const NeptuneClient = require('./neptune-client');

// Environment variables
const NEPTUNE_ENDPOINT = process.env.NEPTUNE_ENDPOINT;

/**
 * Lambda function for executing graph queries on Neptune
 */
exports.handler = async (event) => {
  console.log('Event:', JSON.stringify(event, null, 2));
  
  const { operation, arguments } = event;
  const neptuneClient = new NeptuneClient();
  
  try {
    switch (operation) {
      case 'createUserProfile':
        return await neptuneClient.createUserProfile(
          arguments.userId,
          arguments.learningType,
          arguments.preferences
        );
        
      case 'createConceptRelationship':
        return await neptuneClient.createConceptRelationship(
          arguments.concept1,
          arguments.concept2,
          arguments.relationshipType,
          arguments.strength
        );
        
      case 'trackLearningActivity':
        return await neptuneClient.trackLearningActivity(
          arguments.userId,
          arguments.activity
        );
        
      case 'getUserKnowledgeGraph':
        return await neptuneClient.getUserKnowledgeGraph(arguments.userId);
        
      case 'findLearningPath':
        return await neptuneClient.findLearningPath(
          arguments.userId,
          arguments.fromConcept,
          arguments.toConcept
        );
        
      case 'getConceptRecommendations':
        return await neptuneClient.getConceptRecommendations(
          arguments.userId,
          arguments.limit
        );
        
      case 'analyzeLearningPatterns':
        return await neptuneClient.analyzeLearningPatterns(arguments.userId);
        
      case 'findSimilarLearners':
        return await neptuneClient.findSimilarLearners(
          arguments.userId,
          arguments.limit
        );
        
      case 'buildDomainOntology':
        return await neptuneClient.buildDomainOntology(
          arguments.domain,
          arguments.concepts
        );
        
      case 'executeCustomQuery':
        return await executeCustomQuery(neptuneClient, arguments);
        
      default:
        throw new Error(`Unknown operation: ${operation}`);
    }
  } catch (error) {
    console.error('Error:', error);
    throw error;
  } finally {
    await neptuneClient.close();
  }
};

/**
 * Execute custom Gremlin query
 */
async function executeCustomQuery(neptuneClient, { query, bindings }) {
  try {
    // Validate query for safety
    if (!isQuerySafe(query)) {
      throw new Error('Query contains potentially unsafe operations');
    }
    
    // Execute query with bindings
    const results = await neptuneClient.g
      .inject(query)
      .withBindings(bindings || {})
      .toList();
    
    return {
      results,
      count: results.length,
    };
  } catch (error) {
    console.error('Error executing custom query:', error);
    throw error;
  }
}

/**
 * Basic query safety validation
 */
function isQuerySafe(query) {
  // Disallow drop operations
  if (query.toLowerCase().includes('drop')) return false;
  
  // Disallow system operations
  if (query.includes('system')) return false;
  
  // Add more validation as needed
  return true;
}

/**
 * Batch operations for efficiency
 */
async function batchCreateConcepts(neptuneClient, concepts) {
  const results = [];
  
  // Process in batches of 100
  const batchSize = 100;
  for (let i = 0; i < concepts.length; i += batchSize) {
    const batch = concepts.slice(i, i + batchSize);
    
    const batchPromises = batch.map(concept => 
      neptuneClient.g.V()
        .hasLabel('Concept')
        .has('name', concept.name)
        .fold()
        .coalesce(
          __.unfold(),
          __.addV('Concept')
            .property('name', concept.name)
            .property('domain', concept.domain)
            .property('difficulty', concept.difficulty)
        )
        .iterate()
    );
    
    await Promise.all(batchPromises);
    results.push(...batch.map(c => ({ name: c.name, status: 'created' })));
  }
  
  return results;
}

/**
 * Complex graph algorithms
 */
async function findCommunities(neptuneClient, userId) {
  try {
    // Find communities of learners with similar patterns
    const communities = await neptuneClient.g.V()
      .hasLabel('User')
      .has('userId', userId)
      .as('user')
      .out('PERFORMED')
      .out('RELATED_TO')
      .in('RELATED_TO')
      .in('PERFORMED')
      .hasLabel('User')
      .where(__.not(__.as('user')))
      .group()
      .by('userId')
      .by(__.count())
      .order()
      .by(__.values, gremlin.process.order.desc)
      .limit(20)
      .toList();
    
    return communities;
  } catch (error) {
    console.error('Error finding communities:', error);
    throw error;
  }
}

async function calculatePageRank(neptuneClient, conceptDomain) {
  try {
    // Simple PageRank-like calculation for concept importance
    const iterations = 3;
    let ranks = {};
    
    // Get all concepts in domain
    const concepts = await neptuneClient.g.V()
      .hasLabel('Concept')
      .has('domain', conceptDomain)
      .values('name')
      .toList();
    
    // Initialize ranks
    concepts.forEach(concept => {
      ranks[concept] = 1.0 / concepts.length;
    });
    
    // Iterate PageRank
    for (let i = 0; i < iterations; i++) {
      const newRanks = {};
      
      for (const concept of concepts) {
        // Get incoming connections
        const incoming = await neptuneClient.g.V()
          .hasLabel('Concept')
          .has('name', concept)
          .in()
          .values('name')
          .toList();
        
        let rank = 0.15 / concepts.length; // Damping factor
        
        for (const source of incoming) {
          const outDegree = await neptuneClient.g.V()
            .hasLabel('Concept')
            .has('name', source)
            .out()
            .count()
            .next();
          
          rank += 0.85 * ranks[source] / outDegree.value;
        }
        
        newRanks[concept] = rank;
      }
      
      ranks = newRanks;
    }
    
    // Sort by rank
    const sortedConcepts = Object.entries(ranks)
      .sort((a, b) => b[1] - a[1])
      .map(([concept, rank]) => ({ concept, importance: rank }));
    
    return sortedConcepts;
  } catch (error) {
    console.error('Error calculating PageRank:', error);
    throw error;
  }
}

async function detectLearningCycles(neptuneClient, userId) {
  try {
    // Detect cyclic learning patterns
    const cycles = await neptuneClient.g.V()
      .hasLabel('User')
      .has('userId', userId)
      .out('PERFORMED')
      .out('RELATED_TO')
      .as('start')
      .repeat(__.out().simplePath())
      .until(__.as('start'))
      .path()
      .by('name')
      .limit(10)
      .toList();
    
    return cycles.map(cycle => ({
      cycle: cycle,
      length: cycle.length,
      type: categorizeCycle(cycle),
    }));
  } catch (error) {
    console.error('Error detecting learning cycles:', error);
    throw error;
  }
}

function categorizeCycle(cycle) {
  if (cycle.length <= 3) return 'short';
  if (cycle.length <= 5) return 'medium';
  return 'long';
}

module.exports = { 
  handler,
  batchCreateConcepts,
  findCommunities,
  calculatePageRank,
  detectLearningCycles,
};