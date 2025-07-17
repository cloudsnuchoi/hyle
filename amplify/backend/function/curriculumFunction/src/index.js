const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const s3 = new AWS.S3();

// Environment variables
const CURRICULUM_TABLE = process.env.CURRICULUM_TABLE || 'CurriculumTable';
const SYLLABUS_BUCKET = process.env.SYLLABUS_BUCKET || 'hyle-syllabus-bucket';

/**
 * Lambda function for curriculum data management
 */
exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  const { operation, arguments } = event;
  
  try {
    switch (operation) {
      case 'getCurriculumData':
        return await getCurriculumData(arguments);
      case 'getDetailedSyllabus':
        return await getDetailedSyllabus(arguments);
      case 'mapActivityToCurriculum':
        return await mapActivityToCurriculum(arguments);
      case 'trackTopicProgress':
        return await trackTopicProgress(arguments);
      case 'getCurriculumRecommendations':
        return await getCurriculumRecommendations(arguments);
      case 'generateStudyPath':
        return await generateStudyPath(arguments);
      default:
        throw new Error(`Unknown operation: ${operation}`);
    }
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};

/**
 * Get comprehensive curriculum data
 */
async function getCurriculumData({ input }) {
  const { curriculumType, subject, grade } = input;
  
  try {
    // Get curriculum structure
    const params = {
      TableName: CURRICULUM_TABLE,
      Key: {
        PK: `CURRICULUM#${curriculumType}`,
        SK: `SUBJECT#${subject}`,
      },
    };
    
    const result = await dynamodb.get(params).promise();
    
    if (!result.Item) {
      // Return default structure
      return getDefaultCurriculum(curriculumType, subject);
    }
    
    // Get detailed topics
    const topicsParams = {
      TableName: CURRICULUM_TABLE,
      KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
      ExpressionAttributeValues: {
        ':pk': `CURRICULUM#${curriculumType}#${subject}`,
        ':sk': 'TOPIC#',
      },
    };
    
    const topicsResult = await dynamodb.query(topicsParams).promise();
    
    return {
      curriculum: result.Item,
      topics: topicsResult.Items,
      totalTopics: topicsResult.Count,
    };
  } catch (error) {
    console.error('Error getting curriculum data:', error);
    throw error;
  }
}

/**
 * Get detailed syllabus from S3
 */
async function getDetailedSyllabus({ input }) {
  const { examType, subject, year = new Date().getFullYear() } = input;
  
  try {
    const key = `syllabi/${examType}/${subject}/${year}.json`;
    
    const params = {
      Bucket: SYLLABUS_BUCKET,
      Key: key,
    };
    
    const data = await s3.getObject(params).promise();
    const syllabus = JSON.parse(data.Body.toString());
    
    return {
      examType,
      subject,
      year,
      syllabus,
    };
  } catch (error) {
    if (error.code === 'NoSuchKey') {
      // Return template syllabus
      return getTemplateSyllabus(examType, subject);
    }
    throw error;
  }
}

/**
 * Map user activity to curriculum standards
 */
async function mapActivityToCurriculum({ input }) {
  const { activityText, subject, curriculumType, userId } = input;
  
  try {
    // Extract keywords from activity
    const keywords = extractKeywords(activityText);
    
    // Find matching topics in curriculum
    const matchingTopics = await findMatchingTopics(
      keywords,
      subject,
      curriculumType
    );
    
    // Calculate relevance scores
    const scoredTopics = matchingTopics.map(topic => ({
      ...topic,
      relevanceScore: calculateRelevance(keywords, topic),
    }));
    
    // Sort by relevance
    scoredTopics.sort((a, b) => b.relevanceScore - a.relevanceScore);
    
    // Get top matches
    const topMatches = scoredTopics.slice(0, 5);
    
    // Store mapping for learning analytics
    if (userId && topMatches.length > 0) {
      await storeActivityMapping(userId, activityText, topMatches);
    }
    
    return {
      activity: activityText,
      mappedTopics: topMatches,
      confidence: topMatches[0]?.relevanceScore || 0,
    };
  } catch (error) {
    console.error('Error mapping activity to curriculum:', error);
    throw error;
  }
}

/**
 * Track topic progress
 */
