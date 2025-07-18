import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/user_stats_provider.dart';
import '../../../providers/learning_type_provider.dart';
import '../../learning_type/screens/learning_type_test_screen.dart';
import '../../learning_type/screens/learning_type_result_detail_screen.dart';
import '../widgets/theme_settings_dialog.dart';
import '../widgets/profile_edit_dialog.dart';

// 프로필 정보 Provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfile {
  final String? imagePath;
  final String name;
  final String grade; // 중1, 중2, 중3, 고1, 고2, 고3, 재수생, N수생, 대학생, 공시생, 자격증
  final List<String> subjects; // 과목 태그
  
  UserProfile({
    this.imagePath,
    this.name = '학습자',
    this.grade = '중학생',
    this.subjects = const [],
  });
  
  UserProfile copyWith({
    String? imagePath,
    String? name,
    String? grade,
    List<String>? subjects,
  }) {
    return UserProfile(
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      subjects: subjects ?? this.subjects,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile());
  
  void updateProfile(UserProfile profile) {
    state = profile;
  }
  
  Future<void> updateProfileImage(String imagePath) async {
    state = state.copyWith(imagePath: imagePath);
  }
}

class ProfileScreenImproved extends ConsumerWidget {
  const ProfileScreenImproved({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStats = ref.watch(userStatsProvider);
    final learningType = ref.watch(currentLearningTypeProvider);
    final userProfile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showThemeSettings(context, ref),
            tooltip: '테마 설정',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: AppSpacing.paddingLG,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // 프로필 이미지
                        GestureDetector(
                          onTap: () => _pickImage(context, ref),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: theme.primaryColor.withOpacity(0.1),
                                backgroundImage: userProfile.imagePath != null
                                    ? FileImage(File(userProfile.imagePath!))
                                    : null,
                                child: userProfile.imagePath == null
                                    ? Icon(
                                        Icons.person,
                                        size: 50,
                                        color: theme.primaryColor,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.horizontalGapMD,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    userProfile.name,
                                    style: AppTypography.titleLarge,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      userProfile.grade,
                                      style: AppTypography.labelMedium.copyWith(
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Level ${userStats.level}',
                                    style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${userStats.currentStreak} 일',
                                    style: AppTypography.body,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: userStats.getLevelProgress(),
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${userStats.totalXP} / ${userStats.getXPForNextLevel()} XP',
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // 과목 태그
                    if (userProfile.subjects.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: userProfile.subjects.map((subject) {
                          return Chip(
                            label: Text(subject),
                            backgroundColor: theme.primaryColor.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.primaryColor,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditProfile(context, ref),
                        icon: const Icon(Icons.edit),
                        label: const Text('프로필 편집'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // Learning Type Section
            Text('학습 유형', style: AppTypography.titleLarge),
            AppSpacing.verticalGapMD,
            
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  children: [
                    if (learningType == null)
                      ListTile(
                        leading: Icon(
                          Icons.psychology_outlined,
                          color: theme.primaryColor,
                        ),
                        title: const Text('학습 유형 테스트'),
                        subtitle: const Text('나에게 맞는 학습법 찾기'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearningTypeTestScreen(),
                            ),
                          );
                        },
                      )
                    else
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LearningTypeResultDetailScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: AppSpacing.paddingMD,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.psychology,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  AppSpacing.horizontalGapMD,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          learningType.name,
                                          style: AppTypography.titleMedium,
                                        ),
                                        Text(
                                          learningType.id,
                                          style: AppTypography.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: theme.primaryColor,
                                    size: 16,
                                  ),
                                ],
                              ),
                              AppSpacing.verticalGapSM,
                              Text(
                                learningType.getDescription(),
                                style: AppTypography.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 설정 메뉴
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('테마 설정'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showThemeSettings(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('알림 설정'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('알림 설정 준비 중')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('앱 정보'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Hyle',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Hyle Team',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showThemeSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSettingsDialog(),
    );
  }
  
  void _showEditProfile(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ProfileEditDialog(),
    );
  }
  
  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  ref.read(userProfileProvider.notifier).updateProfileImage(image.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  ref.read(userProfileProvider.notifier).updateProfileImage(image.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}