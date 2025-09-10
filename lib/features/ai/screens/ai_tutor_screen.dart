import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AITutorScreen extends ConsumerStatefulWidget {
  const AITutorScreen({super.key});

  @override
  ConsumerState<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends ConsumerState<AITutorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;
  
  bool _isTyping = false;
  String _selectedSubject = 'math';
  
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '안녕하세요! AI 튜터입니다. 무엇을 도와드릴까요?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: MessageType.greeting,
    ),
    ChatMessage(
      text: '이차방정식 x² - 5x + 6 = 0을 풀어주세요.',
      isUser: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    ChatMessage(
      text: '이차방정식을 풀어보겠습니다.\n\n**단계 1: 인수분해**\nx² - 5x + 6 = 0\n(x - 2)(x - 3) = 0\n\n**단계 2: 해 구하기**\nx - 2 = 0 또는 x - 3 = 0\n따라서 x = 2 또는 x = 3\n\n**답: x = 2, 3**',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      type: MessageType.solution,
    ),
  ];
  
  final List<String> _quickActions = [
    '문제 풀이 도움',
    '개념 설명',
    '예제 문제',
    '오답 분석',
    '학습 팁',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: '네, 그 부분에 대해 설명드리겠습니다. 잠시만 기다려주세요...',
            isUser: false,
            timestamp: DateTime.now(),
            type: MessageType.explanation,
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    });
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
              Color(0xFFE8EDF5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF395886)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF638ECB),
                            Color(0xFF8AAEE0),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI 허브',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1E27),
                            ),
                          ),
                          Text(
                            _isTyping ? '입력 중...' : '온라인',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isTyping ? const Color(0xFF638ECB) : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // AI Feature Buttons
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.analytics, color: Color(0xFF638ECB)),
                          tooltip: 'AI 분석',
                          onPressed: () {
                            context.push('/ai/analysis');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.summarize, color: Color(0xFF638ECB)),
                          tooltip: 'AI 요약',
                          onPressed: () {
                            context.push('/ai/summary');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF638ECB)),
                          tooltip: 'AI 채팅',
                          onPressed: () {
                            context.push('/ai/chat');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Subject Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedSubject,
                        isDense: true,
                        underline: const SizedBox(),
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF638ECB)),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF638ECB),
                          fontWeight: FontWeight.bold,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'math', child: Text('수학')),
                          DropdownMenuItem(value: 'english', child: Text('영어')),
                          DropdownMenuItem(value: 'science', child: Text('과학')),
                          DropdownMenuItem(value: 'history', child: Text('역사')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedSubject = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF395886),
                  indicatorWeight: 3,
                  labelColor: const Color(0xFF395886),
                  unselectedLabelColor: const Color(0xFF737373),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'AI 튜터'),
                    Tab(text: 'AI 채팅'),
                    Tab(text: 'AI 분석'),
                    Tab(text: 'AI 요약'),
                  ],
                ),
              ),

              // Quick Actions
              Container(
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _quickActions.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(_quickActions[index]),
                        onPressed: () {
                          _messageController.text = _quickActions[index];
                          _sendMessage();
                        },
                        backgroundColor: Colors.white,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF638ECB),
                        ),
                        side: BorderSide(
                          color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // AI 튜터 탭
                    _buildAITutorTab(),
                    // AI 채팅 탭
                    _buildAIChatTab(),
                    // AI 분석 탭
                    _buildAIAnalysisTab(),
                    // AI 요약 탭
                    _buildAISummaryTab(),
                  ],
                ),
              ),

              // Input Area
              Container(
                padding: const EdgeInsets.all(20),
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
                    // Attachment Button
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: Color(0xFF638ECB)),
                      onPressed: () {},
                    ),
                    
                    // Text Input
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F3FA),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            hintText: '질문을 입력하세요...',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Send Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF638ECB),
                            Color(0xFF8AAEE0),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAITutorTab() {
    return Column(
      children: [
        // Quick Actions
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(_quickActions[index]),
                  onPressed: () {
                    _messageController.text = _quickActions[index];
                    _sendMessage();
                  },
                  backgroundColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF638ECB),
                  ),
                  side: BorderSide(
                    color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                  ),
                ),
              );
            },
          ),
        ),
        // Chat Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping && index == _messages.length) {
                return _buildTypingIndicator();
              }
              return _buildMessage(_messages[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAIChatTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Color(0xFF8AAEE0),
          ),
          SizedBox(height: 16),
          Text(
            'AI 채팅',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI와 자유롭게 대화하세요',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8AAEE0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 80,
            color: Color(0xFF8AAEE0),
          ),
          SizedBox(height: 16),
          Text(
            'AI 분석',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '학습 데이터를 분석합니다',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8AAEE0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummaryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.summarize,
            size: 80,
            color: Color(0xFF8AAEE0),
          ),
          SizedBox(height: 16),
          Text(
            'AI 요약',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '학습 내용을 요약해드립니다',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8AAEE0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF638ECB),
                    Color(0xFF8AAEE0),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF638ECB) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF638ECB).withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser && message.type != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getMessageTypeColor(message.type!).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getMessageTypeLabel(message.type!),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getMessageTypeColor(message.type!),
                        ),
                      ),
                    ),
                  
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : const Color(0xFF1A1E27),
                      height: 1.4,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF8AAEE0).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF638ECB),
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF638ECB),
                  Color(0xFF8AAEE0),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = (_typingAnimation.value - delay).clamp(0.0, 1.0);
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          Colors.grey[400],
                          const Color(0xFF638ECB),
                          value,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getMessageTypeColor(MessageType type) {
    switch (type) {
      case MessageType.greeting:
        return const Color(0xFF638ECB);
      case MessageType.solution:
        return Colors.green;
      case MessageType.explanation:
        return Colors.orange;
      case MessageType.hint:
        return Colors.purple;
      case MessageType.error:
        return Colors.red;
    }
  }

  String _getMessageTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.greeting:
        return '인사';
      case MessageType.solution:
        return '풀이';
      case MessageType.explanation:
        return '설명';
      case MessageType.hint:
        return '힌트';
      case MessageType.error:
        return '오류';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType? type;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type,
  });
}

enum MessageType {
  greeting,
  solution,
  explanation,
  hint,
  error,
}