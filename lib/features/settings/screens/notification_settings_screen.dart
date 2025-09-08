import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;

  // Notification settings
  bool _allNotifications = true;
  bool _studyReminders = true;
  bool _goalDeadlines = true;
  bool _achievementAlerts = true;
  bool _socialUpdates = true;
  bool _systemUpdates = false;
  bool _promotionalOffers = false;
  
  // Timing settings
  bool _doNotDisturb = false;
  TimeOfDay _dndStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEnd = const TimeOfDay(hour: 7, minute: 0);
  
  // Frequency settings
  String _reminderFrequency = 'Daily';
  String _summaryFrequency = 'Weekly';
  
  // Channel settings
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;
  bool _inAppNotifications = true;

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

  void _toggleAllNotifications(bool value) {
    setState(() {
      _allNotifications = value;
      if (!value) {
        _studyReminders = false;
        _goalDeadlines = false;
        _achievementAlerts = false;
        _socialUpdates = false;
        _systemUpdates = false;
        _promotionalOffers = false;
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
                          'Notification Settings',
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
                                _buildMasterSwitch(),
                                const SizedBox(height: 24),
                                _buildNotificationTypes(),
                                const SizedBox(height: 24),
                                _buildNotificationChannels(),
                                const SizedBox(height: 24),
                                _buildTimingSettings(),
                                const SizedBox(height: 24),
                                _buildFrequencySettings(),
                                const SizedBox(height: 24),
                                _buildAdvancedSettings(),
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

  Widget _buildMasterSwitch() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _allNotifications
              ? [const Color(0xFF8AAEE0), const Color(0xFF638ECB)]
              : [const Color(0xFFBBBBBB), const Color(0xFF999999)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_allNotifications
                ? const Color(0xFF638ECB)
                : const Color(0xFF999999))
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _allNotifications ? 'Enabled' : 'Disabled',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: _allNotifications,
              onChanged: _toggleAllNotifications,
              activeColor: Colors.white,
              activeTrackColor: Colors.white.withValues(alpha: 0.5),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypes() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.category, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Notification Types',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          _buildNotificationToggle(
            icon: Icons.alarm,
            title: 'Study Reminders',
            subtitle: 'Daily study time reminders',
            value: _studyReminders,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _studyReminders = value),
          ),
          _buildNotificationToggle(
            icon: Icons.flag,
            title: 'Goal Deadlines',
            subtitle: 'Upcoming goal notifications',
            value: _goalDeadlines,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _goalDeadlines = value),
          ),
          _buildNotificationToggle(
            icon: Icons.emoji_events,
            title: 'Achievement Alerts',
            subtitle: 'New badges and rewards',
            value: _achievementAlerts,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _achievementAlerts = value),
          ),
          _buildNotificationToggle(
            icon: Icons.people,
            title: 'Social Updates',
            subtitle: 'Friend activity and messages',
            value: _socialUpdates,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _socialUpdates = value),
          ),
          _buildNotificationToggle(
            icon: Icons.system_update,
            title: 'System Updates',
            subtitle: 'App updates and maintenance',
            value: _systemUpdates,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _systemUpdates = value),
          ),
          _buildNotificationToggle(
            icon: Icons.local_offer,
            title: 'Promotional Offers',
            subtitle: 'Special deals and discounts',
            value: _promotionalOffers,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _promotionalOffers = value),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationChannels() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.send, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Notification Channels',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          _buildChannelToggle(
            icon: Icons.phone_android,
            title: 'Push Notifications',
            value: _pushNotifications,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _pushNotifications = value),
          ),
          _buildChannelToggle(
            icon: Icons.email,
            title: 'Email Notifications',
            value: _emailNotifications,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _emailNotifications = value),
          ),
          _buildChannelToggle(
            icon: Icons.sms,
            title: 'SMS Notifications',
            value: _smsNotifications,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _smsNotifications = value),
          ),
          _buildChannelToggle(
            icon: Icons.notifications_active,
            title: 'In-App Notifications',
            value: _inAppNotifications,
            enabled: _allNotifications,
            onChanged: (value) => setState(() => _inAppNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingSettings() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Quiet Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.do_not_disturb, color: Color(0xFF638ECB)),
            title: const Text(
              'Do Not Disturb',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF395886),
              ),
            ),
            subtitle: Text(
              _doNotDisturb
                  ? 'Active from ${_dndStart.format(context)} to ${_dndEnd.format(context)}'
                  : 'Receive notifications anytime',
              style: const TextStyle(fontSize: 14),
            ),
            value: _doNotDisturb,
            onChanged: _allNotifications
                ? (value) => setState(() => _doNotDisturb = value)
                : null,
            activeColor: const Color(0xFF638ECB),
          ),
          if (_doNotDisturb) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.bedtime, color: Color(0xFF8AAEE0)),
              title: const Text(
                'Start Time',
                style: TextStyle(fontSize: 15),
              ),
              trailing: TextButton(
                onPressed: _allNotifications
                    ? () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _dndStart,
                        );
                        if (time != null) {
                          setState(() => _dndStart = time);
                        }
                      }
                    : null,
                child: Text(
                  _dndStart.format(context),
                  style: const TextStyle(
                    color: Color(0xFF638ECB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny, color: Color(0xFF8AAEE0)),
              title: const Text(
                'End Time',
                style: TextStyle(fontSize: 15),
              ),
              trailing: TextButton(
                onPressed: _allNotifications
                    ? () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _dndEnd,
                        );
                        if (time != null) {
                          setState(() => _dndEnd = time);
                        }
                      }
                    : null,
                child: Text(
                  _dndEnd.format(context),
                  style: const TextStyle(
                    color: Color(0xFF638ECB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFrequencySettings() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.repeat, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Frequency',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
              ],
            ),
          ),
          _buildFrequencyTile(
            title: 'Study Reminders',
            value: _reminderFrequency,
            options: ['Hourly', 'Daily', 'Weekly', 'Never'],
            onChanged: (value) => setState(() => _reminderFrequency = value!),
          ),
          _buildFrequencyTile(
            title: 'Progress Summary',
            value: _summaryFrequency,
            options: ['Daily', 'Weekly', 'Monthly', 'Never'],
            onChanged: (value) => setState(() => _summaryFrequency = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
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
                Icon(Icons.settings_applications, color: Color(0xFF638ECB)),
                SizedBox(width: 12),
                Text(
                  'Advanced',
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
            leading: const Icon(Icons.history, color: Color(0xFF8AAEE0)),
            title: const Text('Notification History'),
            subtitle: const Text('View past notifications'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.science, color: Color(0xFF8AAEE0)),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _allNotifications
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Test notification sent!'),
                        backgroundColor: Color(0xFF638ECB),
                      ),
                    );
                  }
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.restore, color: Color(0xFF8AAEE0)),
            title: const Text('Reset to Default'),
            subtitle: const Text('Restore default settings'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings?'),
                  content: const Text('This will restore all notification settings to their default values.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _resetToDefaults();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? const Color(0xFF8AAEE0) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? const Color(0xFF395886) : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: enabled ? const Color(0xFF8AAEE0) : Colors.grey.shade400,
        ),
      ),
      trailing: Switch(
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(0xFF638ECB),
      ),
    );
  }

  Widget _buildChannelToggle({
    required IconData icon,
    required String title,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled ? const Color(0xFF8AAEE0) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: enabled ? const Color(0xFF395886) : Colors.grey,
        ),
      ),
      trailing: Switch(
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(0xFF638ECB),
      ),
    );
  }

  Widget _buildFrequencyTile({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: _allNotifications ? const Color(0xFF395886) : Colors.grey,
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
                style: TextStyle(
                  fontSize: 14,
                  color: _allNotifications ? const Color(0xFF395886) : Colors.grey,
                ),
              ),
            );
          }).toList(),
          onChanged: _allNotifications ? onChanged : null,
          underline: const SizedBox(),
          icon: Icon(
            Icons.arrow_drop_down,
            color: _allNotifications ? const Color(0xFF638ECB) : Colors.grey,
          ),
        ),
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _allNotifications = true;
      _studyReminders = true;
      _goalDeadlines = true;
      _achievementAlerts = true;
      _socialUpdates = true;
      _systemUpdates = false;
      _promotionalOffers = false;
      _doNotDisturb = false;
      _dndStart = const TimeOfDay(hour: 22, minute: 0);
      _dndEnd = const TimeOfDay(hour: 7, minute: 0);
      _reminderFrequency = 'Daily';
      _summaryFrequency = 'Weekly';
      _pushNotifications = true;
      _emailNotifications = false;
      _smsNotifications = false;
      _inAppNotifications = true;
    });
  }
}