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
  String _selectedCategory = 'All';
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
                          'Help & Support',
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
          hintText: 'Search for help...',
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
            title: 'User Guide',
            color: const Color(0xFF8AAEE0),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.play_circle,
            title: 'Video Tutorials',
            color: const Color(0xFF638ECB),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            icon: Icons.forum,
            title: 'Community',
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
    final categories = ['All', 'Getting Started', 'Account', 'Learning', 'Technical', 'Billing'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
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
                  'Popular Articles',
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
            'How to get started with HYLE',
            'Learn the basics of our learning platform',
            Icons.rocket_launch,
          ),
          _buildArticleItem(
            'Understanding your learning type',
            'Discover your unique learning style',
            Icons.psychology,
          ),
          _buildArticleItem(
            'Setting up study goals',
            'Create effective learning objectives',
            Icons.flag,
          ),
          _buildArticleItem(
            'Using AI features effectively',
            'Maximize your AI assistant benefits',
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
        'question': 'How do I reset my password?',
        'answer': 'You can reset your password by going to Settings > Account > Change Password, or by clicking "Forgot Password" on the login screen.',
      },
      {
        'id': 'faq2',
        'question': 'Can I use HYLE offline?',
        'answer': 'Yes! Premium users can download content for offline access. Simply tap the download icon on any lesson or study material.',
      },
      {
        'id': 'faq3',
        'question': 'How does the AI tutor work?',
        'answer': 'Our AI tutor uses advanced language models to provide personalized learning assistance, answer questions, and generate study materials tailored to your needs.',
      },
      {
        'id': 'faq4',
        'question': 'What payment methods are accepted?',
        'answer': 'We accept all major credit cards, debit cards, PayPal, and various regional payment methods depending on your location.',
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
                  'Frequently Asked Questions',
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
                  'Contact Us',
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
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            badge: 'Online',
            badgeColor: Colors.green,
            onTap: _showLiveChat,
          ),
          _buildContactTile(
            icon: Icons.email,
            title: 'Email Support',
            subtitle: 'support@hyle.app',
            onTap: () {},
          ),
          _buildContactTile(
            icon: Icons.phone,
            title: 'Phone Support',
            subtitle: 'Mon-Fri, 9AM-6PM EST',
            onTap: () {},
          ),
          _buildContactTile(
            icon: Icons.feedback,
            title: 'Send Feedback',
            subtitle: 'Help us improve HYLE',
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
              'Learning Resources',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Access our comprehensive learning resources including guides, tutorials, and best practices.',
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
                'Browse Resources',
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
                'Live Chat Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF395886),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Chat interface would go here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}