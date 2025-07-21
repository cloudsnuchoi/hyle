const AWS = require('aws-sdk');
const kinesis = new AWS.Kinesis();
const dynamodb = new AWS.DynamoDB.DocumentClient();
const eventbridge = new AWS.EventBridge();
const sns = new AWS.SNS();

// Environment variables
const STREAM_NAME = process.env.KINESIS_STREAM_NAME;
const USERS_TABLE = process.env.USERS_TABLE;
const SESSIONS_TABLE = process.env.SESSIONS_TABLE;
const ANALYTICS_TABLE = process.env.ANALYTICS_TABLE;

/**
 * Real-time event processing Lambda
 * Processes events from Kinesis stream for real-time analytics and triggers
 */
exports.handler = async (event) => {
  console.log('Processing batch of', event.Records.length, 'records');
  
  const promises = event.Records.map(async (record) => {
    // Decode Kinesis data
    const payload = JSON.parse(
      Buffer.from(record.kinesis.data, 'base64').toString('utf-8')
    );
    
    console.log('Processing event:', payload.eventType);
    
    try {
      switch (payload.eventType) {
        case 'STUDY_SESSION_START':
          await handleSessionStart(payload);
          break;
        case 'STUDY_SESSION_END':
          await handleSessionEnd(payload);
          break;
        case 'TODO_COMPLETED':
          await handleTodoCompleted(payload);
          break;
        case 'FOCUS_BREAK_NEEDED':
          await handleFocusBreak(payload);
          break;
        case 'ACHIEVEMENT_UNLOCKED':
          await handleAchievement(payload);
          break;
        case 'PATTERN_DETECTED':
          await handlePatternDetection(payload);
          break;
        case 'MILESTONE_REACHED':
          await handleMilestone(payload);
          break;
        default:
          console.log('Unknown event type:', payload.eventType);
      }
      
      // Store raw event for analytics
      await storeAnalyticsEvent(payload);
      
    } catch (error) {
      console.error('Error processing record:', error);
      // In production, send to DLQ
    }
  });
  
  await Promise.all(promises);
  
  return {
    batchItemFailures: [] // In production, track failed records
  };
};

/**
 * Handle study session start
 */
async function handleSessionStart(payload) {
  const { userId, sessionId, subject, plannedDuration, startTime } = payload;
  
  // Update user's current status
  await dynamodb.update({
    TableName: USERS_TABLE,
    Key: { id: userId },
    UpdateExpression: 'SET currentSession = :session, isStudying = :true, lastActive = :now',
    ExpressionAttributeValues: {
      ':session': sessionId,
      ':true': true,
      ':now': new Date().toISOString(),
    },
  }).promise();
  
  // Check for study buddies
  const studyBuddies = await findActiveStudyBuddies(userId, subject);
  if (studyBuddies.length > 0) {
    await notifyStudyBuddies(userId, studyBuddies, subject);
  }
  
  // Schedule break reminders
  await scheduleBreakReminders(userId, sessionId, plannedDuration);
}

/**
 * Handle study session end
 */
async function handleSessionEnd(payload) {
  const { userId, sessionId, duration, productivity, completedTodos } = payload;
  
  // Calculate session metrics
  const metrics = calculateSessionMetrics({
    duration,
    productivity,
    completedTodos,
  });
  
  // Update user stats
  await updateUserStats(userId, metrics);
  
  // Check for achievements
  const achievements = await checkAchievements(userId, metrics);
  if (achievements.length > 0) {
    await grantAchievements(userId, achievements);
  }
  
  // Analyze patterns
  const patterns = await analyzeUserPatterns(userId);
  if (patterns.newPatternDetected) {
    await publishEvent({
      eventType: 'PATTERN_DETECTED',
      userId,
      patterns: patterns.detected,
    });
  }
  
  // Clear active session
  await dynamodb.update({
    TableName: USERS_TABLE,
    Key: { id: userId },
    UpdateExpression: 'REMOVE currentSession SET isStudying = :false',
    ExpressionAttributeValues: {
      ':false': false,
    },
  }).promise();
}

/**
 * Handle todo completion
 */
async function handleTodoCompleted(payload) {
  const { userId, todoId, actualTime, estimatedTime, subject } = payload;
  
  // Calculate accuracy for future predictions
  const accuracy = Math.abs(1 - (actualTime / estimatedTime));
  
  // Update prediction model data
  await updatePredictionData(userId, subject, accuracy);
  
  // Check for streaks
  const streak = await checkTodoStreak(userId);
  if (streak.isNewRecord) {
    await publishEvent({
      eventType: 'MILESTONE_REACHED',
      userId,
      milestone: 'todo_streak',
      value: streak.current,
    });
  }
  
  // Update daily/weekly missions
  await updateMissions(userId, 'TODO_COMPLETED', { subject });
}

/**
 * Handle focus break needed
 */
