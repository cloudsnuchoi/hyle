import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  const PrivacyScreen({super.key});

  @override
  ConsumerState<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _expandController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleIn;

  // Privacy settings
  bool _shareDataForImprovement = true;
  bool _personalizedAds = false;
  bool _analyticsEnabled = true;
  bool _crashReporting = true;
  bool _locationTracking = false;
  bool _cameraAccess = false;
  bool _microphoneAccess = false;
  bool _contactsAccess = false;
  
  // Profile visibility
  String _profileVisibility = 'Friends';
  String _activityVisibility = 'Friends';
  String _progressSharing = 'Private';
  
  // Data management
  bool _autoDeleteOldData = false;
  int _dataRetentionDays = 90;
  
  // Expanded sections
  final Set<String> _expandedSections = {};

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

    _scaleIn = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _expandController.dispose();
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
                          'Privacy & Security',
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
                        icon: const Icon(Icons.shield_outlined, color: Color(0xFF395886)),
                        onPressed: () {
                          _showPrivacyScore();
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
                                _buildPrivacyScore(),
                                const SizedBox(height: 24),
                                _buildDataCollectionSection(),
                                const SizedBox(height: 24),
                                _buildPermissionsSection(),
                                const SizedBox(height: 24),
                                _buildVisibilitySection(),
                                const SizedBox(height: 24),
                                _buildDataManagementSection(),
                                const SizedBox(height: 24),
                                _buildSecuritySection(),
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

  Widget _buildPrivacyScore() {
    int score = _calculatePrivacyScore();
    Color scoreColor = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.orange
            : Colors.red;

    return Transform.scale(
      scale: _scaleIn.value,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scoreColor.withValues(alpha: 0.8),
              scoreColor,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: scoreColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Privacy Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getScoreMessage(score),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: _showPrivacyScore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCollectionSection() {
    return _buildExpandableCard(
      id: 'data_collection',
      title: 'Data Collection',
      icon: Icons.data_usage,
      children: [
        _buildSwitchTile(
          icon: Icons.analytics,
          title: 'Analytics',
          subtitle: 'Help us improve the app',
          value: _analyticsEnabled,
          onChanged: (value) => setState(() => _analyticsEnabled = value),
        ),
        _buildSwitchTile(
          icon: Icons.bug_report,
          title: 'Crash Reporting',
          subtitle: 'Automatically report crashes',
          value: _crashReporting,
          onChanged: (value) => setState(() => _crashReporting = value),
        ),
        _buildSwitchTile(
          icon: Icons.trending_up,
          title: 'Share Data for Improvement',
          subtitle: 'Contribute to app development',
          value: _shareDataForImprovement,
          onChanged: (value) => setState(() => _shareDataForImprovement = value),
        ),
        _buildSwitchTile(
          icon: Icons.ads_click,
          title: 'Personalized Ads',
          subtitle: 'Show relevant advertisements',
          value: _personalizedAds,
          onChanged: (value) => setState(() => _personalizedAds = value),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return _buildExpandableCard(
      id: 'permissions',
      title: 'App Permissions',
      icon: Icons.security,
      children: [
        _buildSwitchTile(
          icon: Icons.location_on,
          title: 'Location Access',
          subtitle: 'For location-based features',
          value: _locationTracking,
          onChanged: (value) => setState(() => _locationTracking = value),
        ),
        _buildSwitchTile(
          icon: Icons.camera_alt,
          title: 'Camera Access',
          subtitle: 'For scanning and AR features',
          value: _cameraAccess,
          onChanged: (value) => setState(() => _cameraAccess = value),
        ),
        _buildSwitchTile(
          icon: Icons.mic,
          title: 'Microphone Access',
          subtitle: 'For voice features',
          value: _microphoneAccess,
          onChanged: (value) => setState(() => _microphoneAccess = value),
        ),
        _buildSwitchTile(
          icon: Icons.contacts,
          title: 'Contacts Access',
          subtitle: 'Find friends using the app',
          value: _contactsAccess,
          onChanged: (value) => setState(() => _contactsAccess = value),
        ),
      ],
    );
  }

  Widget _buildVisibilitySection() {
    return _buildExpandableCard(
      id: 'visibility',
      title: 'Profile Visibility',
      icon: Icons.visibility,
      children: [
        _buildDropdownTile(
          icon: Icons.person,
          title: 'Profile Visibility',
          value: _profileVisibility,
          options: ['Public', 'Friends', 'Private'],
          onChanged: (value) => setState(() => _profileVisibility = value!),
        ),
        _buildDropdownTile(
          icon: Icons.trending_up,
          title: 'Activity Visibility',
          value: _activityVisibility,
          options: ['Public', 'Friends', 'Private'],
          onChanged: (value) => setState(() => _activityVisibility = value!),
        ),
        _buildDropdownTile(
          icon: Icons.bar_chart,
          title: 'Progress Sharing',
          value: _progressSharing,
          options: ['Public', 'Friends', 'Private'],
          onChanged: (value) => setState(() => _progressSharing = value!),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildExpandableCard(
      id: 'data_management',
      title: 'Data Management',
      icon: Icons.storage,
      children: [
        _buildSwitchTile(
          icon: Icons.auto_delete,
          title: 'Auto-delete Old Data',
          subtitle: 'Remove data after $_dataRetentionDays days',
          value: _autoDeleteOldData,
          onChanged: (value) => setState(() => _autoDeleteOldData = value),
        ),
        if (_autoDeleteOldData)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Data Retention Period',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF395886),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_dataRetentionDays days',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF638ECB),
                    inactiveTrackColor: const Color(0xFFD5DEEF),
                    thumbColor: const Color(0xFF395886),
                    overlayColor: const Color(0xFF638ECB).withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _dataRetentionDays.toDouble(),
                    min: 30,
                    max: 365,
                    divisions: 11,
                    onChanged: (value) => setState(() => _dataRetentionDays = value.round()),
                  ),
                ),
              ],
            ),
          ),
        ListTile(
          leading: const Icon(Icons.download, color: Color(0xFF8AAEE0)),
          title: const Text('Download My Data'),
          subtitle: const Text('Get a copy of your data'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showDataDownloadDialog();
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text(
            'Delete All Data',
            style: TextStyle(color: Colors.red),
          ),
          subtitle: const Text('Permanently remove your data'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
          onTap: () {
            _showDeleteDataDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildExpandableCard(
      id: 'security',
      title: 'Security Settings',
      icon: Icons.lock,
      children: [
        ListTile(
          leading: const Icon(Icons.key, color: Color(0xFF8AAEE0)),
          title: const Text('Two-Factor Authentication'),
          subtitle: const Text('Add extra security'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Enabled',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.fingerprint, color: Color(0xFF8AAEE0)),
          title: const Text('Biometric Login'),
          subtitle: const Text('Use fingerprint or face'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.devices, color: Color(0xFF8AAEE0)),
          title: const Text('Active Sessions'),
          subtitle: const Text('Manage logged-in devices'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.history, color: Color(0xFF8AAEE0)),
          title: const Text('Login History'),
          subtitle: const Text('View recent login attempts'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {},
        ),
      ],
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
            border: Border.all(color: const Color(0xFF638ECB), width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _showPrivacyPolicy();
              },
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, color: Color(0xFF638ECB)),
                    SizedBox(width: 8),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF638ECB),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF638ECB), width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _showTermsOfService();
              },
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gavel, color: Color(0xFF638ECB)),
                    SizedBox(width: 8),
                    Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: Color(0xFF638ECB),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableCard({
    required String id,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    bool isExpanded = _expandedSections.contains(id);

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
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSections.remove(id);
                } else {
                  _expandedSections.add(id);
                }
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF638ECB), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
            secondChild: Column(children: children),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8AAEE0)),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF638ECB),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF8AAEE0)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF395886),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F3FA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<String>(
          value: value,
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          underline: const SizedBox(),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF638ECB)),
        ),
      ),
    );
  }

  int _calculatePrivacyScore() {
    int score = 100;
    
    // Deduct points for privacy-reducing settings
    if (_shareDataForImprovement) {
      score -= 5;
    }
    if (_personalizedAds) {
      score -= 15;
    }
    if (_analyticsEnabled) {
      score -= 5;
    }
    if (_locationTracking) {
      score -= 10;
    }
    if (_cameraAccess) {
      score -= 5;
    }
    if (_microphoneAccess) {
      score -= 5;
    }
    if (_contactsAccess) {
      score -= 10;
    }
    if (_profileVisibility == 'Public') {
      score -= 15;
    } else if (_profileVisibility == 'Friends') {
      score -= 5;
    }
    if (_activityVisibility == 'Public') {
      score -= 10;
    } else if (_activityVisibility == 'Friends') {
      score -= 5;
    }
    if (_progressSharing == 'Public') {
      score -= 10;
    } else if (_progressSharing == 'Friends') {
      score -= 5;
    }
    
    return score.clamp(0, 100);
  }

  String _getScoreMessage(int score) {
    if (score >= 80) return 'Excellent privacy protection';
    if (score >= 60) return 'Good privacy, some improvements possible';
    if (score >= 40) return 'Moderate privacy, consider reviewing settings';
    return 'Low privacy, review your settings';
  }

  void _showPrivacyScore() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your privacy score is calculated based on your current settings. '
              'The more data you share and permissions you grant, the lower your score.',
            ),
            const SizedBox(height: 16),
            Text(
              'Current Score: ${_calculatePrivacyScore()}/100',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDataDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Text(
          'We\'ll prepare a copy of your data and send it to your registered email address. '
          'This may take up to 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data download requested. Check your email.'),
                  backgroundColor: Color(0xFF638ECB),
                ),
              );
            },
            child: const Text('Request Download'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This will permanently delete all your data including profile, progress, and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle data deletion
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    // Navigate to privacy policy
  }

  void _showTermsOfService() {
    // Navigate to terms of service
  }
}