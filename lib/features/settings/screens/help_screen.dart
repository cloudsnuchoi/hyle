import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _expandController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _expandAnimation;

  final TextEditingController _searchTextController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '전체';
  final Set<String> _expandedFAQs = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideIn = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _expandController.dispose();
    _searchTextController.dispose();
    super.dispose();
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
              Color(0xFF395886),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Opacity(
                        opacity: _fadeIn.value,
                        child: const Text(
                          '도움말 및 지원',
                          style: TextStyle(
                            color: Color(0xFF395886),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      centerTitle: true,
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF395886)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.headset_mic, color: Color(0xFF395886)),
                        onPressed: () {
                          _showLiveChat();
                        },
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Transform.translate(
                          offset: Offset(0, _slideIn.value),
                          child: Opacity(
                            opacity: _fadeIn.value,
                            child: Column(
                              children: [
                                _buildSearchBar(),
                                const SizedBox(height: 24),
                                _buildQuickActions(),
                                const SizedBox(height: 24),
                                _buildCategories(),
                                const SizedBox(height: 24),
                                _buildPopularArticles(),
                                const SizedBox(height: 24),
                                _buildFAQSection(),
                                const SizedBox(height: 24),
                                _buildContactOptions(),
                                const SizedBox(height: 24),
                                _buildResourcesSection(),
                              ],
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLiveChat();
        },
        backgroundColor: const Color(0xFF638ECB),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchTextController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: '도움말 검색...',
          hintStyle: const TextStyle(color: Color(0xFF8AAEE0)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF638ECB)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF8AAEE0)),
                  onPressed: () {
                    setState(() {
                      _searchTextController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.book,
            title: '사용자 가이드',
            color: const Color(0xFF8AAEE0),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.play_circle,
            title: '동영상 강의',
            color: const Color(0xFF638ECB),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.forum,
            title: '커뮤니티',
            color: const Color(0xFF395886),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['전체', '시작하기', '계정', '학습', '기술', '결제'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            bool isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF638ECB) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF395886),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularArticles() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  '인기 글',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          _buildArticleItem(
            'HYLE 시작하기',
            '학습 플랫폼의 기초 알아보기',
            Icons.rocket_launch,
          ),
          _buildArticleItem(
            '내 학습 유형 이해하기',
            '나만의 학습 스타일 발견하기',
            Icons.psychology,
          ),
          _buildArticleItem(
            '학습 목표 설정하기',
            '효과적인 학습 목표 만들기',
            Icons.flag,
          ),
          _buildArticleItem(
            'AI 기능 효과적으로 사용하기',
            'AI 비서의 이점 극대화하기',
            Icons.auto_awesome,
          ),
        ],
      ),
    );
  }

  Widget _buildArticleItem(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF638ECB), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF395886),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF8AAEE0),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8AAEE0)),
      onTap: () {},
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'id': 'faq1',
        'question': '비밀번호를 어떻게 재설정하나요?',
        'answer': '설정 > 계정 > 비밀번호 변경에서 비밀번호를 재설정하거나, 로그인 화면에서 "비밀번호 찾기"를 클릭하여 재설정할 수 있습니다.',
      },
      {
        'id': 'faq2',
        'question': 'HYLE을 오프라인에서 사용할 수 있나요?',
        'answer': '네! 프리미엄 사용자는 오프라인 액세스를 위해 콘텐츠를 다운로드할 수 있습니다. 단순히 수업이나 학습 자료의 다운로드 아이콘을 탭하면 됩니다.',
      },
      {
        'id': 'faq3',
        'question': 'AI 튜터는 어떻게 작동하나요?',
        'answer': '저희 AI 튜터는 고급 언어 모델을 사용하여 개인화된 학습 지원을 제공하고, 질문에 답하며, 여러분의 요구에 맞춰 학습 자료를 생성합니다.',
      },
      {
        'id': 'faq4',
        'question': '어떤 결제 방법을 지원하나요?',
        'answer': '모든 주요 신용카드, 직불카드, PayPal, 그리고 지역에 따른 다양한 결제 방법을 지원합니다.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  '자주 묻는 질문',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          ...faqs.map((faq) => _buildFAQItem(
                faq['id']!,
                faq['question']!,
                faq['answer']!,
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String id, String question, String answer) {
    bool isExpanded = _expandedFAQs.contains(id);

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedFAQs.remove(id);
              } else {
                _expandedFAQs.add(id);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF395886),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.expand_more,
                    color: Color(0xFF638ECB),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8AAEE0),
                height: 1.5,
              ),
            ),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        if (!isExpanded)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildContactOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.contact_support, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  '문의하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          _buildContactTile(
            icon: Icons.chat_bubble,
            title: '라이브 채팅',
            subtitle: '지원팀과 채팅하기',
            badge: '온라인',
            badgeColor: Colors.green,
            onTap: _showLiveChat,
          ),
          _buildContactTile(
            icon: Icons.email,
            title: '이메일 지원',
            subtitle: 'support@hyle.app',
            onTap: () {},
          ),
          _buildContactTile(
            icon: Icons.phone,
            title: '전화 지원',
            subtitle: '월-금, 오전 9시-오후 6시 (EST)',
            onTap: () {},
          ),
          _buildContactTile(
            icon: Icons.feedback,
            title: '피드백 보내기',
            subtitle: 'HYLE 개선을 도와주세요',
            onTap: () {},
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF638ECB), size: 20),
      ),
      title: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF395886),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeColor ?? const Color(0xFF638ECB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF8AAEE0),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8AAEE0)),
      onTap: onTap,
    );
  }

  Widget _buildResourcesSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8AAEE0), Color(0xFF638ECB)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF638ECB).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.school,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              '학습 자료',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '가이드, 튜토리얼, 베스트 프랙티스를 포함한 종합적인 학습 자료에 액세스하세요.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF638ECB),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '자료 둘러보기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLiveChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '라이브 채팅 지원',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF395886),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('채팅 인터페이스가 여기에 표시됩니다'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}