async function trackTopicProgress({ input }) {
  const { userId, topicId, progress, performance, timeSpent } = input;
  
  try {
    const timestamp = new Date().toISOString();
    
    // Store progress record
    await dynamodb.put({
      TableName: CURRICULUM_TABLE,
      Item: {
        PK: `USER#${userId}`,
        SK: `PROGRESS#${topicId}#${timestamp}`,
        topicId,
        progress,
        performance,
        timeSpent,
        timestamp,
        TTL: Math.floor(Date.now() / 1000) + (365 * 24 * 60 * 60), // 1 year
      },
    }).promise();
    
    // Update aggregate progress
    await updateAggregateProgress(userId, topicId, progress, performance);
    
    // Check for milestone achievements
    const milestones = await checkMilestones(userId, topicId, progress);
    
    return {
      success: true,
      milestones,
    };
  } catch (error) {
    console.error('Error tracking topic progress:', error);
    throw error;
  }
}

/**
 * Get curriculum-based recommendations
 */
async function getCurriculumRecommendations({ input }) {
  const { userId, curriculumType, subject, currentTopic } = input;
  
  try {
    // Get user's progress
    const userProgress = await getUserProgress(userId, curriculumType, subject);
    
    // Get curriculum structure
    const curriculum = await getCurriculumStructure(curriculumType, subject);
    
    // Find next topics based on prerequisites
    const nextTopics = findNextTopics(
      currentTopic,
      userProgress,
      curriculum
    );
    
    // Get review topics based on performance
    const reviewTopics = findReviewTopics(userProgress);
    
    // Get challenge topics for advanced learners
    const challengeTopics = findChallengeTopics(
      userProgress,
      curriculum
    );
    
    return {
      next: nextTopics,
      review: reviewTopics,
      challenge: challengeTopics,
    };
  } catch (error) {
    console.error('Error getting curriculum recommendations:', error);
    throw error;
  }
}

/**
 * Generate personalized study path
 */
async function generateStudyPath({ input }) {
  const { userId, targetExam, targetDate, dailyHours, weakAreas } = input;
  
  try {
    // Get exam requirements
    const examRequirements = await getExamRequirements(targetExam);
    
    // Get user's current level
    const userLevel = await assessUserLevel(userId, examRequirements.subjects);
    
    // Calculate available study time
    const daysUntilExam = Math.floor(
      (new Date(targetDate) - new Date()) / (1000 * 60 * 60 * 24)
    );
    const totalHours = daysUntilExam * dailyHours;
    
    // Generate path
    const studyPath = generateOptimalPath({
      examRequirements,
      userLevel,
      totalHours,
      weakAreas,
      daysUntilExam,
    });
    
    // Store study plan
    await storeStudyPlan(userId, studyPath);
    
    return studyPath;
  } catch (error) {
    console.error('Error generating study path:', error);
    throw error;
  }
}

/**
 * Helper functions
 */

function getDefaultCurriculum(curriculumType, subject) {
  const defaults = {
    'korean_sat': {
      mathematics: {
        name: '수학',
        units: [
          { id: 'algebra', name: '대수', weight: 0.25 },
          { id: 'geometry', name: '기하', weight: 0.20 },
          { id: 'calculus', name: '미적분', weight: 0.35 },
          { id: 'probability', name: '확률과 통계', weight: 0.20 },
        ],
      },
      // Add more subjects...
    },
    'ap': {
      'ap_calculus_ab': {
        name: 'AP Calculus AB',
        units: [
          { id: 'limits', name: 'Limits and Continuity', weight: 0.10 },
          { id: 'derivatives', name: 'Differentiation', weight: 0.35 },
          { id: 'applications', name: 'Applications of Differentiation', weight: 0.25 },
          { id: 'integrals', name: 'Integration', weight: 0.30 },
        ],
      },
      // Add more AP subjects...
    },
  };
  
  return defaults[curriculumType]?.[subject] || {
    name: subject,
    units: [],
  };
}

function extractKeywords(text) {
  // Convert to lowercase and split
  const words = text.toLowerCase().split(/\s+/);
  
  // Common stop words to exclude
  const stopWords = new Set([
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    '이', '그', '저', '것', '을', '를', '의', '에', '에서', '으로',
  ]);
  
  // Extract meaningful words
  const keywords = words.filter(word => 
    word.length > 2 && !stopWords.has(word)
  );
  
  // Add n-grams for better matching
  const ngrams = [];
  for (let i = 0; i < words.length - 1; i++) {
    ngrams.push(`${words[i]} ${words[i + 1]}`);
  }
  
  return [...keywords, ...ngrams];
}

