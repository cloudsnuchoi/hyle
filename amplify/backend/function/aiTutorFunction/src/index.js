const AWS = require('aws-sdk');
const bedrock = new AWS.BedrockRuntime({ region: 'us-east-1' });
const dynamodb = new AWS.DynamoDB.DocumentClient();
const neptune = require('./neptune-client');
const pinecone = require('./pinecone-client');

// Environment variables
const BEDROCK_MODEL_ID = process.env.BEDROCK_MODEL_ID || 'anthropic.claude-3-opus-20240229';
const USERS_TABLE = process.env.USERS_TABLE;
const SESSIONS_TABLE = process.env.SESSIONS_TABLE;

/**
 * Main Lambda handler for AI tutor functions
 */
exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  const { operation, arguments } = event;
  
  try {
    switch (operation) {
      case 'generateStudyPlan':
        return await generateStudyPlan(arguments);
      case 'analyzeSession':
        return await analyzeSession(arguments);
      case 'predictTaskDuration':
        return await predictTaskDuration(arguments);
      case 'getRealtimeAdvice':
        return await getRealtimeAdvice(arguments);
      case 'analyzeLearningPattern':
        return await analyzeLearningPattern(arguments);
      default:
        throw new Error(`Unknown operation: ${operation}`);
    }
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};

/**
 * Generate a personalized study plan using Claude
 */
