import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CertificateScreen extends ConsumerStatefulWidget {
  const CertificateScreen({super.key});

  @override
  ConsumerState<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends ConsumerState<CertificateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;

  final List<Map<String, dynamic>> _certificates = [
    {
      'id': '1',
      'title': 'Mathematics Fundamentals',
      'issuer': 'HYLE Academy',
      'date': DateTime.now().subtract(const Duration(days: 60)),
      'status': 'verified',
      'score': 95,
      'skills': ['Algebra', 'Geometry', 'Calculus'],
      'certificateNumber': 'HYLE-2025-0001',
    },
    {
      'id': '2',
      'title': 'Physics Excellence',
      'issuer': 'HYLE Academy',
      'date': DateTime.now().subtract(const Duration(days: 30)),
      'status': 'verified',
      'score': 88,
      'skills': ['Mechanics', 'Thermodynamics', 'Optics'],
      'certificateNumber': 'HYLE-2025-0002',
    },
    {
      'id': '3',
      'title': 'English Proficiency',
      'issuer': 'HYLE Academy',
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'status': 'pending',
      'score': 92,
      'skills': ['Grammar', 'Writing', 'Speaking'],
      'certificateNumber': 'HYLE-2025-0003',
    },
  ];

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
      curve: Curves.easeOut,
    ));

    _slideIn = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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
              Color(0xFF395886),
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeIn.value,
                child: Transform.translate(
                  offset: Offset(0, _slideIn.value),
                  child: Column(
                    children: [
                      _buildHeader(),
                      _buildStats(),
                      Expanded(child: _buildCertificateList()),
                    ],
                  ),
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
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'My Certificates',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF395886)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final verifiedCount = _certificates.where((c) => c['status'] == 'verified').length;
    final totalCount = _certificates.length;
    final avgScore = _certificates.fold<double>(
      0, (sum, cert) => sum + cert['score']) / _certificates.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalCount.toString(), Icons.card_membership),
          _buildStatItem('Verified', verifiedCount.toString(), Icons.verified),
          _buildStatItem('Avg Score', '${avgScore.toInt()}%', Icons.star),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF638ECB), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF8AAEE0),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _certificates.length,
      itemBuilder: (context, index) {
        return _buildCertificateCard(_certificates[index]);
      },
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> certificate) {
    final isVerified = certificate['status'] == 'verified';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVerified ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isVerified 
                  ? const Color(0xFF638ECB).withValues(alpha: 0.1)
                  : const Color(0xFFD5DEEF).withValues(alpha: 0.2),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF395886).withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: isVerified ? const Color(0xFF638ECB) : const Color(0xFF8AAEE0),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF395886),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                size: 14,
                                color: const Color(0xFF8AAEE0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                certificate['issuer'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8AAEE0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isVerified ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isVerified ? 'Verified' : 'Pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Certificate Number',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF8AAEE0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          certificate['certificateNumber'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF395886),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF8AAEE0),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${certificate['score']}%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF638ECB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: const Color(0xFF8AAEE0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(certificate['date']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8AAEE0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (certificate['skills'] as List).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF638ECB).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF638ECB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF638ECB),
                          side: const BorderSide(color: Color(0xFF638ECB)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isVerified ? () {} : null,
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF638ECB),
                          disabledBackgroundColor: const Color(0xFFD5DEEF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}