async function findMatchingTopics(keywords, subject, curriculumType) {
  const params = {
    TableName: CURRICULUM_TABLE,
    IndexName: 'SubjectIndex',
    KeyConditionExpression: 'subject = :subject',
    FilterExpression: 'curriculumType = :curriculum',
    ExpressionAttributeValues: {
      ':subject': subject,
      ':curriculum': curriculumType,
    },
  };
  
  const result = await dynamodb.query(params).promise();
  
  // Filter topics by keyword matches
  return result.Items.filter(topic => {
    const topicKeywords = [
      ...(topic.keywords || []),
      topic.name.toLowerCase(),
      topic.nameEn?.toLowerCase(),
    ].filter(Boolean);
    
    return keywords.some(keyword => 
      topicKeywords.some(tk => tk.includes(keyword))
    );
  });
}

function calculateRelevance(keywords, topic) {
  const topicKeywords = [
    ...(topic.keywords || []),
    topic.name.toLowerCase(),
    topic.nameEn?.toLowerCase(),
  ].filter(Boolean);
  
  let score = 0;
  let matches = 0;
  
  for (const keyword of keywords) {
    for (const topicKeyword of topicKeywords) {
      if (topicKeyword.includes(keyword)) {
        matches++;
        // Exact match gets higher score
        if (topicKeyword === keyword) {
          score += 2;
        } else {
          score += 1;
        }
      }
    }
  }
  
  // Normalize score
  return matches > 0 ? score / (keywords.length * topicKeywords.length) : 0;
}

async function storeActivityMapping(userId, activity, mappedTopics) {
  const timestamp = new Date().toISOString();
  
  await dynamodb.put({
    TableName: CURRICULUM_TABLE,
    Item: {
      PK: `USER#${userId}`,
      SK: `ACTIVITY#${timestamp}`,
      activity,
      mappedTopics: mappedTopics.map(t => ({
        id: t.id,
        name: t.name,
        relevanceScore: t.relevanceScore,
      })),
      timestamp,
      TTL: Math.floor(Date.now() / 1000) + (90 * 24 * 60 * 60), // 90 days
    },
  }).promise();
}

async function updateAggregateProgress(userId, topicId, progress, performance) {
  const params = {
    TableName: CURRICULUM_TABLE,
    Key: {
      PK: `USER#${userId}`,
      SK: `TOPIC_PROGRESS#${topicId}`,
    },
    UpdateExpression: `
      SET currentProgress = :progress,
          lastPerformance = :performance,
          lastUpdated = :timestamp,
          sessionCount = if_not_exists(sessionCount, :zero) + :one,
          averagePerformance = if_not_exists(averagePerformance, :performance)
    `,
    ExpressionAttributeValues: {
      ':progress': progress,
      ':performance': performance,
      ':timestamp': new Date().toISOString(),
      ':zero': 0,
      ':one': 1,
    },
  };
  
  await dynamodb.update(params).promise();
}

async function checkMilestones(userId, topicId, progress) {
  const milestones = [];
  
  // Topic completion milestone
  if (progress >= 100) {
    milestones.push({
      type: 'topic_completed',
      topicId,
      achievement: 'Topic Master',
      xpReward: 100,
    });
  }
  
  // First progress milestone
  if (progress >= 25) {
    const existing = await dynamodb.get({
      TableName: CURRICULUM_TABLE,
      Key: {
        PK: `USER#${userId}`,
        SK: `MILESTONE#${topicId}#first_quarter`,
      },
    }).promise();
    
    if (!existing.Item) {
      milestones.push({
        type: 'first_quarter',
        topicId,
        achievement: 'Good Start',
        xpReward: 25,
      });
      
      // Store milestone
      await dynamodb.put({
        TableName: CURRICULUM_TABLE,
        Item: {
          PK: `USER#${userId}`,
          SK: `MILESTONE#${topicId}#first_quarter`,
          achieved: true,
          timestamp: new Date().toISOString(),
        },
      }).promise();
    }
  }
  
  return milestones;
}

