const gremlin = require('gremlin');
const DriverRemoteConnection = gremlin.driver.DriverRemoteConnection;
const Graph = gremlin.structure.Graph;
const P = gremlin.process.P;
const __ = gremlin.process.statics;

// Neptune connection configuration
const NEPTUNE_ENDPOINT = process.env.NEPTUNE_ENDPOINT;
const NEPTUNE_PORT = process.env.NEPTUNE_PORT || '8182';

class NeptuneClient {
  constructor() {
    this.dc = new DriverRemoteConnection(
      `wss://${NEPTUNE_ENDPOINT}:${NEPTUNE_PORT}/gremlin`,
      {}
    );
    this.graph = new Graph();
    this.g = this.graph.traversal().withRemote(this.dc);
  }

  /**
   * Create or update user learning profile in knowledge graph
   */
  async createUserProfile(userId, learningType, preferences) {
    try {
      // Create user vertex if not exists
      await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .fold()
        .coalesce(
          __.unfold(),
          __.addV('User')
            .property('userId', userId)
            .property('learningType', learningType)
            .property('createdAt', new Date().toISOString())
        )
        .property('learningType', learningType)
        .property('updatedAt', new Date().toISOString())
        .iterate();

      // Add learning preferences
      for (const [key, value] of Object.entries(preferences)) {
        await this.g.V()
          .hasLabel('User')
          .has('userId', userId)
          .property(key, value)
          .iterate();
      }

      return { success: true };
    } catch (error) {
      console.error('Error creating user profile:', error);
      throw error;
    }
  }

  /**
   * Create knowledge relationships between concepts
   */
  async createConceptRelationship(concept1, concept2, relationshipType, strength = 1.0) {
    try {
      // Ensure concepts exist
      const concepts = [concept1, concept2];
      for (const concept of concepts) {
        await this.g.V()
          .hasLabel('Concept')
          .has('name', concept)
          .fold()
          .coalesce(
            __.unfold(),
            __.addV('Concept')
              .property('name', concept)
              .property('domain', this.extractDomain(concept))
          )
          .iterate();
      }

      // Create relationship
      await this.g.V()
        .hasLabel('Concept')
        .has('name', concept1)
        .as('c1')
        .V()
        .hasLabel('Concept')
        .has('name', concept2)
        .as('c2')
        .coalesce(
          __.inE(relationshipType).where(__.outV().as('c1')),
          __.addE(relationshipType).from('c1').to('c2')
        )
        .property('strength', strength)
        .property('updatedAt', new Date().toISOString())
        .iterate();

      return { success: true };
    } catch (error) {
      console.error('Error creating concept relationship:', error);
      throw error;
    }
  }

  /**
   * Track user's learning journey
   */
  async trackLearningActivity(userId, activity) {
    const { conceptId, activityType, duration, performance, timestamp } = activity;

    try {
      // Create activity vertex
      const activityVertex = await this.g.addV('Activity')
        .property('activityId', `${userId}-${timestamp}`)
        .property('type', activityType)
        .property('duration', duration)
        .property('performance', performance)
        .property('timestamp', timestamp)
        .next();

      // Connect user to activity
      await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .addE('PERFORMED')
        .to(__.V(activityVertex.value))
        .iterate();

      // Connect activity to concept
      await this.g.V(activityVertex.value)
        .addE('RELATED_TO')
        .to(__.V().hasLabel('Concept').has('conceptId', conceptId))
        .iterate();

      // Update user's mastery of concept
      await this.updateConceptMastery(userId, conceptId, performance);

      return { success: true, activityId: activityVertex.value };
    } catch (error) {
      console.error('Error tracking learning activity:', error);
      throw error;
    }
  }