async function generateStudyPlan({ input }) {
  const { prompt, userLevel, learningType, availableHours, subjects, examDate } = input;
  
  // Get user's learning history from DynamoDB
  const userHistory = await getUserLearningHistory(input.userId);
  
  // Get similar patterns from Pinecone
  const similarPatterns = await pinecone.findSimilarStudyPatterns({
    learningType,
    subjects,
    userLevel,
  });
  
  // Construct prompt for Claude
  const systemPrompt = `You are an expert AI tutor helping students create personalized study plans. 
The student has learning type ${learningType}, is at level ${userLevel}, and has ${availableHours} hours available.
Their subjects are: ${subjects.join(', ')}.
${examDate ? `They have an exam on ${examDate}.` : ''}

Based on their learning history and similar successful students, create an optimal study plan.

User's recent performance:
${JSON.stringify(userHistory, null, 2)}

Similar successful patterns:
${JSON.stringify(similarPatterns, null, 2)}`;

  const claudeResponse = await bedrock.invokeModel({
    modelId: BEDROCK_MODEL_ID,
    contentType: 'application/json',
    accept: 'application/json',
    body: JSON.stringify({
      anthropic_version: "bedrock-2023-05-31",
      messages: [
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      max_tokens: 2000,
      temperature: 0.7,
    }),
  }).promise();

  const response = JSON.parse(claudeResponse.body.toString());
  const studyPlan = parseStudyPlanResponse(response.content);
  
  // Store the plan in DynamoDB for tracking
  await storePlan(input.userId, studyPlan);
  
  return {
    id: generateId(),
    tasks: studyPlan.tasks,
    totalHours: studyPlan.totalHours,
    recommendations: studyPlan.recommendations,
  };
}

/**
 * Analyze ongoing study session for real-time feedback
 */
async function analyzeSession({ input }) {
  const { sessionId, duration, pauseCount, taskCompletionRate, timeOfDay, subject } = input;
  
  // Get user's typical patterns from Neptune
  const userPatterns = await neptune.getUserStudyPatterns(sessionId);
  
  // Calculate productivity metrics
  const productivityScore = calculateProductivityScore({
    duration,
    pauseCount,
    taskCompletionRate,
    userPatterns,
  });
  
  // Determine focus level
  const focusLevel = determineFocusLevel(pauseCount, duration);
  
  // Generate suggestions based on current state
  const suggestions = await generateSessionSuggestions({
    productivityScore,
    focusLevel,
    timeOfDay,
    subject,
    userPatterns,
  });
  
  // Check if break is needed
  const breakRecommended = shouldRecommendBreak(duration, productivityScore, pauseCount);
  
  // Determine next best action
  const nextBestAction = await determineNextAction({
    currentSubject: subject,
    duration,
    productivityScore,
    userPatterns,
  });
  
  return {
    productivityScore,
    focusLevel,
    suggestions,
    breakRecommended,
    nextBestAction,
  };
}

/**
 * Predict task duration based on historical data
 */
async function predictTaskDuration({ input }) {
  const { taskTitle, subject, userId } = input;
  
  // Get user's historical task completion times
  const historicalTasks = await dynamodb.query({
    TableName: 'TodoTable',
    IndexName: 'byUser',
    KeyConditionExpression: 'userID = :userId',
    FilterExpression: 'subject = :subject AND completed = :completed',
    ExpressionAttributeValues: {
      ':userId': userId,
      ':subject': subject,
      ':completed': true,
    },
    Limit: 50,
  }).promise();
  
  // Find similar tasks using embeddings
  const taskEmbedding = await generateTaskEmbedding(taskTitle);
  const similarTasks = await pinecone.findSimilarTasks(taskEmbedding, subject);
  
  // Calculate average duration with confidence
  const { estimatedMinutes, confidence } = calculateDurationEstimate(
    historicalTasks.Items,
    similarTasks
  );
  
  return {
    estimatedMinutes,
    confidence,
    basedOnSessions: historicalTasks.Items.length,
  };
}

/**
 * Provide real-time advice based on current context
 */
async function getRealtimeAdvice({ input }) {
  const { question, currentActivity, timeStudied, energyLevel, upcomingDeadlines, recentPerformance } = input;
  
  // Analyze current context
  const contextAnalysis = analyzeStudyContext({
    currentActivity,
    timeStudied,
    energyLevel,
    upcomingDeadlines,
    recentPerformance,
  });
  
  // Generate advice using Claude
  const systemPrompt = `You are a supportive AI tutor providing real-time study advice.
Current context:
- Activity: ${currentActivity}
- Time studied: ${timeStudied} minutes
- Energy level: ${energyLevel}/10
- Upcoming deadlines: ${upcomingDeadlines.join(', ')}
- Recent performance: ${JSON.stringify(recentPerformance)}

Analysis: ${JSON.stringify(contextAnalysis)}

Provide brief, actionable advice in response to the student's question.`;

  const claudeResponse = await bedrock.invokeModel({
    modelId: BEDROCK_MODEL_ID,
    contentType: 'application/json',
    accept: 'application/json',
    body: JSON.stringify({
      anthropic_version: "bedrock-2023-05-31",
      messages: [
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: question
        }
      ],
      max_tokens: 500,
      temperature: 0.6,
    }),
  }).promise();

  const response = JSON.parse(claudeResponse.body.toString());
  
  return {
    advice: response.content,
    confidence: contextAnalysis.confidence,
    reasoning: contextAnalysis.reasoning,
  };
}

/**
 * Analyze learning patterns over time
 */
async function analyzeLearningPattern({ input }) {
  const { userId, startDate, endDate } = input;
  
  // Get all study sessions in date range
  const sessions = await getStudySessions(userId, startDate, endDate);
  
  // Analyze patterns using Neptune graph
  const patterns = await neptune.analyzeLearningGraph(userId, sessions);
  
  // Calculate statistics
  const stats = calculateLearningStatistics(sessions);
  
  // Generate insights using AI
  const insights = await generateLearningInsights(patterns, stats);
  
  return {
    peakHours: stats.peakHours,
    bestSubjects: stats.bestSubjects,
    averageSessionLength: stats.averageSessionLength,
    consistencyScore: stats.consistencyScore,
    recommendations: insights.recommendations,
    strengths: insights.strengths,
    areasForImprovement: insights.areasForImprovement,
  };
}

