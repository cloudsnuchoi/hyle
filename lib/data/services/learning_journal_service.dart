import 'dart:async';
import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

/// Service for managing learning journal and reflections
class LearningJournalService {
  static final LearningJournalService _instance = LearningJournalService._internal();
  factory LearningJournalService() => _instance;
  LearningJournalService._internal();

  // Journal entry storage
  final Map<String, List<JournalEntry>> _userJournals = {};
  final Map<String, StreamController<JournalUpdate>> _updateControllers = {};
  
  // Reflection prompts
  final Map<String, List<ReflectionPrompt>> _reflectionPrompts = {};
  
  /// Create a new journal entry
  Future<JournalEntry> createEntry({
    required String userId,
    required String title,
    required String content,
    required JournalEntryType type,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    List<String>? attachmentIds,
  }) async {
    try {
      final entry = JournalEntry(
        id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        title: title,
        content: content,
        type: type,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: tags ?? [],
        metadata: metadata ?? {},
        attachmentIds: attachmentIds ?? [],
        wordCount: _countWords(content),
      );

      // Store entry
      _userJournals[userId] ??= [];
      _userJournals[userId]!.add(entry);

      // Extract and store insights
      final insights = await _extractInsights(entry);
      entry.insights = insights;

      // Generate AI summary if needed
      if (content.length > 500) {
        entry.aiSummary = await _generateSummary(content);
      }

      // Analyze sentiment
      entry.sentiment = await _analyzeSentiment(content);

      // Emit update
      _emitUpdate(userId, JournalUpdate(
        type: JournalUpdateType.entryCreated,
        entry: entry,
        timestamp: DateTime.now(),
      ));

      // Check for streak
      await _updateJournalStreak(userId);

      return entry;
    } catch (e) {
      safePrint('Error creating journal entry: $e');
      rethrow;
    }
  }

  /// Update existing journal entry
  Future<JournalEntry> updateEntry({
    required String userId,
    required String entryId,
    String? title,
    String? content,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final entries = _userJournals[userId];
      if (entries == null) {
        throw Exception('No journal found for user');
      }

      final entryIndex = entries.indexWhere((e) => e.id == entryId);
      if (entryIndex == -1) {
        throw Exception('Entry not found');
      }

      final entry = entries[entryIndex];
      
      // Update fields
      if (title != null) entry.title = title;
      if (content != null) {
        entry.content = content;
        entry.wordCount = _countWords(content);
        
        // Re-analyze content
        entry.insights = await _extractInsights(entry);
        if (content.length > 500) {
          entry.aiSummary = await _generateSummary(content);
        }
        entry.sentiment = await _analyzeSentiment(content);
      }
      if (tags != null) entry.tags = tags;
      if (metadata != null) entry.metadata.addAll(metadata);
      
      entry.updatedAt = DateTime.now();
      entry.editCount++;

      // Emit update
      _emitUpdate(userId, JournalUpdate(
        type: JournalUpdateType.entryUpdated,
        entry: entry,
        timestamp: DateTime.now(),
      ));

      return entry;
    } catch (e) {
      safePrint('Error updating journal entry: $e');
      rethrow;
    }
  }