  /**
   * Get user's knowledge graph
   */
  async getUserKnowledgeGraph(userId) {
    try {
      // Get all concepts user has interacted with
      const concepts = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('PERFORMED')
        .out('RELATED_TO')
        .hasLabel('Concept')
        .group()
        .by('name')
        .by(__.values('mastery').mean())
        .toList();

      // Get relationships between concepts
      const relationships = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('PERFORMED')
        .out('RELATED_TO')
        .hasLabel('Concept')
        .as('source')
        .outE()
        .as('edge')
        .inV()
        .as('target')
        .select('source', 'edge', 'target')
        .by('name')
        .by(__.valueMap())
        .by('name')
        .toList();

      return {
        concepts: concepts[0] || {},
        relationships: relationships
      };
    } catch (error) {
      console.error('Error getting user knowledge graph:', error);
      throw error;
    }
  }

  /**
   * Find learning paths between concepts
   */
  async findLearningPath(userId, fromConcept, toConcept) {
    try {
      // Find shortest path considering user's mastery
      const paths = await this.g.V()
        .hasLabel('Concept')
        .has('name', fromConcept)
        .repeat(
          __.outE().inV()
            .simplePath()
        )
        .until(__.has('name', toConcept))
        .limit(5)
        .path()
        .by('name')
        .toList();

      // Score paths based on user's current knowledge
      const scoredPaths = await Promise.all(
        paths.map(async (path) => {
          const score = await this.scorePathForUser(userId, path);
          return { path, score };
        })
      );

      // Sort by score
      scoredPaths.sort((a, b) => b.score - a.score);

      return scoredPaths.map(sp => sp.path);
    } catch (error) {
      console.error('Error finding learning path:', error);
      throw error;
    }
  }

  /**
   * Get concept recommendations based on user's learning graph
   */
  async getConceptRecommendations(userId, limit = 5) {
    try {
      // Get user's mastered concepts
      const masteredConcepts = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('MASTERED')
        .values('name')
        .toList();

      // Find related concepts not yet mastered
      const recommendations = await this.g.V()
        .hasLabel('Concept')
        .where(__.has('name', P.within(...masteredConcepts)))
        .out()
        .hasLabel('Concept')
        .where(__.not(__.has('name', P.within(...masteredConcepts))))
        .group()
        .by('name')
        .by(__.count())
        .order()
        .by(__.values, gremlin.process.order.desc)
        .limit(limit)
        .toList();

      return recommendations[0] || {};
    } catch (error) {
      console.error('Error getting concept recommendations:', error);
      throw error;
    }
  }

  /**
   * Analyze learning patterns
   */
  async analyzeLearningPatterns(userId) {
    try {
      // Time-based patterns
      const timePatterns = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('PERFORMED')
        .group()
        .by(__.values('timestamp').map(t => new Date(t).getHours()))
        .by(__.values('performance').mean())
        .toList();

      // Concept difficulty patterns
      const difficultyPatterns = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('PERFORMED')
        .out('RELATED_TO')
        .group()
        .by('difficulty')
        .by(__.in('RELATED_TO').values('performance').mean())
        .toList();

      // Learning velocity by domain
      const velocityPatterns = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('PERFORMED')
        .out('RELATED_TO')
        .group()
        .by('domain')
        .by(__.count())
        .toList();

      return {
        timePatterns: timePatterns[0] || {},
        difficultyPatterns: difficultyPatterns[0] || {},
        velocityPatterns: velocityPatterns[0] || {}
      };
    } catch (error) {
      console.error('Error analyzing learning patterns:', error);
      throw error;
    }
  }

  /**
   * Find similar learners
   */
  async findSimilarLearners(userId, limit = 10) {
    try {
      // Get user's concept interactions
      const userConcepts = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('PERFORMED')
        .out('RELATED_TO')
        .values('name')
        .toList();

      // Find users with similar concept interactions
      const similarUsers = await this.g.V()
        .hasLabel('Concept')
        .where(__.has('name', P.within(...userConcepts)))
        .in('RELATED_TO')
        .in('PERFORMED')
        .hasLabel('User')
        .where(__.not(__.has('userId', userId)))
        .group()
        .by('userId')
        .by(__.count())
        .order()
        .by(__.values, gremlin.process.order.desc)
        .limit(limit)
        .toList();

      return similarUsers[0] || {};
    } catch (error) {
      console.error('Error finding similar learners:', error);
      throw error;
    }
  }

