import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for managing learning ontology and knowledge relationships
class OntologyService {
  static final OntologyService _instance = OntologyService._internal();
  factory OntologyService() => _instance;
  OntologyService._internal();

  // Cache for ontology data
  final Map<String, LearningDomain> _domainCache = {};
  final Map<String, ConceptNode> _conceptCache = {};
  final Map<String, List<ConceptRelation>> _relationCache = {};

  /// Initialize ontology with predefined domains
  Future<void> initialize() async {
    try {
      // Load core learning domains
      await _loadCoreDomains();
      
      // Load concept relationships
      await _loadConceptRelations();
      
      safePrint('Ontology service initialized');
    } catch (e) {
      safePrint('Error initializing ontology: $e');
    }
  }

  /// Get learning domain by name
  LearningDomain? getDomain(String domainName) {
    return _domainCache[domainName.toLowerCase()];
  }

  /// Get concept by ID
  ConceptNode? getConcept(String conceptId) {
    return _conceptCache[conceptId];
  }

  /// Find concepts by subject
  List<ConceptNode> getConceptsBySubject(String subject) {
    return _conceptCache.values
        .where((concept) => concept.subject.toLowerCase() == subject.toLowerCase())
        .toList();
  }

  /// Get concept relationships
  List<ConceptRelation> getConceptRelations(String conceptId) {
    return _relationCache[conceptId] ?? [];
  }

  /// Find learning path between concepts
  Future<List<List<ConceptNode>>> findLearningPaths({
    required String fromConceptId,
    required String toConceptId,
    String? userId,
  }) async {
    try {
      // Call Lambda function to find paths using Neptune
      final response = await Amplify.API.post(
        '/learning-paths',
        apiName: 'aiTutorAPI',
        body: HttpPayload.json({
          'operation': 'findLearningPath',
          'userId': userId,
          'fromConcept': fromConceptId,
          'toConcept': toConceptId,
        }),
      ).response;

      if (response.body != null) {
        final paths = json.decode(response.body);
        return _parseLearningPaths(paths);
      }
      return [];
    } catch (e) {
      safePrint('Error finding learning paths: $e');
      return [];
    }
  }

  /// Get concept recommendations based on user progress
  Future<List<ConceptRecommendation>> getConceptRecommendations({
    required String userId,
    required String currentSubject,
    int limit = 5,
  }) async {
    try {
      final response = await Amplify.API.post(
        '/concept-recommendations',
        apiName: 'aiTutorAPI',
        body: HttpPayload.json({
          'operation': 'getConceptRecommendations',
          'userId': userId,
          'subject': currentSubject,
          'limit': limit,
        }),
      ).response;

      if (response.body != null) {
        final recommendations = json.decode(response.body);
        return _parseRecommendations(recommendations);
      }
      return [];
    } catch (e) {
      safePrint('Error getting concept recommendations: $e');
      return [];
    }
  }