async function getUserProgress(userId, curriculumType, subject) {
  const params = {
    TableName: CURRICULUM_TABLE,
    KeyConditionExpression: 'PK = :pk AND begins_with(SK, :sk)',
    ExpressionAttributeValues: {
      ':pk': `USER#${userId}`,
      ':sk': 'TOPIC_PROGRESS#',
    },
  };
  
  const result = await dynamodb.query(params).promise();
  
  // Filter by curriculum and subject
  return result.Items.filter(item => 
    item.topicId?.includes(curriculumType) && 
    item.topicId?.includes(subject)
  );
}

function findNextTopics(currentTopic, userProgress, curriculum) {
  // Find topics that have currentTopic as prerequisite
  const completedTopics = userProgress
    .filter(p => p.currentProgress >= 80)
    .map(p => p.topicId);
  
  return curriculum.topics
    .filter(topic => 
      topic.prerequisites.includes(currentTopic) &&
      !completedTopics.includes(topic.id)
    )
    .slice(0, 3);
}

function findReviewTopics(userProgress) {
  // Find topics with low performance
  return userProgress
    .filter(p => p.lastPerformance < 0.7 && p.currentProgress > 50)
    .sort((a, b) => a.lastPerformance - b.lastPerformance)
    .slice(0, 3);
}

function findChallengeTopics(userProgress, curriculum) {
  const masteredTopics = userProgress
    .filter(p => p.currentProgress >= 90 && p.averagePerformance >= 0.85)
    .map(p => p.topicId);
  
  // Find advanced topics
  return curriculum.topics
    .filter(topic => 
      topic.difficulty === 'advanced' &&
      topic.prerequisites.every(prereq => masteredTopics.includes(prereq))
    )
    .slice(0, 2);
}

function generateOptimalPath({ examRequirements, userLevel, totalHours, weakAreas, daysUntilExam }) {
  const path = {
    phases: [],
    totalDuration: daysUntilExam,
    estimatedReadiness: 0,
  };
  
  // Phase 1: Foundation (30% of time)
  const foundationDays = Math.floor(daysUntilExam * 0.3);
  path.phases.push({
    name: 'Foundation Building',
    duration: foundationDays,
    focus: weakAreas.slice(0, 2),
    dailyGoals: {
      concepts: 2,
      problems: 20,
      reviewTime: 30, // minutes
    },
  });
  
  // Phase 2: Core Learning (40% of time)
  const coreDays = Math.floor(daysUntilExam * 0.4);
  path.phases.push({
    name: 'Core Mastery',
    duration: coreDays,
    focus: examRequirements.coreTopics,
    dailyGoals: {
      concepts: 3,
      problems: 30,
      practiceTests: 1, // per week
    },
  });
  
  // Phase 3: Advanced & Review (20% of time)
  const advancedDays = Math.floor(daysUntilExam * 0.2);
  path.phases.push({
    name: 'Advanced Topics',
    duration: advancedDays,
    focus: examRequirements.advancedTopics,
    dailyGoals: {
      concepts: 1,
      problems: 40,
      mockExams: 2, // per week
    },
  });
  
  // Phase 4: Final Review (10% of time)
  const reviewDays = daysUntilExam - foundationDays - coreDays - advancedDays;
  path.phases.push({
    name: 'Final Review',
    duration: reviewDays,
    focus: ['All topics', 'Weak areas', 'Exam strategies'],
    dailyGoals: {
      review: 'All topics',
      problems: 50,
      fullMockExams: 3, // total
    },
  });
  
  // Calculate estimated readiness
  path.estimatedReadiness = calculateReadiness(userLevel, totalHours, examRequirements);
  
  return path;
}

function calculateReadiness(userLevel, totalHours, examRequirements) {
  const currentReadiness = userLevel.overallScore || 0.5;
  const requiredHours = examRequirements.estimatedPrepHours || 200;
  const hoursFactor = Math.min(totalHours / requiredHours, 1.0);
  
  return Math.min(currentReadiness + (hoursFactor * 0.4), 0.95);
}

async function storeStudyPlan(userId, studyPath) {
  await dynamodb.put({
    TableName: CURRICULUM_TABLE,
    Item: {
      PK: `USER#${userId}`,
      SK: 'STUDY_PLAN#CURRENT',
      ...studyPath,
      createdAt: new Date().toISOString(),
    },
  }).promise();
}

module.exports = { handler };