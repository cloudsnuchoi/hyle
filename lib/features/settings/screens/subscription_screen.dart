import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  
  String _selectedPlan = 'free'; // 'free' or 'premium'

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
              Color(0xFFD5DEEF),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildCurrentPlan(),
                    const SizedBox(height: 24),
                    _buildPlanOptions(),
                    const SizedBox(height: 24),
                    _buildFeatureComparison(),
                    const SizedBox(height: 24),
                    _buildActionButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF395886)),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profile');
              }
            },
          ),
          const Expanded(
            child: Text(
              '구독 관리',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // 좌우 균형을 위한 공간
        ],
      ),
    );
  }

  Widget _buildCurrentPlan() {
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF638ECB),
              Color(0xFF395886),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF395886).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '현재 플랜',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '무료 플랜',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '기본 학습 기능을 무료로 이용중입니다',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                SizedBox(width: 8),
                Text(
                  '가입일: 2025년 8월 1일',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOptions() {
    return Transform.translate(
      offset: Offset(0, _slideIn.value),
      child: FadeTransition(
        opacity: _fadeIn,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '플랜 선택',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF395886),
                ),
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                id: 'free',
                title: '무료 플랜',
                price: '₩0',
                period: '/월',
                description: '기본 학습 기능',
                isPopular: false,
              ),
              const SizedBox(height: 12),
              _buildPlanCard(
                id: 'premium',
                title: '프리미엄 플랜',
                price: '₩9,900',
                period: '/월',
                description: 'AI 튜터 + 모든 기능',
                isPopular: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String title,
    required String price,
    required String period,
    required String description,
    required bool isPopular,
  }) {
    final isSelected = _selectedPlan == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF638ECB) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? const Color(0xFF638ECB).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF638ECB),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF395886),
                        ),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '인기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8AAEE0),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF638ECB) : const Color(0xFF395886),
                      ),
                    ),
                    Text(
                      period,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8AAEE0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
    return FadeTransition(
      opacity: _fadeIn,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기능 비교',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureRow('학습 타이머', true, true),
            _buildFeatureRow('투두 리스트', true, true),
            _buildFeatureRow('학습 기록', true, true),
            _buildFeatureRow('기본 통계', true, true),
            const Divider(height: 24),
            _buildFeatureRow('AI 튜터', false, true),
            _buildFeatureRow('맞춤형 학습 추천', false, true),
            _buildFeatureRow('상세 분석 리포트', false, true),
            _buildFeatureRow('무제한 플래시카드', false, true),
            _buildFeatureRow('오프라인 모드', false, true),
            _buildFeatureRow('광고 제거', false, true),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool inFree, bool inPremium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF525252),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                inFree ? Icons.check_circle : Icons.cancel,
                color: inFree ? Colors.green : Colors.grey.shade300,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                inPremium ? Icons.check_circle : Icons.cancel,
                color: inPremium ? Colors.green : Colors.grey.shade300,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final isPremiumSelected = _selectedPlan == 'premium';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isPremiumSelected ? () {
            // 결제 프로세스 시작
            _showPaymentDialog();
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF638ECB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: isPremiumSelected ? 8 : 0,
            shadowColor: const Color(0xFF638ECB).withValues(alpha: 0.3),
          ),
          child: Text(
            isPremiumSelected ? '프리미엄 시작하기' : '현재 플랜 사용중',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('프리미엄 구독'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('프리미엄 플랜을 시작하시겠습니까?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₩9,900/월',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF638ECB),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• 7일 무료 체험 제공',
                    style: TextStyle(fontSize: 14, color: Color(0xFF525252)),
                  ),
                  Text(
                    '• 언제든지 취소 가능',
                    style: TextStyle(fontSize: 14, color: Color(0xFF525252)),
                  ),
                ],
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('결제 기능은 준비 중입니다'),
                  backgroundColor: Color(0xFF638ECB),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF638ECB),
              foregroundColor: Colors.white,
            ),
            child: const Text('구독 시작'),
          ),
        ],
      ),
    );
  }
}