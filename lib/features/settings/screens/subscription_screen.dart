import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleIn;
  late Animation<double> _pulse;

  String _selectedPlan = 'premium';
  String _billingCycle = 'monthly';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

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

    _scaleIn = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
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
                          'Subscription',
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
                                _buildCurrentPlan(),
                                const SizedBox(height: 24),
                                _buildBillingToggle(),
                                const SizedBox(height: 24),
                                _buildPlanOptions(),
                                const SizedBox(height: 24),
                                _buildFeatureComparison(),
                                const SizedBox(height: 24),
                                _buildPaymentMethod(),
                                const SizedBox(height: 24),
                                _buildBillingHistory(),
                                const SizedBox(height: 32),
                                _buildActionButtons(),
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
    );
  }

  Widget _buildCurrentPlan() {
    return Transform.scale(
      scale: _scaleIn.value,
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Plan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Renews on Dec 15, 2024',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlanStat('Days Left', '15'),
                _buildPlanStat('Saved', '\$120'),
                _buildPlanStat('Member Since', 'Jan 2024'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _billingCycle = 'monthly'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _billingCycle == 'monthly'
                      ? const Color(0xFF638ECB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      color: _billingCycle == 'monthly'
                          ? Colors.white
                          : const Color(0xFF395886),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _billingCycle = 'yearly'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _billingCycle == 'yearly'
                      ? const Color(0xFF638ECB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Yearly',
                      style: TextStyle(
                        color: _billingCycle == 'yearly'
                            ? Colors.white
                            : const Color(0xFF395886),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_billingCycle != 'yearly')
                      Positioned(
                        top: -4,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Save 20%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOptions() {
    return Column(
      children: [
        _buildPlanCard(
          id: 'free',
          name: 'Free',
          price: _billingCycle == 'monthly' ? '\$0' : '\$0',
          period: _billingCycle == 'monthly' ? '/month' : '/year',
          features: [
            'Basic learning features',
            '5 AI queries per day',
            'Limited study materials',
            'Basic progress tracking',
          ],
          isPopular: false,
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _selectedPlan == 'premium' ? _pulse.value : 1.0,
              child: _buildPlanCard(
                id: 'premium',
                name: 'Premium',
                price: _billingCycle == 'monthly' ? '\$9.99' : '\$95.99',
                period: _billingCycle == 'monthly' ? '/month' : '/year',
                features: [
                  'Unlimited AI assistance',
                  'All study materials',
                  'Advanced analytics',
                  'Priority support',
                  'Offline mode',
                  'Custom study plans',
                ],
                isPopular: true,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildPlanCard(
          id: 'pro',
          name: 'Pro',
          price: _billingCycle == 'monthly' ? '\$19.99' : '\$191.99',
          period: _billingCycle == 'monthly' ? '/month' : '/year',
          features: [
            'Everything in Premium',
            'Team collaboration',
            'API access',
            'White-label options',
            'Dedicated account manager',
            'Custom integrations',
            'SLA guarantee',
          ],
          isPopular: false,
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required String id,
    required String name,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
  }) {
    bool isSelected = _selectedPlan == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF638ECB) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF395886).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isPopular)
              Positioned(
                top: 0,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF395886),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF638ECB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF638ECB),
                        ),
                      ),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8AAEE0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF8AAEE0),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF395886),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparison() {
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
                Icon(Icons.compare, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Feature Comparison',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          _buildComparisonRow('AI Queries', ['5/day', 'Unlimited', 'Unlimited']),
          _buildComparisonRow('Study Materials', ['Basic', 'All', 'All + Premium']),
          _buildComparisonRow('Analytics', ['Basic', 'Advanced', 'Enterprise']),
          _buildComparisonRow('Support', ['Community', 'Priority', 'Dedicated']),
          _buildComparisonRow('Team Features', ['—', '—', '✓']),
          _buildComparisonRow('API Access', ['—', '—', '✓']),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String feature, List<String> values) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF395886),
              ),
            ),
          ),
          ...values.map((value) => Expanded(
                child: Center(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: value == '—' ? Colors.grey : const Color(0xFF638ECB),
                      fontWeight: value == '✓' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
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
                Icon(Icons.payment, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card, color: Color(0xFF8AAEE0)),
            title: const Text('•••• •••• •••• 4242'),
            subtitle: const Text('Expires 12/25'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF638ECB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Default',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline, color: Color(0xFF8AAEE0)),
            title: const Text('Add Payment Method'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBillingHistory() {
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
                Icon(Icons.history, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Billing History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          _buildBillingItem('Nov 15, 2024', 'Premium Monthly', '\$9.99'),
          _buildBillingItem('Oct 15, 2024', 'Premium Monthly', '\$9.99'),
          _buildBillingItem('Sep 15, 2024', 'Premium Monthly', '\$9.99'),
          ListTile(
            leading: const Icon(Icons.receipt_long, color: Color(0xFF8AAEE0)),
            title: const Text('View All Invoices'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBillingItem(String date, String description, String amount) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.receipt, color: Color(0xFF638ECB), size: 20),
      ),
      title: Text(
        description,
        style: const TextStyle(fontSize: 15),
      ),
      subtitle: Text(
        date,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Text(
        amount,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF395886),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF8AAEE0), Color(0xFF638ECB)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Handle upgrade/change plan
              },
              child: const Center(
                child: Text(
                  'Change Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Subscription'),
                content: const Text(
                  'Are you sure you want to cancel your subscription? '
                  'You will lose access to premium features at the end of your billing period.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Keep Subscription'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Handle cancellation
                    },
                    child: const Text(
                      'Cancel Subscription',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
          child: const Text(
            'Cancel Subscription',
            style: TextStyle(
              color: Color(0xFF395886),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}