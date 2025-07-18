import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/local_ai_simulation_service.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/learning_type_provider.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: '안녕하세요! AI 학습 도우미입니다. 🤖\n\n무엇을 도와드릴까요?\n• 학습 질문하기\n• 학습 계획 세우기\n• 실수 패턴 분석\n• 노트를 플래시카드로 변환',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 학습 도우미'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'analyze',
                child: Text('학습 분석 요청'),
              ),
              const PopupMenuItem(
                value: 'plan',
                child: Text('학습 계획 생성'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('대화 초기화'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Actions
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.paddingMD,
              children: [
                _buildQuickAction(
                  '학습 추천',
                  Icons.lightbulb,
                  Colors.orange,
                  () => _requestRecommendations(),
                ),
                _buildQuickAction(
                  '성과 분석',
                  Icons.analytics,
                  Colors.blue,
                  () => _requestPerformanceAnalysis(),
                ),
                _buildQuickAction(
                  '실수 패턴',
                  Icons.warning,
                  Colors.red,
                  () => _requestMistakeAnalysis(),
                ),
                _buildQuickAction(
                  '학습 계획',
                  Icons.calendar_today,
                  Colors.green,
                  () => _requestStudyPlan(),
                ),
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: AppSpacing.paddingMD,
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          
          // Input Area
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '질문을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                AppSpacing.horizontalGapMD,
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ActionChip(
        avatar: Icon(icon, color: color, size: 20),
        label: Text(label),
        onPressed: onTap,
        backgroundColor: color.withOpacity(0.1),
      ),
    );
  }
  
  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            AppSpacing.horizontalGapMD,
          ],
          Flexible(
            child: Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: message.isUser 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTypography.body.copyWith(
                      color: message.isUser ? Colors.white : Colors.black,
                    ),
                  ),
                  if (message.actions != null) ...[
                    AppSpacing.verticalGapMD,
                    ...message.actions!.map((action) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: TextButton(
                        onPressed: action.onPressed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(action.label),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            AppSpacing.horizontalGapMD,
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.smart_toy, color: Colors.white),
          ),
          AppSpacing.horizontalGapMD,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildDot(0),
                AppSpacing.horizontalGapSM,
                _buildDot(1),
                AppSpacing.horizontalGapSM,
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade400.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (_isTyping) {
          setState(() {});
        }
      },
    );
  }
  
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    // Get AI response
    final response = await LocalAISimulationService.getAITutorResponse(text);
    
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
  }
  
  void _requestRecommendations() async {
    setState(() {
      _messages.add(ChatMessage(
        text: '학습 추천을 요청합니다.',
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    final userStats = ref.read(userStatsProvider);
    final mainSubject = userStats.subjectStats.entries.isEmpty 
      ? 'General' 
      : userStats.subjectStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    final recommendations = await LocalAISimulationService.getLearningRecommendations(mainSubject);
    
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: '$mainSubject 과목 학습을 위한 추천사항입니다:\n\n' + 
              recommendations.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n'),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
  }
  
  void _requestPerformanceAnalysis() async {
    setState(() {
      _messages.add(ChatMessage(
        text: '내 학습 성과를 분석해주세요.',
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    final userStats = ref.read(userStatsProvider);
    final analysis = await LocalAISimulationService.analyzePerformance(userStats.subjectStats);
    
    final insights = analysis['insights'] as List<String>;
    final suggestions = analysis['suggestions'] as List<String>;
    
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: '📊 학습 성과 분석 결과\n\n' +
              '**가장 많이 학습한 과목**: ${analysis['strongestSubject']}\n' +
              '**더 관심이 필요한 과목**: ${analysis['weakestSubject']}\n' +
              '**총 학습 시간**: ${analysis['totalStudyTime']}분\n\n' +
              '**인사이트**:\n' + insights.map((i) => '• $i').join('\n') + '\n\n' +
              '**제안사항**:\n' + suggestions.map((s) => '• $s').join('\n'),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
  }
  
  void _requestMistakeAnalysis() async {
    setState(() {
      _messages.add(ChatMessage(
        text: '자주 하는 실수 패턴을 분석해주세요.',
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    // Simulate getting the most studied subject
    final userStats = ref.read(userStatsProvider);
    final mainSubject = userStats.subjectStats.entries.isEmpty 
      ? 'Math' 
      : userStats.subjectStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    final mistakes = await LocalAISimulationService.analyzeMistakes(mainSubject);
    
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: '🔍 $mainSubject 과목 실수 패턴 분석\n\n' +
              mistakes.map((m) => 
                '**${m.type}** (${(m.frequency * 100).toInt()}%)\n' +
                '📌 ${m.description}\n' +
                '💡 ${m.solution}\n'
              ).join('\n'),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
  }
  
  void _requestStudyPlan() async {
    setState(() {
      _messages.add(ChatMessage(
        text: '맞춤형 학습 계획을 만들어주세요.',
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _scrollToBottom();
    
    final learningType = ref.read(currentLearningTypeProvider);
    final userStats = ref.read(userStatsProvider);
    final subjects = userStats.subjectStats.keys.toList();
    
    if (subjects.isEmpty) {
      subjects.addAll(['Math', 'English', 'Science']);
    }
    
    final plan = await LocalAISimulationService.generateStudyPlan(
      learningType?.toString() ?? 'General',
      subjects,
    );
    
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: '📅 ${plan.title}\n\n${plan.description}\n\n' +
              '**이번 주 학습 일정**:\n' +
              plan.sessions.take(10).map((s) => 
                '• ${_formatDate(s.date)} ${s.time} - ${s.subject} (${s.duration}분)\n' +
                '  집중: ${s.focus}'
              ).join('\n') + '\n\n' +
              '**학습 팁**:\n' + plan.tips.map((t) => '• $t').join('\n'),
        isUser: false,
        timestamp: DateTime.now(),
        actions: [
          MessageAction(
            label: '계획 저장하기',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('학습 계획이 저장되었습니다')),
              );
            },
          ),
        ],
      ));
    });
    
    _scrollToBottom();
  }
  
  void _handleMenuSelection(String value) {
    switch (value) {
      case 'analyze':
        _requestPerformanceAnalysis();
        break;
      case 'plan':
        _requestStudyPlan();
        break;
      case 'clear':
        setState(() {
          _messages.clear();
          _addWelcomeMessage();
        });
        break;
    }
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${date.month}/${date.day}(${weekdays[date.weekday - 1]})';
  }
}

// Models
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<MessageAction>? actions;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actions,
  });
}

class MessageAction {
  final String label;
  final VoidCallback onPressed;
  
  MessageAction({
    required this.label,
    required this.onPressed,
  });
}