  /// Get journal entries with filtering
  Future<List<JournalEntry>> getEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    JournalEntryType? type,
    List<String>? tags,
    SentimentType? sentiment,
    String? searchQuery,
    int? limit,
  }) async {
    try {
      var entries = _userJournals[userId] ?? [];

      // Apply filters
      if (startDate != null) {
        entries = entries.where((e) => e.createdAt.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        entries = entries.where((e) => e.createdAt.isBefore(endDate)).toList();
      }
      if (type != null) {
        entries = entries.where((e) => e.type == type).toList();
      }
      if (tags != null && tags.isNotEmpty) {
        entries = entries.where((e) => 
          tags.any((tag) => e.tags.contains(tag))
        ).toList();
      }
      if (sentiment != null) {
        entries = entries.where((e) => e.sentiment == sentiment).toList();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        entries = entries.where((e) =>
          e.title.toLowerCase().contains(query) ||
          e.content.toLowerCase().contains(query) ||
          e.tags.any((tag) => tag.toLowerCase().contains(query))
        ).toList();
      }

      // Sort by creation date (newest first)
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Apply limit
      if (limit != null && entries.length > limit) {
        entries = entries.take(limit).toList();
      }

      return entries;
    } catch (e) {
      safePrint('Error getting journal entries: $e');
      rethrow;
    }
  }

  /// Get reflection prompts for user
  Future<List<ReflectionPrompt>> getReflectionPrompts({
    required String userId,
    required PromptContext context,
  }) async {
    try {
      // Get user's learning context
      final userContext = await _getUserLearningContext(userId);
      
      // Generate personalized prompts
      final prompts = <ReflectionPrompt>[];
      
      // Daily reflection prompts
      if (context == PromptContext.daily) {
        prompts.addAll([
          ReflectionPrompt(
            id: 'daily_achievement',
            prompt: '오늘 가장 자랑스러운 학습 성취는 무엇인가요?',
            category: PromptCategory.achievement,
            followUpQuestions: [
              '이 성취를 이루기 위해 어떤 노력을 했나요?',
              '다음에는 어떻게 더 발전시킬 수 있을까요?',
            ],
          ),
          ReflectionPrompt(
            id: 'daily_challenge',
            prompt: '오늘 직면한 가장 큰 학습 도전은 무엇이었나요?',
            category: PromptCategory.challenge,
            followUpQuestions: [
              '이 도전을 어떻게 극복했나요?',
              '이 경험에서 무엇을 배웠나요?',
            ],
          ),
          ReflectionPrompt(
            id: 'daily_insight',
            prompt: '오늘 학습하면서 얻은 새로운 통찰은 무엇인가요?',
            category: PromptCategory.insight,
            followUpQuestions: [
              '이 통찰이 앞으로의 학습에 어떤 영향을 줄까요?',
              '이를 실제로 어떻게 적용할 수 있을까요?',
            ],
          ),
        ]);
      }
      
      // Weekly reflection prompts
      else if (context == PromptContext.weekly) {
        prompts.addAll([
          ReflectionPrompt(
            id: 'weekly_progress',
            prompt: '이번 주 학습 목표 달성도를 평가해보세요.',
            category: PromptCategory.progress,
            followUpQuestions: [
              '목표를 달성했다면 성공 요인은 무엇인가요?',
              '목표를 달성하지 못했다면 개선점은 무엇인가요?',
            ],
          ),
          ReflectionPrompt(
            id: 'weekly_patterns',
            prompt: '이번 주 학습 패턴에서 발견한 것은 무엇인가요?',
            category: PromptCategory.pattern,
            followUpQuestions: [
              '가장 효과적이었던 학습 시간대는 언제인가요?',
              '어떤 학습 방법이 가장 도움이 되었나요?',
            ],
          ),
        ]);
      }
      
      // Subject-specific prompts
      if (userContext.currentSubject != null) {
        prompts.add(ReflectionPrompt(
          id: 'subject_understanding',
          prompt: '${userContext.currentSubject}에 대한 이해도가 어떻게 변화했나요?',
          category: PromptCategory.subject,
          metadata: {'subject': userContext.currentSubject},
        ));
      }
      
      // Milestone prompts
      if (userContext.recentMilestone != null) {
        prompts.add(ReflectionPrompt(
          id: 'milestone_reflection',
          prompt: '${userContext.recentMilestone} 달성을 축하합니다! 이 순간을 기록해보세요.',
          category: PromptCategory.milestone,
          metadata: {'milestone': userContext.recentMilestone},
        ));
      }

      return prompts;
    } catch (e) {
      safePrint('Error getting reflection prompts: $e');
      rethrow;
    }
  }

  /// Generate journal insights report
  Future<JournalInsightsReport> generateInsightsReport({
    required String userId,
    required DateTimeRange period,
  }) async {
    try {
      final entries = await getEntries(
        userId: userId,
        startDate: period.start,
        endDate: period.end,
      );

      // Analyze journal patterns
      final patterns = _analyzeJournalPatterns(entries);
      
      // Track sentiment trends
      final sentimentTrends = _analyzeSentimentTrends(entries);
      
      // Identify recurring themes
      final themes = _identifyThemes(entries);
      
      // Calculate writing statistics
      final stats = _calculateWritingStats(entries, period);
      
      // Extract key insights
      final keyInsights = _extractKeyInsights(entries);
      
      // Generate growth indicators
      final growthIndicators = _analyzeGrowthIndicators(entries);
      
      // Create word cloud data
      final wordCloudData = _generateWordCloudData(entries);
      
      return JournalInsightsReport(
        userId: userId,
        period: period,
        totalEntries: entries.length,
        patterns: patterns,
        sentimentTrends: sentimentTrends,
        recurringThemes: themes,
        writingStats: stats,
        keyInsights: keyInsights,
        growthIndicators: growthIndicators,
        wordCloudData: wordCloudData,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      safePrint('Error generating insights report: $e');
      rethrow;
    }
  }

  /// Export journal entries
  Future<String> exportJournal({
    required String userId,
    required ExportFormat format,
    DateTimeRange? period,
    bool includeInsights = true,
    bool includeAttachments = false,
  }) async {
    try {
      final entries = await getEntries(
        userId: userId,
        startDate: period?.start,
        endDate: period?.end,
      );

      switch (format) {
        case ExportFormat.markdown:
          return _exportAsMarkdown(entries, includeInsights);
          
        case ExportFormat.json:
          return _exportAsJson(entries, includeInsights, includeAttachments);
          
        case ExportFormat.pdf:
          return await _exportAsPdf(entries, includeInsights);
          
        case ExportFormat.html:
          return _exportAsHtml(entries, includeInsights);
      }
    } catch (e) {
      safePrint('Error exporting journal: $e');
      rethrow;
    }
  }

  /// Get journal statistics
  Future<JournalStatistics> getStatistics({
    required String userId,
    DateTimeRange? period,
  }) async {
    try {
      final entries = await getEntries(
        userId: userId,
        startDate: period?.start,
        endDate: period?.end,
      );

      final now = DateTime.now();
      final stats = JournalStatistics(
        totalEntries: entries.length,
        totalWords: entries.fold(0, (sum, e) => sum + e.wordCount),
        averageWordsPerEntry: entries.isEmpty ? 0 : 
          entries.fold(0, (sum, e) => sum + e.wordCount) ~/ entries.length,
        entriesByType: _countEntriesByType(entries),
        entriesBySentiment: _countEntriesBySentiment(entries),
        topTags: _getTopTags(entries),
        writingStreak: await _getWritingStreak(userId),
        lastEntryDate: entries.isEmpty ? null : entries.first.createdAt,
        mostProductiveDay: _findMostProductiveDay(entries),
        averageEntriesPerWeek: _calculateAverageEntriesPerWeek(entries, period),
      );

      return stats;
    } catch (e) {
      safePrint('Error getting journal statistics: $e');
      rethrow;
    }
  }

  /// Search journal with AI
  Future<List<JournalSearchResult>> searchWithAI({
    required String userId,
    required String query,
    SearchIntent? intent,
  }) async {
    try {
      final entries = _userJournals[userId] ?? [];
      final results = <JournalSearchResult>[];

      // Determine search intent if not provided
      intent ??= _determineSearchIntent(query);

      // Perform semantic search
      for (final entry in entries) {
        final relevance = await _calculateRelevance(entry, query, intent);
        
        if (relevance > 0.5) {
          // Extract relevant snippets
          final snippets = _extractRelevantSnippets(entry.content, query);
          
          results.add(JournalSearchResult(
            entry: entry,
            relevanceScore: relevance,
            matchedSnippets: snippets,
            matchedTags: entry.tags.where((tag) => 
              tag.toLowerCase().contains(query.toLowerCase())
            ).toList(),
            searchIntent: intent,
          ));
        }
      }

      // Sort by relevance
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));

      return results;
    } catch (e) {
      safePrint('Error searching journal with AI: $e');
      rethrow;
    }
  }

  /// Get journal recommendations
  Future<List<JournalRecommendation>> getRecommendations({
    required String userId,
    required RecommendationType type,
  }) async {
    try {
      final recommendations = <JournalRecommendation>[];
      final entries = _userJournals[userId] ?? [];
      
      switch (type) {
        case RecommendationType.continueWriting:
          // Find entries that could be expanded
          final incompleteEntries = entries.where((e) => 
            e.wordCount < 100 || 
            e.metadata['incomplete'] == true
          ).toList();
          
          for (final entry in incompleteEntries.take(3)) {
            recommendations.add(JournalRecommendation(
              type: type,
              title: '계속 작성하기: ${entry.title}',
              description: '이 항목을 더 자세히 작성해보세요',
              actionData: {'entryId': entry.id},
              priority: 0.8,
            ));
          }
          break;
          
        case RecommendationType.reflectOnProgress:
          // Check if it's time for periodic reflection
          final lastReflection = entries
              .where((e) => e.type == JournalEntryType.reflection)
              .firstOrNull;
          
          if (lastReflection == null || 
              DateTime.now().difference(lastReflection.createdAt).inDays > 7) {
            recommendations.add(JournalRecommendation(
              type: type,
              title: '주간 학습 돌아보기',
              description: '이번 주 학습을 정리하고 다음 주를 계획해보세요',
              actionData: {'promptType': 'weekly_reflection'},
              priority: 0.9,
            ));
          }
          break;
          
        case RecommendationType.exploreTheme:
          // Suggest exploring recurring themes
          final themes = _identifyThemes(entries);
          for (final theme in themes.take(2)) {
            recommendations.add(JournalRecommendation(
              type: type,
              title: '${theme.name} 더 깊이 탐구하기',
              description: '이 주제에 대한 생각을 더 발전시켜보세요',
              actionData: {'theme': theme.name, 'relatedEntries': theme.entryIds},
              priority: 0.7,
            ));
          }
          break;
          
        case RecommendationType.reviewOldEntries:
          // Suggest reviewing old entries
          final oldEntries = entries
              .where((e) => DateTime.now().difference(e.createdAt).inDays > 30)
              .toList();
          
          if (oldEntries.isNotEmpty) {
            final randomOld = oldEntries[
              DateTime.now().millisecondsSinceEpoch % oldEntries.length
            ];
            
            recommendations.add(JournalRecommendation(
              type: type,
              title: '과거 기록 돌아보기',
              description: '한 달 전 작성한 "${randomOld.title}"를 다시 읽어보세요',
              actionData: {'entryId': randomOld.id},
              priority: 0.6,
            ));
          }
          break;
      }
      
      // Sort by priority
      recommendations.sort((a, b) => b.priority.compareTo(a.priority));
      
      return recommendations;
    } catch (e) {
      safePrint('Error getting journal recommendations: $e');
      rethrow;
    }
  }

  // Private helper methods
  int _countWords(String text) {
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  Future<List<String>> _extractInsights(JournalEntry entry) async {
    // Simulate insight extraction
    final insights = <String>[];
    
    // Check for learning breakthroughs
    if (entry.content.contains('이해했') || entry.content.contains('깨달았')) {
      insights.add('학습 돌파구 발견');
    }
    
    // Check for challenges
    if (entry.content.contains('어려웠') || entry.content.contains('힘들었')) {
      insights.add('도전 과제 직면');
    }
    
    // Check for goals
    if (entry.content.contains('목표') || entry.content.contains('계획')) {
      insights.add('목표 설정');
    }
    
    return insights;
  }

  Future<String> _generateSummary(String content) async {
    // Simulate AI summary generation
    final sentences = content.split('. ');
    if (sentences.length <= 3) return content;
    
    // Take first and last sentences as simple summary
    return '${sentences.first}... ${sentences.last}';
  }

  Future<SentimentType> _analyzeSentiment(String content) async {
    // Simple sentiment analysis simulation
    final positiveWords = ['좋았', '성공', '달성', '기쁘', '만족', '행복'];
    final negativeWords = ['어려웠', '실패', '힘들', '걱정', '불안', '스트레스'];
    
    int positiveCount = 0;
    int negativeCount = 0;
    
    for (final word in positiveWords) {
      if (content.contains(word)) positiveCount++;
    }
    
    for (final word in negativeWords) {
      if (content.contains(word)) negativeCount++;
    }
    
    if (positiveCount > negativeCount) return SentimentType.positive;
    if (negativeCount > positiveCount) return SentimentType.negative;
    return SentimentType.neutral;
  }

  void _emitUpdate(String userId, JournalUpdate update) {
    _updateControllers[userId]?.add(update);
  }

  Future<void> _updateJournalStreak(String userId) async {
    // Implementation for updating journal writing streak
  }

  Future<_UserLearningContext> _getUserLearningContext(String userId) async {
    // Simulate getting user context
    return _UserLearningContext(
      currentSubject: 'Mathematics',
      recentMilestone: null,
    );
  }

  List<JournalPattern> _analyzeJournalPatterns(List<JournalEntry> entries) {
    // Implementation for pattern analysis
    return [];
  }

  List<SentimentTrend> _analyzeSentimentTrends(List<JournalEntry> entries) {
    final trends = <SentimentTrend>[];
    
    // Group by week
    final weeklyGroups = <String, List<JournalEntry>>{};
    for (final entry in entries) {
      final weekKey = '${entry.createdAt.year}-${entry.createdAt.weekOfYear}';
      weeklyGroups[weekKey] ??= [];
      weeklyGroups[weekKey]!.add(entry);
    }
    
    // Calculate sentiment for each week
    weeklyGroups.forEach((week, entries) {
      int positive = 0, negative = 0, neutral = 0;
      
      for (final entry in entries) {
        switch (entry.sentiment) {
          case SentimentType.positive:
            positive++;
            break;
          case SentimentType.negative:
            negative++;
            break;
          case SentimentType.neutral:
            neutral++;
            break;
          default:
            neutral++;
        }
      }
      
      trends.add(SentimentTrend(
        period: week,
        positiveRatio: positive / entries.length,
        negativeRatio: negative / entries.length,
        neutralRatio: neutral / entries.length,
        dominantSentiment: positive > negative 
            ? SentimentType.positive 
            : (negative > positive ? SentimentType.negative : SentimentType.neutral),
      ));
    });
    
    return trends;
  }

  List<Theme> _identifyThemes(List<JournalEntry> entries) {
    // Simple theme identification
    final themeMap = <String, Set<String>>{};
    
    for (final entry in entries) {
      for (final tag in entry.tags) {
        themeMap[tag] ??= {};
        themeMap[tag]!.add(entry.id);
      }
    }
    
    return themeMap.entries
        .where((e) => e.value.length >= 3) // At least 3 entries
        .map((e) => Theme(
          name: e.key,
          frequency: e.value.length,
          entryIds: e.value.toList(),
        ))
        .toList()
      ..sort((a, b) => b.frequency.compareTo(a.frequency));
  }

  WritingStatistics _calculateWritingStats(
    List<JournalEntry> entries,
    DateTimeRange period,
  ) {
    if (entries.isEmpty) {
      return WritingStatistics(
        totalWords: 0,
        averageWordsPerEntry: 0,
        averageEntriesPerWeek: 0,
        longestEntry: null,
        shortestEntry: null,
      );
    }
    
    final totalWords = entries.fold(0, (sum, e) => sum + e.wordCount);
    final weeks = period.duration.inDays / 7;
    
    entries.sort((a, b) => b.wordCount.compareTo(a.wordCount));
    
    return WritingStatistics(
      totalWords: totalWords,
      averageWordsPerEntry: totalWords ~/ entries.length,
      averageEntriesPerWeek: entries.length / weeks,
      longestEntry: entries.first,
      shortestEntry: entries.last,
    );
  }

  List<String> _extractKeyInsights(List<JournalEntry> entries) {
    final insights = <String>[];
    
    // Count insights across all entries
    final insightCounts = <String, int>{};
    for (final entry in entries) {
      for (final insight in entry.insights ?? []) {
        insightCounts[insight] = (insightCounts[insight] ?? 0) + 1;
      }
    }
    
    // Return top insights
    final sortedInsights = insightCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedInsights
        .take(5)
        .map((e) => '${e.key} (${e.value}회)')
        .toList();
  }

  List<GrowthIndicator> _analyzeGrowthIndicators(List<JournalEntry> entries) {
    // Implementation for growth analysis
    return [];
  }

  Map<String, double> _generateWordCloudData(List<JournalEntry> entries) {
    final wordCounts = <String, int>{};
    
    for (final entry in entries) {
      final words = entry.content
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((w) => w.length > 3); // Filter short words
      
      for (final word in words) {
        wordCounts[word] = (wordCounts[word] ?? 0) + 1;
      }
    }
    
    // Convert to frequencies and take top 50
    final totalWords = wordCounts.values.fold(0, (a, b) => a + b);
    final wordFrequencies = <String, double>{};
    
    wordCounts.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(50)
      ..forEach((e) {
        wordFrequencies[e.key] = e.value / totalWords;
      });
    
    return wordFrequencies;
  }

  String _exportAsMarkdown(List<JournalEntry> entries, bool includeInsights) {
    final buffer = StringBuffer();
    
    buffer.writeln('# 학습 일지');
    buffer.writeln();
    
    for (final entry in entries) {
      buffer.writeln('## ${entry.title}');
      buffer.writeln('*${entry.createdAt.toString().split('.').first}*');
      buffer.writeln();
      buffer.writeln(entry.content);
      
      if (includeInsights && entry.insights != null && entry.insights!.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('### 인사이트');
        for (final insight in entry.insights!) {
          buffer.writeln('- $insight');
        }
      }
      
      if (entry.tags.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('태그: ${entry.tags.join(', ')}');
      }
      
      buffer.writeln();
      buffer.writeln('---');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  String _exportAsJson(
    List<JournalEntry> entries,
    bool includeInsights,
    bool includeAttachments,
  ) {
    final data = entries.map((e) => {
      'id': e.id,
      'title': e.title,
      'content': e.content,
      'type': e.type.toString(),
      'createdAt': e.createdAt.toIso8601String(),
      'updatedAt': e.updatedAt.toIso8601String(),
      'tags': e.tags,
      'wordCount': e.wordCount,
      'sentiment': e.sentiment?.toString(),
      if (includeInsights) 'insights': e.insights,
      if (includeInsights) 'aiSummary': e.aiSummary,
      if (includeAttachments) 'attachmentIds': e.attachmentIds,
    }).toList();
    
    return jsonEncode(data);
  }

  Future<String> _exportAsPdf(List<JournalEntry> entries, bool includeInsights) async {
    // Simulate PDF export - would use actual PDF library in production
    return 'PDF export path';
  }

  String _exportAsHtml(List<JournalEntry> entries, bool includeInsights) {
    final buffer = StringBuffer();
    
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html><head><title>학습 일지</title></head><body>');
    buffer.writeln('<h1>학습 일지</h1>');
    
    for (final entry in entries) {
      buffer.writeln('<article>');
      buffer.writeln('<h2>${entry.title}</h2>');
      buffer.writeln('<time>${entry.createdAt}</time>');
      buffer.writeln('<p>${entry.content.replaceAll('\n', '<br>')}</p>');
      
      if (includeInsights && entry.insights != null) {
        buffer.writeln('<h3>인사이트</h3><ul>');
        for (final insight in entry.insights!) {
          buffer.writeln('<li>$insight</li>');
        }
        buffer.writeln('</ul>');
      }
      
      buffer.writeln('</article><hr>');
    }
    
    buffer.writeln('</body></html>');
    return buffer.toString();
  }

  // Additional helper method stubs...
  Map<JournalEntryType, int> _countEntriesByType(List<JournalEntry> entries) => {};
  Map<SentimentType, int> _countEntriesBySentiment(List<JournalEntry> entries) => {};
  List<String> _getTopTags(List<JournalEntry> entries) => [];
  Future<int> _getWritingStreak(String userId) async => 0;
  String _findMostProductiveDay(List<JournalEntry> entries) => '';
  double _calculateAverageEntriesPerWeek(
    List<JournalEntry> entries,
    DateTimeRange? period,
  ) => 0.0;
  
  SearchIntent _determineSearchIntent(String query) => SearchIntent.general;
  Future<double> _calculateRelevance(
    JournalEntry entry,
    String query,
    SearchIntent intent,
  ) async => 0.0;
  List<String> _extractRelevantSnippets(String content, String query) => [];
}

// Data models
class JournalEntry {
  final String id;
  final String userId;
  String title;
  String content;
  final JournalEntryType type;
  final DateTime createdAt;
  DateTime updatedAt;
  List<String> tags;
  final Map<String, dynamic> metadata;
  final List<String> attachmentIds;
  int wordCount;
  List<String>? insights;
  String? aiSummary;
  SentimentType? sentiment;
  int editCount = 0;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.metadata,
    required this.attachmentIds,
    required this.wordCount,
    this.insights,
    this.aiSummary,
    this.sentiment,
  });
}

