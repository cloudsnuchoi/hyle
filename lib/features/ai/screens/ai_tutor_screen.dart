import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 채팅 세션 모델
class ChatSession {
  final String id;
  final String title;
  final String subject;
  final DateTime lastMessage;
  final List<ChatMessage> messages;
  final ChatContext currentContext; // 현재 대화 컨텍스트

  ChatSession({
    required this.id,
    required this.title,
    required this.subject,
    required this.lastMessage,
    required this.messages,
    this.currentContext = ChatContext.general,
  });
}

// 대화 컨텍스트 (AI가 자동 감지)
enum ChatContext {
  general,    // 일반 대화
  learning,   // 학습 관련
  analysis,   // 분석 요청
  summary,    // 요약 요청
  emotional,  // 정서적 지원
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatContext? detectedContext; // AI가 감지한 컨텍스트

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.detectedContext,
  });
}

class AITutorScreen extends ConsumerStatefulWidget {
  const AITutorScreen({super.key});

  @override
  ConsumerState<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends ConsumerState<AITutorScreen> 
    with TickerProviderStateMixin {
  
  // UI 상태
  String _selectedSubject = '전체';
  ChatSession? _currentSession;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showTools = false; // 도구 표시 여부 (AI가 자동 결정)
  
  // 애니메이션
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _toolsController;
  late Animation<double> _toolsAnimation;
  
  // 더미 데이터 - 실제로는 백엔드에서 가져옴
  final List<ChatSession> _sessions = [
    ChatSession(
      id: '1',
      title: '수학 이차방정식 질문',
      subject: '수학',
      lastMessage: DateTime.now().subtract(const Duration(hours: 2)),
      currentContext: ChatContext.learning,
      messages: [
        ChatMessage(
          id: '1',
          content: '이차방정식 해를 구하는 방법 알려주세요',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          detectedContext: ChatContext.learning,
        ),
        ChatMessage(
          id: '2',
          content: '이차방정식 ax² + bx + c = 0의 해를 구하는 방법은 여러 가지가 있습니다:\n\n1. 인수분해법\n2. 완전제곱식\n3. 근의 공식\n\n가장 일반적인 근의 공식은 x = (-b ± √(b²-4ac)) / 2a 입니다.',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          detectedContext: ChatContext.learning,
        ),
      ],
    ),
    ChatSession(
      id: '2',
      title: '영어 문법 공부',
      subject: '영어',
      lastMessage: DateTime.now().subtract(const Duration(hours: 5)),
      messages: [],
    ),
    ChatSession(
      id: '3',
      title: '국어 비문학 독해',
      subject: '국어',
      lastMessage: DateTime.now().subtract(const Duration(days: 1)),
      currentContext: ChatContext.analysis,
      messages: [],
    ),
    ChatSession(
      id: '4',
      title: '오늘 학습 내용',
      subject: '전체',
      lastMessage: DateTime.now().subtract(const Duration(days: 1)),
      currentContext: ChatContext.summary,
      messages: [],
    ),
    ChatSession(
      id: '5',
      title: '과학 실험 질문',
      subject: '과학',
      lastMessage: DateTime.now().subtract(const Duration(days: 2)),
      messages: [],
    ),
  ];

  // 빠른 시작 프롬프트
  final List<Map<String, dynamic>> _quickPrompts = [
    {'icon': Icons.calculate, 'text': '수학 문제 풀이', 'subject': '수학'},
    {'icon': Icons.translate, 'text': '영어 번역/문법', 'subject': '영어'},
    {'icon': Icons.menu_book, 'text': '국어 독해 분석', 'subject': '국어'},
    {'icon': Icons.science, 'text': '과학 개념 설명', 'subject': '과학'},
    {'icon': Icons.public, 'text': '사회 시사 토론', 'subject': '사회'},
    {'icon': Icons.history_edu, 'text': '역사 사건 정리', 'subject': '한국사'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _toolsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _toolsAnimation = CurvedAnimation(
      parent: _toolsController,
      curve: Curves.easeInOut,
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _toolsController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 필터링된 세션 목록
  List<ChatSession> get _filteredSessions {
    return _sessions.where((session) {
      return _selectedSubject == '전체' || session.subject == _selectedSubject;
    }).toList()
      ..sort((a, b) => b.lastMessage.compareTo(a.lastMessage));
  }

  // AI가 메시지 컨텍스트 자동 감지
  ChatContext _detectContext(String message) {
    final lowerMessage = message.toLowerCase();
    
    // 학습 관련 키워드
    if (lowerMessage.contains('문제') || lowerMessage.contains('풀이') || 
        lowerMessage.contains('공식') || lowerMessage.contains('설명') ||
        lowerMessage.contains('가르쳐') || lowerMessage.contains('알려')) {
      return ChatContext.learning;
    }
    
    // 분석 관련 키워드
    if (lowerMessage.contains('분석') || lowerMessage.contains('왜') || 
        lowerMessage.contains('이유') || lowerMessage.contains('원인')) {
      return ChatContext.analysis;
    }
    
    // 요약 관련 키워드
    if (lowerMessage.contains('요약') || lowerMessage.contains('정리') || 
        lowerMessage.contains('핵심')) {
      return ChatContext.summary;
    }
    
    // 감정 관련 키워드
    if (lowerMessage.contains('힘들') || lowerMessage.contains('스트레스') || 
        lowerMessage.contains('우울') || lowerMessage.contains('걱정')) {
      return ChatContext.emotional;
    }
    
    return ChatContext.general;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F3FA),
              Color(0xFFD5DEEF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _currentSession == null 
                  ? _buildSessionList()
                  : _buildChatView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentSession != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _currentSession = null;
                      _showTools = false;
                    });
                  },
                )
              else
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSession?.title ?? 'AI 학습 도우미',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF395886),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_currentSession != null && _currentSession!.currentContext != ChatContext.general)
                      Text(
                        _getContextLabel(_currentSession!.currentContext),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              if (_currentSession == null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: const Color(0xFF638ECB),
                  onPressed: _showNewChatDialog,
                ),
            ],
          ),
          if (_currentSession == null) ...[
            const SizedBox(height: 12),
            _buildSubjectFilter(),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectFilter() {
    final subjects = ['전체', '수학', '영어', '국어', '과학', '사회', '한국사', '기타'];
    
    return SizedBox(
      height: 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isSelected = _selectedSubject == subject;
          
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == subjects.length - 1 ? 0 : 4,
            ),
            child: FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSubject = subject;
                });
              },
              selectedColor: _getSubjectColor(subject).withValues(alpha: 0.2),
              checkmarkColor: _getSubjectColor(subject),
              labelStyle: TextStyle(
                color: isSelected ? _getSubjectColor(subject) : const Color(0xFF525252),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionList() {
    if (_filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '대화를 시작해보세요',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            // 빠른 시작 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _quickPrompts.map((prompt) => 
                  _buildQuickStartButton(prompt)
                ).toList(),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // 빠른 시작 섹션
          if (_filteredSessions.length < 3)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickPrompts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildQuickStartCard(_quickPrompts[index]),
                  );
                },
              ),
            ),
          
          // 대화 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredSessions.length,
              itemBuilder: (context, index) {
                final session = _filteredSessions[index];
                return _buildSessionCard(session);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartButton(Map<String, dynamic> prompt) {
    return ElevatedButton.icon(
      onPressed: () => _startNewChat(prompt['subject'], prompt['text']),
      icon: Icon(prompt['icon'], size: 18),
      label: Text(prompt['text']),
      style: ElevatedButton.styleFrom(
        backgroundColor: _getSubjectColor(prompt['subject']).withValues(alpha: 0.1),
        foregroundColor: _getSubjectColor(prompt['subject']),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _getSubjectColor(prompt['subject']).withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStartCard(Map<String, dynamic> prompt) {
    return GestureDetector(
      onTap: () => _startNewChat(prompt['subject'], prompt['text']),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSubjectColor(prompt['subject']).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              prompt['icon'],
              color: _getSubjectColor(prompt['subject']),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              prompt['text'],
              style: TextStyle(
                fontSize: 12,
                color: _getSubjectColor(prompt['subject']),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(ChatSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentSession = session;
            // 학습 컨텍스트면 도구 표시
            if (session.currentContext == ChatContext.learning) {
              _showTools = true;
              _toolsController.forward();
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getSubjectColor(session.subject).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getContextIcon(session.currentContext),
                  color: _getSubjectColor(session.subject),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF262626),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSubjectColor(session.subject).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            session.subject,
                            style: TextStyle(
                              fontSize: 12,
                              color: _getSubjectColor(session.subject),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTimeAgo(session.lastMessage),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF737373),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF737373),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // 동적 도구 바 (필요시 표시)
        if (_showTools)
          FadeTransition(
            opacity: _toolsAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildToolButton(Icons.calculate, '계산기'),
                  _buildToolButton(Icons.draw, '그리기'),
                  _buildToolButton(Icons.image, '이미지'),
                  _buildToolButton(Icons.format_shapes, '수식'),
                  _buildToolButton(Icons.book, '참고자료'),
                ],
              ),
            ),
          ),
        
        Expanded(
          child: _buildMessageList(),
        ),
        
        _buildInputArea(),
      ],
    );
  }

  Widget _buildToolButton(IconData icon, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon),
            onPressed: () {},
            color: const Color(0xFF638ECB),
            iconSize: 20,
            padding: EdgeInsets.zero,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF525252),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_currentSession!.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '무엇이든 물어보세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI가 자동으로 맥락을 파악하여 도와드립니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _currentSession!.messages.length,
      itemBuilder: (context, index) {
        final message = _currentSession!.messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.isUser 
            ? const Color(0xFF638ECB)
            : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser && message.detectedContext != null && message.detectedContext != ChatContext.general)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getContextColor(message.detectedContext!).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getContextLabel(message.detectedContext!),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getContextColor(message.detectedContext!),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: message.isUser ? Colors.white : const Color(0xFF262626),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // 파일 첨부 기능
            },
            color: const Color(0xFF638ECB),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요...',
                filled: true,
                fillColor: const Color(0xFFF0F3FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF638ECB),
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // 컨텍스트 자동 감지
    final detectedContext = _detectContext(text);
    
    setState(() {
      _currentSession!.messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: text,
          isUser: true,
          timestamp: DateTime.now(),
          detectedContext: detectedContext,
        ),
      );
      _messageController.clear();
      
      // 학습 컨텍스트면 도구 표시
      if (detectedContext == ChatContext.learning && !_showTools) {
        _showTools = true;
        _toolsController.forward();
      } else if (detectedContext != ChatContext.learning && _showTools) {
        _toolsController.reverse().then((_) {
          setState(() {
            _showTools = false;
          });
        });
      }
    });

    // AI 응답 시뮬레이션
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentSession!.messages.add(
            ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              content: _getAIResponse(text, detectedContext),
              isUser: false,
              timestamp: DateTime.now(),
              detectedContext: detectedContext,
            ),
          );
        });
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getAIResponse(String message, ChatContext context) {
    // 실제로는 AI API 호출
    switch (context) {
      case ChatContext.learning:
        return '좋은 질문이네요! 단계별로 설명해드릴게요...';
      case ChatContext.analysis:
        return '이를 분석해보면 다음과 같은 패턴이 보입니다...';
      case ChatContext.summary:
        return '핵심 내용을 정리하면 다음과 같습니다...';
      case ChatContext.emotional:
        return '힘드셨겠네요. 제가 도와드릴 수 있는 부분이 있을까요?';
      case ChatContext.general:
      default:
        return '네, 이해했습니다. 더 자세히 말씀해주시겠어요?';
    }
  }

  void _showNewChatDialog() {
    String selectedSubject = '수학';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('새 대화 시작'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('과목 선택'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF0F3FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '수학', child: Text('수학')),
                  DropdownMenuItem(value: '영어', child: Text('영어')),
                  DropdownMenuItem(value: '국어', child: Text('국어')),
                  DropdownMenuItem(value: '과학', child: Text('과학')),
                  DropdownMenuItem(value: '사회', child: Text('사회')),
                  DropdownMenuItem(value: '한국사', child: Text('한국사')),
                  DropdownMenuItem(value: '기타', child: Text('기타')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedSubject = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'AI가 대화 내용에 따라 자동으로\n학습, 분석, 요약, 상담 모드를 전환합니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF737373),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                _startNewChat(selectedSubject, '새 대화');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF638ECB),
                foregroundColor: Colors.white,
              ),
              child: const Text('시작'),
            ),
          ],
        ),
      ),
    );
  }

  void _startNewChat(String subject, String title) {
    final newSession = ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      subject: subject,
      lastMessage: DateTime.now(),
      messages: [],
    );
    
    setState(() {
      _sessions.insert(0, newSession);
      _currentSession = newSession;
    });
  }

  String _getContextLabel(ChatContext context) {
    switch (context) {
      case ChatContext.learning:
        return '학습 모드';
      case ChatContext.analysis:
        return '분석 모드';
      case ChatContext.summary:
        return '요약 모드';
      case ChatContext.emotional:
        return '상담 모드';
      case ChatContext.general:
      default:
        return '일반 대화';
    }
  }

  Color _getContextColor(ChatContext context) {
    switch (context) {
      case ChatContext.learning:
        return Colors.blue;
      case ChatContext.analysis:
        return Colors.orange;
      case ChatContext.summary:
        return Colors.green;
      case ChatContext.emotional:
        return Colors.purple;
      case ChatContext.general:
      default:
        return const Color(0xFF638ECB);
    }
  }

  IconData _getContextIcon(ChatContext context) {
    switch (context) {
      case ChatContext.learning:
        return Icons.school;
      case ChatContext.analysis:
        return Icons.analytics;
      case ChatContext.summary:
        return Icons.summarize;
      case ChatContext.emotional:
        return Icons.favorite;
      case ChatContext.general:
      default:
        return Icons.chat;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case '수학':
        return Colors.red;
      case '영어':
        return Colors.blue;
      case '국어':
        return Colors.orange;
      case '과학':
        return Colors.green;
      case '사회':
        return Colors.purple;
      case '한국사':
        return Colors.brown;
      default:
        return const Color(0xFF638ECB);
    }
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}