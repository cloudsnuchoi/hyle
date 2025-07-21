const { PineconeClient } = require('@pinecone-database/pinecone');
const AWS = require('aws-sdk');
const bedrock = new AWS.BedrockRuntime({ region: 'us-east-1' });

// Pinecone configuration
const PINECONE_API_KEY = process.env.PINECONE_API_KEY;
const PINECONE_ENVIRONMENT = process.env.PINECONE_ENVIRONMENT;
const PINECONE_INDEX_NAME = process.env.PINECONE_INDEX_NAME || 'hyle-learning';

// Embedding model configuration
const EMBEDDING_MODEL_ID = 'amazon.titan-embed-text-v1';
const EMBEDDING_DIMENSION = 1536;

class PineconeClient {
  constructor() {
    this.client = null;
    this.index = null;
  }

  async initialize() {
    if (!this.client) {
      this.client = new PineconeClient();
      await this.client.init({
        apiKey: PINECONE_API_KEY,
        environment: PINECONE_ENVIRONMENT,
      });
      
      this.index = this.client.Index(PINECONE_INDEX_NAME);
    }
  }

  /**
   * Generate embeddings using Amazon Titan
   */
  async generateEmbedding(text) {
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
      return result.embedding;
    } catch (error) {
      console.error('Error generating embedding:', error);
      throw error;
    }
  }

  /**
   * Store study session in vector DB
   */
  async storeStudySession(session) {
    await this.initialize();

    const {
      sessionId,
      userId,
      subject,
      topic,
      duration,
      performance,
      notes,
      timestamp,
      learningType,
      concepts,
      difficulty
    } = session;

    // Create rich text representation for embedding
    const textRepresentation = this.createSessionText(session);
    const embedding = await this.generateEmbedding(textRepresentation);

    // Prepare metadata
    const metadata = {
      userId,
      subject,
      topic,
      duration,
      performance,
      timestamp,
      learningType,
      difficulty,
      concepts: concepts.join(','),
      sessionType: 'study_session',
    };

    // Upsert to Pinecone
    await this.index.upsert({
      upsertRequest: {
        vectors: [{
          id: sessionId,
          values: embedding,
          metadata,
        }],
      },
    });

    return { success: true, sessionId };
  }

  /**
   * Store learning content (notes, flashcards, etc.)
   */
  async storeContent(content) {
    await this.initialize();

    const {
      contentId,
      userId,
      type, // 'note', 'flashcard', 'summary', 'quiz'
      subject,
      topic,
      text,
      metadata: additionalMetadata = {}
    } = content;

    // Generate embedding
    const embedding = await this.generateEmbedding(text);

    // Prepare metadata
    const metadata = {
      userId,
      contentType: type,
      subject,
      topic,
      createdAt: new Date().toISOString(),
      ...additionalMetadata,
    };

    // Upsert to Pinecone
    await this.index.upsert({
      upsertRequest: {
        vectors: [{
          id: contentId,
          values: embedding,
          metadata,
        }],
      },
    });

    return { success: true, contentId };
  }

  /**
   * Find similar study patterns
   */
  async findSimilarStudyPatterns(query) {
    await this.initialize();

    const {
      learningType,
      subjects,
      userLevel,
      performanceThreshold = 0.7,
      limit = 10
    } = query;

    // Create query text
    const queryText = `Learning type: ${learningType}. Subjects: ${subjects.join(', ')}. Level: ${userLevel}.`;
    const queryEmbedding = await this.generateEmbedding(queryText);

    // Search with filters
    const results = await this.index.query({
      queryRequest: {
        vector: queryEmbedding,
        topK: limit,
        includeValues: false,
        includeMetadata: true,
        filter: {
          $and: [
            { sessionType: { $eq: 'study_session' } },
            { performance: { $gte: performanceThreshold } },
            { learningType: { $eq: learningType } },
          ],
        },
      },
    });

    // Process and return patterns
    return this.extractPatterns(results.matches);
  }

  /**
   * Find similar tasks for duration prediction
   */
  async findSimilarTasks(taskEmbedding, subject, limit = 20) {
    await this.initialize();

    const results = await this.index.query({
      queryRequest: {
        vector: taskEmbedding,
        topK: limit,
        includeMetadata: true,
        filter: {
          $and: [
            { contentType: { $eq: 'task' } },
            { subject: { $eq: subject } },
            { completed: { $eq: true } },
          ],
        },
      },
    });

    return results.matches.map(match => ({
      taskId: match.id,
      similarity: match.score,
      duration: match.metadata.actualDuration,
      difficulty: match.metadata.difficulty,
    }));
  }

  /**
   * Get personalized content recommendations
   */
  async getContentRecommendations(userId, context) {
    await this.initialize();

    const {
      currentSubject,
      recentPerformance,
      timeAvailable,
      energyLevel,
      learningGoals
    } = context;

    // Create context embedding
    const contextText = this.createContextText(context);
    const contextEmbedding = await this.generateEmbedding(contextText);

    // Search for relevant content
    const results = await this.index.query({
      queryRequest: {
        vector: contextEmbedding,
        topK: 20,
        includeMetadata: true,
        filter: {
          $or: [
            { userId: { $eq: userId } },
            { isPublic: { $eq: true } },
          ],
        },
      },
    });

    // Rank and filter recommendations
    return this.rankRecommendations(results.matches, context);
  }

  /**
   * Semantic search for study materials
   */
  async searchStudyMaterials(query, filters = {}) {
    await this.initialize();

    const {
      userId,
      subject,
      difficulty,
      contentTypes = ['note', 'flashcard', 'summary'],
      limit = 20
    } = filters;

    // Generate query embedding
    const queryEmbedding = await this.generateEmbedding(query);

    // Build filter
    const filter = {
      $and: [
        { contentType: { $in: contentTypes } },
      ],
    };

    if (userId) filter.$and.push({ userId: { $eq: userId } });
    if (subject) filter.$and.push({ subject: { $eq: subject } });
    if (difficulty) filter.$and.push({ difficulty: { $eq: difficulty } });

    // Search
    const results = await this.index.query({
      queryRequest: {
        vector: queryEmbedding,
        topK: limit,
        includeMetadata: true,
        filter,
      },
    });

    return results.matches.map(match => ({
      id: match.id,
      score: match.score,
      type: match.metadata.contentType,
      subject: match.metadata.subject,
      topic: match.metadata.topic,
      metadata: match.metadata,
    }));
  }

  /**
   * Store learning interactions for collaborative filtering
   */
  async storeInteraction(interaction) {
    await this.initialize();

    const {
      interactionId,
      userId,
      contentId,
      interactionType, // 'view', 'like', 'save', 'complete'
      duration,
      performance,
      timestamp
    } = interaction;

    // Get content to create interaction embedding
    const content = await this.getContent(contentId);
    if (!content) return { success: false, error: 'Content not found' };

    // Create interaction text
    const interactionText = `User ${userId} ${interactionType} content about ${content.topic} in ${content.subject}. Performance: ${performance}`;
    const embedding = await this.generateEmbedding(interactionText);

    // Store interaction
    await this.index.upsert({
      upsertRequest: {
        vectors: [{
          id: interactionId,
          values: embedding,
          metadata: {
            userId,
            contentId,
            interactionType,
            duration,
            performance,
            timestamp,
            contentSubject: content.subject,
            contentTopic: content.topic,
          },
        }],
      },
    });

    return { success: true, interactionId };
  }

  /**
   * Find study buddies with similar patterns
   */
  async findStudyBuddies(userId, preferences) {
    await this.initialize();

    const {
      subjects,
      studyTimes,
      learningType,
      performanceLevel,
      limit = 10
    } = preferences;

    // Get user's recent sessions
    const userSessions = await this.getUserRecentSessions(userId);
    if (userSessions.length === 0) {
      return [];
    }

    // Create user profile embedding
    const profileText = this.createUserProfileText(userSessions, preferences);
    const profileEmbedding = await this.generateEmbedding(profileText);

    // Search for similar user patterns
    const results = await this.index.query({
      queryRequest: {
        vector: profileEmbedding,
        topK: limit * 2, // Get more to filter
        includeMetadata: true,
        filter: {
          $and: [
            { sessionType: { $eq: 'study_session' } },
            { userId: { $ne: userId } }, // Exclude self
            { subject: { $in: subjects } },
          ],
        },
      },
    });

    // Group by user and calculate compatibility
    return this.calculateBuddyCompatibility(results.matches, preferences);
  }

  /**
   * Helper methods
   */
  createSessionText(session) {
    return `
      Subject: ${session.subject}
      Topic: ${session.topic}
      Concepts: ${session.concepts.join(', ')}
      Learning Type: ${session.learningType}
      Performance: ${session.performance}
      Difficulty: ${session.difficulty}
      Duration: ${session.duration} minutes
      Notes: ${session.notes || 'No notes'}
    `.trim();
  }

  createContextText(context) {
    return `
      Current subject: ${context.currentSubject}
      Recent performance: ${context.recentPerformance}
      Time available: ${context.timeAvailable} minutes
      Energy level: ${context.energyLevel}/10
      Learning goals: ${context.learningGoals.join(', ')}
    `.trim();
  }

  createUserProfileText(sessions, preferences) {
    const avgPerformance = sessions.reduce((sum, s) => sum + s.performance, 0) / sessions.length;
    const subjects = [...new Set(sessions.map(s => s.subject))];
    
    return `
      Learning type: ${preferences.learningType}
      Subjects: ${subjects.join(', ')}
      Average performance: ${avgPerformance}
      Preferred study times: ${preferences.studyTimes.join(', ')}
      Performance level: ${preferences.performanceLevel}
    `.trim();
  }

  extractPatterns(matches) {
    const patterns = {
      commonTopics: {},
      averageDuration: 0,
      averagePerformance: 0,
      bestTimeOfDay: {},
      effectiveTechniques: [],
    };

    let totalDuration = 0;
    let totalPerformance = 0;

    matches.forEach(match => {
      const metadata = match.metadata;
      
      // Topics
      if (metadata.topic) {
        patterns.commonTopics[metadata.topic] = (patterns.commonTopics[metadata.topic] || 0) + 1;
      }
      
      // Duration and performance
      totalDuration += metadata.duration || 0;
      totalPerformance += metadata.performance || 0;
      
      // Time of day
      const hour = new Date(metadata.timestamp).getHours();
      const timeSlot = this.getTimeSlot(hour);
      patterns.bestTimeOfDay[timeSlot] = (patterns.bestTimeOfDay[timeSlot] || 0) + 1;
    });

    patterns.averageDuration = totalDuration / matches.length;
    patterns.averagePerformance = totalPerformance / matches.length;

    return patterns;
  }

  rankRecommendations(matches, context) {
    return matches
      .map(match => {
        const metadata = match.metadata;
        let score = match.score;
        
        // Boost score based on context
        if (metadata.subject === context.currentSubject) score *= 1.2;
        if (metadata.difficulty === context.difficultyPreference) score *= 1.1;
        if (metadata.estimatedDuration <= context.timeAvailable) score *= 1.1;
        
        return {
          ...match,
          adjustedScore: score,
        };
      })
      .sort((a, b) => b.adjustedScore - a.adjustedScore)
      .slice(0, 10);
  }

  async getUserRecentSessions(userId, limit = 20) {
    const results = await this.index.query({
      queryRequest: {
        vector: new Array(EMBEDDING_DIMENSION).fill(0), // Dummy vector
        topK: limit,
        includeMetadata: true,
        filter: {
          $and: [
            { userId: { $eq: userId } },
            { sessionType: { $eq: 'study_session' } },
          ],
        },
      },
    });

    return results.matches.map(m => m.metadata);
  }

  calculateBuddyCompatibility(matches, preferences) {
    const userGroups = {};
    
    // Group sessions by user
    matches.forEach(match => {
      const userId = match.metadata.userId;
      if (!userGroups[userId]) {
        userGroups[userId] = [];
      }
      userGroups[userId].push(match);
    });

    // Calculate compatibility scores
    const buddies = Object.entries(userGroups).map(([buddyId, sessions]) => {
      let compatibilityScore = 0;
      
      // Similar performance levels
      const avgPerformance = sessions.reduce((sum, s) => sum + s.metadata.performance, 0) / sessions.length;
      compatibilityScore += 1 - Math.abs(avgPerformance - preferences.performanceLevel) / 100;
      
      // Similar study times
      const studyHours = sessions.map(s => new Date(s.metadata.timestamp).getHours());
      const timeOverlap = this.calculateTimeOverlap(studyHours, preferences.studyTimes);
      compatibilityScore += timeOverlap;
      
      // Subject overlap
      const subjects = [...new Set(sessions.map(s => s.metadata.subject))];
      const subjectOverlap = subjects.filter(s => preferences.subjects.includes(s)).length / preferences.subjects.length;
      compatibilityScore += subjectOverlap;
      
      return {
        userId: buddyId,
        compatibilityScore: compatibilityScore / 3, // Normalize
        commonSubjects: subjects.filter(s => preferences.subjects.includes(s)),
        averagePerformance: avgPerformance,
      };
    });

    return buddies
      .sort((a, b) => b.compatibilityScore - a.compatibilityScore)
      .slice(0, preferences.limit);
  }

  getTimeSlot(hour) {
    if (hour >= 5 && hour < 9) return 'early_morning';
    if (hour >= 9 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 15) return 'afternoon';
    if (hour >= 15 && hour < 18) return 'late_afternoon';
    if (hour >= 18 && hour < 21) return 'evening';
    return 'night';
  }

  calculateTimeOverlap(hours1, hours2) {
    const slots1 = new Set(hours1.map(h => this.getTimeSlot(h)));
    const slots2 = new Set(hours2.map(h => this.getTimeSlot(parseInt(h))));
    
    const intersection = [...slots1].filter(x => slots2.has(x));
    return intersection.length / Math.max(slots1.size, slots2.size);
  }

  async getContent(contentId) {
    // In production, this would fetch from a database
    // For now, return mock data
    return {
      id: contentId,
      subject: 'Mathematics',
      topic: 'Calculus',
    };
  }
}

module.exports = PineconeClient;