class ReflectionPrompt {
  final String id;
  final String prompt;
  final PromptCategory category;
  final List<String>? followUpQuestions;
  final Map<String, dynamic>? metadata;

  ReflectionPrompt({
    required this.id,
    required this.prompt,
    required this.category,
    this.followUpQuestions,
    this.metadata,
  });
}

class JournalUpdate {
  final JournalUpdateType type;
  final JournalEntry? entry;
  final DateTime timestamp;

  JournalUpdate({
    required this.type,
    this.entry,
    required this.timestamp,
  });
}

class JournalInsightsReport {
  final String userId;
  final DateTimeRange period;
  final int totalEntries;
  final List<JournalPattern> patterns;
  final List<SentimentTrend> sentimentTrends;
  final List<Theme> recurringThemes;
  final WritingStatistics writingStats;
  final List<String> keyInsights;
  final List<GrowthIndicator> growthIndicators;
  final Map<String, double> wordCloudData;
  final DateTime generatedAt;

  JournalInsightsReport({
    required this.userId,
    required this.period,
    required this.totalEntries,
    required this.patterns,
    required this.sentimentTrends,
    required this.recurringThemes,
    required this.writingStats,
    required this.keyInsights,
    required this.growthIndicators,
    required this.wordCloudData,
    required this.generatedAt,
  });
}