  /// Track concept mastery
  Future<void> updateConceptMastery({
    required String userId,
    required String conceptId,
    required double performance,
    required int duration,
  }) async {
    try {
      await Amplify.API.post(
        '/concept-mastery',
        apiName: 'aiTutorAPI',
        body: HttpPayload.json({
          'operation': 'updateConceptMastery',
          'userId': userId,
          'conceptId': conceptId,
          'performance': performance,
          'duration': duration,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).response;
    } catch (e) {
      safePrint('Error updating concept mastery: $e');
    }
  }

  /// Get knowledge graph for a user
  Future<KnowledgeGraph?> getUserKnowledgeGraph(String userId) async {
    try {
      final response = await Amplify.API.post(
        '/knowledge-graph',
        apiName: 'aiTutorAPI',
        body: HttpPayload.json({
          'operation': 'getUserKnowledgeGraph',
          'userId': userId,
        }),
      ).response;

      if (response.body != null) {
        final graphData = json.decode(response.body);
        return _parseKnowledgeGraph(graphData);
      }
      return null;
    } catch (e) {
      safePrint('Error getting knowledge graph: $e');
      return null;
    }
  }

  /// Build concept hierarchy for a domain
  Map<String, List<ConceptNode>> buildConceptHierarchy(String domain) {
    final hierarchy = <String, List<ConceptNode>>{};
    final domainConcepts = getConceptsBySubject(domain);

    for (final concept in domainConcepts) {
      final level = concept.difficultyLevel.toString();
      hierarchy[level] ??= [];
      hierarchy[level]!.add(concept);
    }

    // Sort by prerequisites
    hierarchy.forEach((level, concepts) {
      concepts.sort((a, b) => a.prerequisites.length.compareTo(b.prerequisites.length));
    });

    return hierarchy;
  }

  /// Get concept difficulty based on prerequisites and relations
  double calculateConceptDifficulty(String conceptId) {
    final concept = getConcept(conceptId);
    if (concept == null) return 0.5;

    double difficulty = concept.difficultyLevel / 5.0;
    
    // Adjust based on prerequisites
    final prerequisites = concept.prerequisites.length;
    difficulty += prerequisites * 0.1;
    
    // Adjust based on relations
    final relations = getConceptRelations(conceptId);
    final complexRelations = relations.where((r) => 
      r.type == RelationType.requires || 
      r.type == RelationType.buildsupon
    ).length;
    difficulty += complexRelations * 0.05;

    return difficulty.clamp(0.0, 1.0);
  }

  /// Find related concepts
  List<ConceptNode> findRelatedConcepts(String conceptId, {int maxDepth = 2}) {
    final visited = <String>{};
    final related = <ConceptNode>[];
    
    _findRelatedRecursive(conceptId, visited, related, 0, maxDepth);
    
    return related;
  }

  void _findRelatedRecursive(
    String conceptId,
    Set<String> visited,
    List<ConceptNode> related,
    int currentDepth,
    int maxDepth,
  ) {
    if (currentDepth >= maxDepth || visited.contains(conceptId)) return;
    
    visited.add(conceptId);
    
    final relations = getConceptRelations(conceptId);
    for (final relation in relations) {
      final targetConcept = getConcept(relation.targetConceptId);
      if (targetConcept != null && !related.contains(targetConcept)) {
        related.add(targetConcept);
        _findRelatedRecursive(
          relation.targetConceptId,
          visited,
          related,
          currentDepth + 1,
          maxDepth,
        );
      }
    }
  }

  /// Load core learning domains
  Future<void> _loadCoreDomains() async {
    // Mathematics domain
    _domainCache['mathematics'] = LearningDomain(
      id: 'math',
      name: 'Mathematics',
      description: 'Mathematical concepts and problem solving',
      subdomains: [
        'Algebra',
        'Geometry',
        'Calculus',
        'Statistics',
        'Number Theory',
      ],
      color: Colors.blue,
      icon: Icons.calculate,
    );

    // Science domain
    _domainCache['science'] = LearningDomain(
      id: 'science',
      name: 'Science',
      description: 'Natural sciences and scientific method',
      subdomains: [
        'Physics',
        'Chemistry',
        'Biology',
        'Earth Science',
        'Astronomy',
      ],
      color: Colors.green,
      icon: Icons.science,
    );

    // Language domain
    _domainCache['language'] = LearningDomain(
      id: 'language',
      name: 'Language',
      description: 'Language learning and communication',
      subdomains: [
        'Grammar',
        'Vocabulary',
        'Writing',
        'Reading Comprehension',
        'Speaking',
      ],
      color: Colors.orange,
      icon: Icons.language,
    );

    // Add more domains as needed
  }

  /// Load concept relationships
  Future<void> _loadConceptRelations() async {
    // Example concept relationships
    // In production, these would be loaded from Neptune
    
    // Math concepts
    _conceptCache['algebra_basics'] = ConceptNode(
      id: 'algebra_basics',
      name: 'Algebra Basics',
      description: 'Introduction to algebraic thinking',
      subject: 'Mathematics',
      difficultyLevel: 1,
      prerequisites: [],
      learningObjectives: [
        'Understand variables',
        'Solve simple equations',
        'Work with expressions',
      ],
    );

    _conceptCache['linear_equations'] = ConceptNode(
      id: 'linear_equations',
      name: 'Linear Equations',
      description: 'Solving and graphing linear equations',
      subject: 'Mathematics',
      difficultyLevel: 2,
      prerequisites: ['algebra_basics'],
      learningObjectives: [
        'Solve linear equations',
        'Graph linear functions',
        'Find slope and intercepts',
      ],
    );

    // Add relationships
    _relationCache['algebra_basics'] = [
      ConceptRelation(
        sourceConceptId: 'algebra_basics',
        targetConceptId: 'linear_equations',
        type: RelationType.prerequisite,
        strength: 1.0,
      ),
    ];
  }

  /// Parse learning paths from API response
  List<List<ConceptNode>> _parseLearningPaths(dynamic pathsData) {
    final paths = <List<ConceptNode>>[];
    
    for (final pathData in pathsData) {
      final path = <ConceptNode>[];
      for (final conceptName in pathData) {
        final concept = _conceptCache.values.firstWhere(
          (c) => c.name == conceptName,
          orElse: () => ConceptNode(
            id: conceptName.toLowerCase().replaceAll(' ', '_'),
            name: conceptName,
            description: '',
            subject: 'General',
            difficultyLevel: 1,
            prerequisites: [],
            learningObjectives: [],
          ),
        );
        path.add(concept);
      }
      paths.add(path);
    }
    
    return paths;
  }

  /// Parse concept recommendations
  List<ConceptRecommendation> _parseRecommendations(dynamic data) {
    final recommendations = <ConceptRecommendation>[];
    
    if (data is Map) {
      data.forEach((conceptName, count) {
        final concept = _conceptCache.values.firstWhere(
          (c) => c.name == conceptName,
          orElse: () => ConceptNode(
            id: conceptName.toLowerCase().replaceAll(' ', '_'),
            name: conceptName,
            description: '',
            subject: 'General',
            difficultyLevel: 1,
            prerequisites: [],
            learningObjectives: [],
          ),
        );
        
        recommendations.add(ConceptRecommendation(
          concept: concept,
          relevanceScore: count.toDouble() / 10,
          reason: 'Based on your learning history',
        ));
      });
    }
    
    return recommendations;
  }

  /// Parse knowledge graph data
  KnowledgeGraph _parseKnowledgeGraph(Map<String, dynamic> data) {
    final nodes = <KnowledgeNode>[];
    final edges = <KnowledgeEdge>[];
    
    // Parse concept nodes with mastery
    final concepts = data['concepts'] as Map<String, dynamic>? ?? {};
    concepts.forEach((conceptName, mastery) {
      nodes.add(KnowledgeNode(
        id: conceptName.toLowerCase().replaceAll(' ', '_'),
        label: conceptName,
        mastery: mastery.toDouble(),
        type: 'concept',
      ));
    });
    
    // Parse relationships
    final relationships = data['relationships'] as List? ?? [];
    for (final rel in relationships) {
      edges.add(KnowledgeEdge(
        source: rel['source'],
        target: rel['target'],
        type: rel['edge']['label'] ?? 'related',
        weight: rel['edge']['strength']?.toDouble() ?? 1.0,
      ));
    }
    
    return KnowledgeGraph(nodes: nodes, edges: edges);
  }
}

// Data models
class LearningDomain {
  final String id;
  final String name;
  final String description;
  final List<String> subdomains;
  final Color color;
  final IconData icon;

  LearningDomain({
    required this.id,
    required this.name,
    required this.description,
    required this.subdomains,
    required this.color,
    required this.icon,
  });
}

class ConceptNode {
  final String id;
  final String name;
  final String description;
  final String subject;
  final int difficultyLevel; // 1-5
  final List<String> prerequisites;
  final List<String> learningObjectives;

  ConceptNode({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.difficultyLevel,
    required this.prerequisites,
    required this.learningObjectives,
  });
}

class ConceptRelation {
  final String sourceConceptId;
  final String targetConceptId;
  final RelationType type;
  final double strength; // 0-1

  ConceptRelation({
    required this.sourceConceptId,
    required this.targetConceptId,
    required this.type,
    required this.strength,
  });
}

enum RelationType {
  prerequisite,
  related,
  buildsupon,
  requires,
  alternative,
}

class ConceptRecommendation {
  final ConceptNode concept;
  final double relevanceScore;
  final String reason;

  ConceptRecommendation({
    required this.concept,
    required this.relevanceScore,
    required this.reason,
  });
}

class KnowledgeGraph {
  final List<KnowledgeNode> nodes;
  final List<KnowledgeEdge> edges;

  KnowledgeGraph({
    required this.nodes,
    required this.edges,
  });
}

class KnowledgeNode {
  final String id;
  final String label;
  final double mastery;
  final String type;

  KnowledgeNode({
    required this.id,
    required this.label,
    required this.mastery,
    required this.type,
  });
}

class KnowledgeEdge {
  final String source;
  final String target;
  final String type;
  final double weight;

  KnowledgeEdge({
    required this.source,
    required this.target,
    required this.type,
    required this.weight,
  });
}