async function handleFocusBreak(payload) {
  const { userId, sessionId, reason, urgency } = payload;
  
  // Send push notification
  await sendPushNotification(userId, {
    title: 'Time for a break! 🧘',
    body: getBreakMessage(reason),
    data: {
      type: 'BREAK_REMINDER',
      sessionId,
      urgency,
    },
  });
  
  // Log break recommendation
  await dynamodb.put({
    TableName: ANALYTICS_TABLE,
    Item: {
      id: `break-${Date.now()}`,
      userId,
      sessionId,
      type: 'BREAK_RECOMMENDATION',
      reason,
      timestamp: new Date().toISOString(),
    },
  }).promise();
}

/**
 * Handle achievement unlock
 */
async function handleAchievement(payload) {
  const { userId, achievementId, xpReward, coinReward } = payload;
  
  // Grant rewards
  await grantRewards(userId, { xp: xpReward, coins: coinReward });
  
  // Send celebration notification
  await sendPushNotification(userId, {
    title: '🎉 Achievement Unlocked!',
    body: `You've earned ${xpReward} XP and ${coinReward} coins!`,
    data: {
      type: 'ACHIEVEMENT',
      achievementId,
    },
  });
  
  // Update leaderboards
  await updateLeaderboards(userId, xpReward);
  
  // Check for level up
  const levelUp = await checkLevelUp(userId);
  if (levelUp.didLevelUp) {
    await publishEvent({
      eventType: 'MILESTONE_REACHED',
      userId,
      milestone: 'level_up',
      value: levelUp.newLevel,
    });
  }
}

/**
 * Handle pattern detection
 */
async function handlePatternDetection(payload) {
  const { userId, patterns } = payload;
  
  // Generate insights based on patterns
  const insights = generateInsights(patterns);
  
  // Store insights for AI recommendations
  await dynamodb.put({
    TableName: 'InsightsTable',
    Item: {
      id: `insight-${Date.now()}`,
      userId,
      patterns,
      insights,
      timestamp: new Date().toISOString(),
    },
  }).promise();
  
  // Notify user of new insights
  if (insights.priority === 'high') {
    await sendPushNotification(userId, {
      title: '💡 New Learning Insight',
      body: insights.summary,
      data: {
        type: 'INSIGHT',
        insightId: insights.id,
      },
    });
  }
}

/**
 * Handle milestone reached
 */
async function handleMilestone(payload) {
  const { userId, milestone, value } = payload;
  
  // Record milestone
  await dynamodb.put({
    TableName: 'MilestonesTable',
    Item: {
      id: `milestone-${Date.now()}`,
      userId,
      milestone,
      value,
      timestamp: new Date().toISOString(),
    },
  }).promise();
  
  // Share to social feed if significant
  if (isSignificantMilestone(milestone, value)) {
    await createSocialPost(userId, {
      type: 'MILESTONE',
      milestone,
      value,
    });
  }
  
  // Update user profile
  await updateUserProfile(userId, milestone, value);
}

// Helper functions
async function findActiveStudyBuddies(userId, subject) {
  // Find friends currently studying the same subject
  const user = await dynamodb.get({
    TableName: USERS_TABLE,
    Key: { id: userId },
  }).promise();
  
  if (!user.Item || !user.Item.friends) {
    return [];
  }
  
  const friendPromises = user.Item.friends.map(async (friendId) => {
    const friend = await dynamodb.get({
      TableName: USERS_TABLE,
      Key: { id: friendId },
    }).promise();
    
    if (friend.Item && friend.Item.isStudying && friend.Item.currentSubject === subject) {
      return friend.Item;
    }
    return null;
  });
  
  const friends = await Promise.all(friendPromises);
  return friends.filter(f => f !== null);
}

async function notifyStudyBuddies(userId, buddies, subject) {
  const user = await dynamodb.get({
    TableName: USERS_TABLE,
    Key: { id: userId },
  }).promise();
  
  const notifications = buddies.map(buddy => 
    sendPushNotification(buddy.id, {
      title: `${user.Item.name} is studying ${subject}!`,
      body: 'Join them for a group study session',
      data: {
        type: 'STUDY_BUDDY',
        userId,
        subject,
      },
    })
  );
  
  await Promise.all(notifications);
}

async function scheduleBreakReminders(userId, sessionId, plannedDuration) {
  // Schedule breaks based on duration
  const breaks = [];
  
  if (plannedDuration >= 45) {
    breaks.push({
      delay: 45 * 60, // 45 minutes
      message: 'Time for a 5-minute break!',
    });
  }
  
  if (plannedDuration >= 90) {
    breaks.push({
      delay: 90 * 60, // 90 minutes
      message: 'You\'ve been studying for 90 minutes. Take a 15-minute break!',
    });
  }
  
  // Use EventBridge to schedule reminders
  const rulePromises = breaks.map(async (breakReminder, index) => {
    const ruleName = `break-${sessionId}-${index}`;
    const scheduleTime = new Date(Date.now() + breakReminder.delay * 1000);
    
    await eventbridge.putRule({
      Name: ruleName,
      ScheduleExpression: `at(${scheduleTime.toISOString()})`,
      State: 'ENABLED',
    }).promise();
    
    await eventbridge.putTargets({
      Rule: ruleName,
      Targets: [{
        Id: '1',
        Arn: process.env.LAMBDA_ARN,
        Input: JSON.stringify({
          eventType: 'FOCUS_BREAK_NEEDED',
          userId,
          sessionId,
          reason: 'scheduled',
          message: breakReminder.message,
        }),
      }],
    }).promise();
  });
  
  await Promise.all(rulePromises);
}