class JournalStatistics {
  final int totalEntries;
  final int totalWords;
  final int averageWordsPerEntry;
  final Map<JournalEntryType, int> entriesByType;
  final Map<SentimentType, int> entriesBySentiment;
  final List<String> topTags;
  final int writingStreak;
  final DateTime? lastEntryDate;
  final String mostProductiveDay;
  final double averageEntriesPerWeek;

  JournalStatistics({
    required this.totalEntries,
    required this.totalWords,
    required this.averageWordsPerEntry,
    required this.entriesByType,
    required this.entriesBySentiment,
    required this.topTags,
    required this.writingStreak,
    this.lastEntryDate,
    required this.mostProductiveDay,
    required this.averageEntriesPerWeek,
  });
}

class JournalSearchResult {
  final JournalEntry entry;
  final double relevanceScore;
  final List<String> matchedSnippets;
  final List<String> matchedTags;
  final SearchIntent searchIntent;

  JournalSearchResult({
    required this.entry,
    required this.relevanceScore,
    required this.matchedSnippets,
    required this.matchedTags,
    required this.searchIntent,
  });
}

class JournalRecommendation {
  final RecommendationType type;
  final String title;
  final String description;
  final Map<String, dynamic> actionData;
  final double priority;

  JournalRecommendation({
    required this.type,
    required this.title,
    required this.description,
    required this.actionData,
    required this.priority,
  });
}