  /**
   * Build domain ontology
   */
  async buildDomainOntology(domain, concepts) {
    try {
      // Create domain vertex
      await this.g.V()
        .hasLabel('Domain')
        .has('name', domain)
        .fold()
        .coalesce(
          __.unfold(),
          __.addV('Domain').property('name', domain)
        )
        .iterate();

      // Add concepts to domain
      for (const concept of concepts) {
        await this.g.V()
          .hasLabel('Concept')
          .has('name', concept.name)
          .fold()
          .coalesce(
            __.unfold(),
            __.addV('Concept')
              .property('name', concept.name)
              .property('difficulty', concept.difficulty || 'medium')
              .property('description', concept.description || '')
          )
          .as('concept')
          .V()
          .hasLabel('Domain')
          .has('name', domain)
          .addE('BELONGS_TO')
          .from('concept')
          .iterate();

        // Add prerequisites
        if (concept.prerequisites) {
          for (const prereq of concept.prerequisites) {
            await this.createConceptRelationship(
              prereq,
              concept.name,
              'PREREQUISITE_OF',
              1.0
            );
          }
        }
      }

      return { success: true };
    } catch (error) {
      console.error('Error building domain ontology:', error);
      throw error;
    }
  }

  /**
   * Helper methods
   */
  async updateConceptMastery(userId, conceptId, performance) {
    const masteryThreshold = 0.8;
    
    // Calculate new mastery score
    const currentMastery = await this.g.V()
      .hasLabel('User')
      .has('userId', userId)
      .out('STUDIES')
      .hasLabel('Concept')
      .has('conceptId', conceptId)
      .values('mastery')
      .fold()
      .coalesce(__.unfold(), __.constant(0))
      .next();

    const newMastery = currentMastery.value * 0.7 + performance * 0.3;

    // Update or create STUDIES edge
    await this.g.V()
      .hasLabel('User')
      .has('userId', userId)
      .as('user')
      .V()
      .hasLabel('Concept')
      .has('conceptId', conceptId)
      .as('concept')
      .coalesce(
        __.inE('STUDIES').where(__.outV().as('user')),
        __.addE('STUDIES').from('user').to('concept')
      )
      .property('mastery', newMastery)
      .property('lastStudied', new Date().toISOString())
      .iterate();

    // Add MASTERED edge if threshold reached
    if (newMastery >= masteryThreshold && currentMastery.value < masteryThreshold) {
      await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .as('user')
        .V()
        .hasLabel('Concept')
        .has('conceptId', conceptId)
        .addE('MASTERED')
        .from('user')
        .property('achievedAt', new Date().toISOString())
        .iterate();
    }
  }

  extractDomain(conceptName) {
    // Simple domain extraction - in production, use NLP
    const domains = {
      'calculus': 'mathematics',
      'algebra': 'mathematics',
      'grammar': 'english',
      'vocabulary': 'english',
      'physics': 'science',
      'chemistry': 'science',
      'history': 'social_studies'
    };

    for (const [keyword, domain] of Object.entries(domains)) {
      if (conceptName.toLowerCase().includes(keyword)) {
        return domain;
      }
    }

    return 'general';
  }

  async scorePathForUser(userId, path) {
    // Score based on user's mastery of concepts in path
    let score = 0;
    for (const concept of path) {
      const mastery = await this.g.V()
        .hasLabel('User')
        .has('userId', userId)
        .out('STUDIES')
        .has('name', concept)
        .values('mastery')
        .fold()
        .coalesce(__.unfold(), __.constant(0))
        .next();
      
      score += mastery.value;
    }
    return score / path.length;
  }

  async close() {
    await this.dc.close();
  }
}

module.exports = NeptuneClient;