// Helper functions
function calculateProductivityScore({ duration, pauseCount, taskCompletionRate, userPatterns }) {
  const baseScore = taskCompletionRate;
  const pausePenalty = Math.max(0, 1 - (pauseCount * 0.1));
  const durationBonus = duration > userPatterns.avgDuration ? 1.1 : 0.9;
  
  return Math.min(1, baseScore * pausePenalty * durationBonus);
}

function determineFocusLevel(pauseCount, duration) {
  const pauseRate = pauseCount / (duration / 60); // pauses per hour
  
  if (pauseRate < 2) return 'excellent';
  if (pauseRate < 4) return 'good';
  if (pauseRate < 6) return 'fair';
  return 'poor';
}

function shouldRecommendBreak(duration, productivityScore, pauseCount) {
  // Recommend break if studied for 90+ minutes
  if (duration >= 90) return true;
  
  // Recommend break if productivity is dropping
  if (duration >= 45 && productivityScore < 0.6) return true;
  
  // Recommend break if too many pauses (signs of fatigue)
  if (pauseCount > 5 && duration >= 30) return true;
  
  return false;
}

async function generateSessionSuggestions({ productivityScore, focusLevel, timeOfDay, subject, userPatterns }) {
  const suggestions = [];
  
  if (productivityScore < 0.6) {
    suggestions.push('Consider switching to a different subject or taking a short break');
  }
  
  if (focusLevel === 'poor') {
    suggestions.push('Try the Pomodoro technique to improve focus');
  }
  
  if (timeOfDay === 'night' && userPatterns.bestTime !== 'night') {
    suggestions.push('You typically perform better earlier in the day');
  }
  
  if (subject === userPatterns.weakestSubject) {
    suggestions.push(`Break down ${subject} into smaller, manageable chunks`);
  }
  
  return suggestions;
}

async function getUserLearningHistory(userId) {
  const params = {
    TableName: SESSIONS_TABLE,
    IndexName: 'byUser',
    KeyConditionExpression: 'userID = :userId',
    ExpressionAttributeValues: {
      ':userId': userId,
    },
    Limit: 20,
    ScanIndexForward: false, // Get most recent first
  };
  
  const result = await dynamodb.query(params).promise();
  return result.Items;
}

function generateId() {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

function parseStudyPlanResponse(claudeResponse) {
  // Parse Claude's response into structured format
  // This is a simplified version - in production, use more robust parsing
  try {
    const lines = claudeResponse.split('\n');
    const tasks = [];
    const recommendations = [];
    let totalHours = 0;
    
    let inTaskSection = false;
    let inRecommendationSection = false;
    
    for (const line of lines) {
      if (line.includes('Tasks:') || line.includes('Study Plan:')) {
        inTaskSection = true;
        inRecommendationSection = false;
        continue;
      }
      
      if (line.includes('Recommendations:') || line.includes('Tips:')) {
        inTaskSection = false;
        inRecommendationSection = true;
        continue;
      }
      
      if (inTaskSection && line.trim()) {
        // Parse task format: "- Math: Chapter 5 Review (45 minutes)"
        const match = line.match(/- (.+): (.+) \((\d+) minutes?\)/);
        if (match) {
          tasks.push({
            title: match[2].trim(),
            subject: match[1].trim(),
            estimatedMinutes: parseInt(match[3]),
            priority: 'MEDIUM', // Default, could be enhanced
          });
          totalHours += parseInt(match[3]) / 60;
        }
      }
      
      if (inRecommendationSection && line.trim() && line.startsWith('-')) {
        recommendations.push(line.substring(1).trim());
      }
    }
    
    return { tasks, totalHours, recommendations };
  } catch (error) {
    console.error('Error parsing Claude response:', error);
    return {
      tasks: [],
      totalHours: 0,
      recommendations: ['Please try rephrasing your request'],
    };
  }
}

async function storePlan(userId, plan) {
  const params = {
    TableName: 'StudyPlansTable',
    Item: {
      id: generateId(),
      userId,
      plan,
      createdAt: new Date().toISOString(),
    },
  };
  
  await dynamodb.put(params).promise();
}

module.exports = { handler };