class JournalPattern {
  final String name;
  final String description;
  final double frequency;
  final List<String> examples;

  JournalPattern({
    required this.name,
    required this.description,
    required this.frequency,
    required this.examples,
  });
}

class SentimentTrend {
  final String period;
  final double positiveRatio;
  final double negativeRatio;
  final double neutralRatio;
  final SentimentType dominantSentiment;

  SentimentTrend({
    required this.period,
    required this.positiveRatio,
    required this.negativeRatio,
    required this.neutralRatio,
    required this.dominantSentiment,
  });
}

class Theme {
  final String name;
  final int frequency;
  final List<String> entryIds;

  Theme({
    required this.name,
    required this.frequency,
    required this.entryIds,
  });
}

class WritingStatistics {
  final int totalWords;
  final int averageWordsPerEntry;
  final double averageEntriesPerWeek;
  final JournalEntry? longestEntry;
  final JournalEntry? shortestEntry;

  WritingStatistics({
    required this.totalWords,
    required this.averageWordsPerEntry,
    required this.averageEntriesPerWeek,
    this.longestEntry,
    this.shortestEntry,
  });
}

class GrowthIndicator {
  final String metric;
  final double value;
  final double change;
  final String trend;

  GrowthIndicator({
    required this.metric,
    required this.value,
    required this.change,
    required this.trend,
  });
}

// Enums
enum JournalEntryType {
  dailyReflection,
  learningNote,
  goalSetting,
  problemSolving,
  ideaCapture,
  emotionalProcessing,
  milestone,
  reflection,
  planning,
  review,
}

enum SentimentType {
  positive,
  negative,
  neutral,
  mixed,
}

enum PromptContext {
  daily,
  weekly,
  monthly,
  milestone,
  challenge,
  achievement,
}

enum PromptCategory {
  achievement,
  challenge,
  insight,
  progress,
  pattern,
  subject,
  milestone,
  emotion,
  planning,
}

enum ExportFormat {
  markdown,
  json,
  pdf,
  html,
}

enum RecommendationType {
  continueWriting,
  reflectOnProgress,
  exploreTheme,
  reviewOldEntries,
}

enum SearchIntent {
  general,
  findSolution,
  trackProgress,
  reviewEmotions,
  findInsights,
}

enum JournalUpdateType {
  entryCreated,
  entryUpdated,
  entryDeleted,
  insightAdded,
}

// Private helper classes
class _UserLearningContext {
  final String? currentSubject;
  final String? recentMilestone;

  _UserLearningContext({
    this.currentSubject,
    this.recentMilestone,
  });
}

// Extension for week of year
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay = difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}