async function calculateSessionMetrics({ duration, productivity, completedTodos }) {
  return {
    duration,
    productivity,
    completedTodos,
    xpEarned: Math.floor(duration * productivity * 1.5),
    efficiency: completedTodos / (duration / 60), // todos per hour
  };
}

async function updateUserStats(userId, metrics) {
  await dynamodb.update({
    TableName: USERS_TABLE,
    Key: { id: userId },
    UpdateExpression: `
      ADD totalStudyTime :duration,
          totalXP :xp,
          todosCompleted :todos
      SET lastSessionMetrics = :metrics,
          updatedAt = :now
    `,
    ExpressionAttributeValues: {
      ':duration': metrics.duration,
      ':xp': metrics.xpEarned,
      ':todos': metrics.completedTodos,
      ':metrics': metrics,
      ':now': new Date().toISOString(),
    },
  }).promise();
}

async function checkAchievements(userId, metrics) {
  const achievements = [];
  
  // Check various achievement conditions
  if (metrics.duration >= 120) {
    achievements.push({
      id: 'marathon_session',
      name: 'Marathon Session',
      description: 'Study for 2+ hours in one session',
      xp: 100,
      coins: 20,
    });
  }
  
  if (metrics.efficiency >= 3) {
    achievements.push({
      id: 'efficiency_master',
      name: 'Efficiency Master',
      description: 'Complete 3+ todos per hour',
      xp: 50,
      coins: 10,
    });
  }
  
  if (metrics.productivity >= 0.9) {
    achievements.push({
      id: 'focus_champion',
      name: 'Focus Champion',
      description: '90%+ productivity in a session',
      xp: 75,
      coins: 15,
    });
  }
  
  // Check if already unlocked
  const user = await dynamodb.get({
    TableName: USERS_TABLE,
    Key: { id: userId },
  }).promise();
  
  const unlockedAchievements = user.Item.achievements || [];
  return achievements.filter(a => !unlockedAchievements.includes(a.id));
}

async function sendPushNotification(userId, notification) {
  // Get user's device tokens
  const user = await dynamodb.get({
    TableName: USERS_TABLE,
    Key: { id: userId },
  }).promise();
  
  if (!user.Item || !user.Item.deviceTokens) {
    return;
  }
  
  // Send via SNS
  const promises = user.Item.deviceTokens.map(token => 
    sns.publish({
      TargetArn: token,
      Message: JSON.stringify({
        default: notification.body,
        APNS: JSON.stringify({
          aps: {
            alert: {
              title: notification.title,
              body: notification.body,
            },
            sound: 'default',
            badge: 1,
          },
          data: notification.data,
        }),
        GCM: JSON.stringify({
          notification: {
            title: notification.title,
            body: notification.body,
          },
          data: notification.data,
        }),
      }),
      MessageStructure: 'json',
    }).promise()
  );
  
  await Promise.all(promises);
}

async function storeAnalyticsEvent(event) {
  await dynamodb.put({
    TableName: ANALYTICS_TABLE,
    Item: {
      id: `event-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      ...event,
      timestamp: new Date().toISOString(),
      ttl: Math.floor(Date.now() / 1000) + (90 * 24 * 60 * 60), // 90 days
    },
  }).promise();
}

async function publishEvent(event) {
  await kinesis.putRecord({
    StreamName: STREAM_NAME,
    Data: JSON.stringify(event),
    PartitionKey: event.userId,
  }).promise();
}

function getBreakMessage(reason) {
  const messages = {
    scheduled: 'Time for your scheduled break!',
    low_productivity: 'Your focus is dropping. A short break will help!',
    long_session: 'You\'ve been at it for a while. Rest your mind!',
    eye_strain: 'Give your eyes a rest. Look at something distant.',
  };
  return messages[reason] || 'Take a break to stay productive!';
}

function generateInsights(patterns) {
  // Analyze patterns and generate actionable insights
  const insights = {
    id: `insight-${Date.now()}`,
    summary: '',
    priority: 'medium',
    recommendations: [],
  };
  
  if (patterns.includes('declining_afternoon_productivity')) {
    insights.summary = 'Your afternoon productivity is declining';
    insights.recommendations.push('Try a 20-minute power nap after lunch');
    insights.priority = 'high';
  }
  
  if (patterns.includes('consistent_morning_start')) {
    insights.summary = 'Great job maintaining morning study routine!';
    insights.recommendations.push('Consider tackling harder subjects in the morning');
  }
  
  return insights;
}

function isSignificantMilestone(milestone, value) {
  const significant = {
    level_up: value % 10 === 0, // Every 10 levels
    study_streak: value % 7 === 0, // Weekly streaks
    total_hours: value % 100 === 0, // Every 100 hours
    todo_streak: value % 30 === 0, // Monthly todo streaks
  };
  
  return significant[milestone] || false;
}

module.exports = { handler };