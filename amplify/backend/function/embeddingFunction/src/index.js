const AWS = require('aws-sdk');
const bedrock = new AWS.BedrockRuntime({ region: 'us-east-1' });
const pinecone = require('./pinecone-client');

// Environment variables
const EMBEDDING_MODEL_ID = process.env.EMBEDDING_MODEL_ID || 'amazon.titan-embed-text-v1';

/**
 * Lambda function for generating and managing embeddings
 */
exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  const { operation, arguments } = event;
  
  try {
    switch (operation) {
      case 'generateEmbedding':
        return await generateEmbedding(arguments);
      case 'storeSessionEmbedding':
        return await storeSessionEmbedding(arguments);
      case 'storeContentEmbedding':
        return await storeContentEmbedding(arguments);
      case 'findSimilarContent':
        return await findSimilarContent(arguments);
      case 'updateUserEmbedding':
        return await updateUserEmbedding(arguments);
      default:
        throw new Error(`Unknown operation: ${operation}`);
    }
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};

/**
 * Generate embedding for text
 */
async function generateEmbedding({ input }) {
  const { text } = input;
  
  try {
    const response = await bedrock.invokeModel({
      modelId: EMBEDDING_MODEL_ID,
      contentType: 'application/json',
      accept: 'application/json',
      body: JSON.stringify({
        inputText: text
      }),
    }).promise();

    const result = JSON.parse(response.body.toString());
    
    return {
      embedding: result.embedding,
      dimension: result.embedding.length,
    };
  } catch (error) {
    console.error('Error generating embedding:', error);
    throw error;
  }
}

/**
 * Store study session embedding
 */
async function storeSessionEmbedding({ input }) {
  const { sessionId, userId, text, metadata } = input;
  
  const pineconeClient = new pinecone.PineconeClient();
  await pineconeClient.initialize();
  
  try {
    // Generate embedding
    const embeddingResult = await generateEmbedding({ input: { text } });
    
    // Add session-specific metadata
    const enrichedMetadata = {
      ...metadata,
      userId,
      timestamp: new Date().toISOString(),
      type: 'session',
    };
    
    // Store in Pinecone
    await pineconeClient.storeStudySession({
      sessionId,
      userId,
      embedding: embeddingResult.embedding,
      metadata: enrichedMetadata,
    });
    
    return {
      success: true,
      sessionId,
      embeddingDimension: embeddingResult.dimension,
    };
  } catch (error) {
    console.error('Error storing session embedding:', error);
    throw error;
  }
}

/**
 * Store content embedding (notes, flashcards, etc.)
 */
async function storeContentEmbedding({ input }) {
  const { contentId, userId, contentType, text, metadata } = input;
  
  const pineconeClient = new pinecone.PineconeClient();
  await pineconeClient.initialize();
  
  try {
    // Generate embedding
    const embeddingResult = await generateEmbedding({ input: { text } });
    
    // Store in Pinecone
    await pineconeClient.storeContent({
      contentId,
      userId,
      type: contentType,
      text,
      embedding: embeddingResult.embedding,
      metadata,
    });
    
    // Also store in DynamoDB for quick retrieval
    await storeContentMetadata({
      contentId,
      userId,
      contentType,
      metadata,
    });
    
    return {
      success: true,
      contentId,
      embeddingDimension: embeddingResult.dimension,
    };
  } catch (error) {
    console.error('Error storing content embedding:', error);
    throw error;
  }
}

/**
 * Find similar content using semantic search
 */
async function findSimilarContent({ input }) {
  const { query, userId, contentTypes, limit = 10, filters = {} } = input;
  
  const pineconeClient = new pinecone.PineconeClient();
  await pineconeClient.initialize();
  
  try {
    // Generate query embedding
    const queryEmbedding = await generateEmbedding({ input: { text: query } });
    
    // Search in Pinecone
    const results = await pineconeClient.searchStudyMaterials(query, {
      userId,
      contentTypes,
      limit,
      ...filters,
    });
    
    // Enrich results with additional data
    const enrichedResults = await enrichResults(results);
    
    return {
      query,
      results: enrichedResults,
      totalFound: results.length,
    };
  } catch (error) {
    console.error('Error finding similar content:', error);
    throw error;
  }
}

/**
 * Update user profile embedding based on activity
 */
async function updateUserEmbedding({ input }) {
  const { userId, recentActivities, preferences } = input;
  
  const pineconeClient = new pinecone.PineconeClient();
  await pineconeClient.initialize();
  
  try {
    // Create user profile text
    const profileText = createUserProfileText(recentActivities, preferences);
    
    // Generate embedding
    const embeddingResult = await generateEmbedding({ input: { text: profileText } });
    
    // Store/update user embedding
    await pineconeClient.index.upsert({
      upsertRequest: {
        vectors: [{
          id: `user-${userId}`,
          values: embeddingResult.embedding,
          metadata: {
            userId,
            type: 'user_profile',
            preferences,
            lastUpdated: new Date().toISOString(),
          },
        }],
      },
    });
    
    return {
      success: true,
      userId,
      profileUpdated: true,
    };
  } catch (error) {
    console.error('Error updating user embedding:', error);
    throw error;
  }
}

/**
 * Helper functions
 */

function createUserProfileText(activities, preferences) {
  const subjects = [...new Set(activities.map(a => a.subject))].join(', ');
  const topics = [...new Set(activities.map(a => a.topic))].join(', ');
  const avgPerformance = activities.reduce((sum, a) => sum + (a.performance || 0), 0) / activities.length;
  
  return `
User learning profile:
Subjects: ${subjects}
Topics studied: ${topics}
Average performance: ${avgPerformance.toFixed(2)}
Learning preferences: ${JSON.stringify(preferences)}
Recent focus areas: ${activities.slice(0, 5).map(a => a.topic).join(', ')}
  `.trim();
}

async function storeContentMetadata({ contentId, userId, contentType, metadata }) {
  const dynamodb = new AWS.DynamoDB.DocumentClient();
  
  await dynamodb.put({
    TableName: process.env.CONTENT_TABLE,
    Item: {
      contentId,
      userId,
      contentType,
      ...metadata,
      createdAt: new Date().toISOString(),
    },
  }).promise();
}

async function enrichResults(results) {
  const dynamodb = new AWS.DynamoDB.DocumentClient();
  
  const enrichmentPromises = results.map(async (result) => {
    try {
      // Get additional metadata from DynamoDB
      const response = await dynamodb.get({
        TableName: process.env.CONTENT_TABLE,
        Key: { contentId: result.id },
      }).promise();
      
      return {
        ...result,
        enrichedData: response.Item || {},
      };
    } catch (error) {
      console.error(`Error enriching result ${result.id}:`, error);
      return result;
    }
  });
  
  return Promise.all(enrichmentPromises);
}

module.exports = { handler };