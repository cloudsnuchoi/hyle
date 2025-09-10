import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
  final String grade;
  final List<String> subjects;
  
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
  
  void updateProfile({
    String? imagePath,
    String? name,
    String? grade,
    List<String>? subjects,
  }) {
    state = state.copyWith(
      imagePath: imagePath,
      name: name,
      grade: grade,
      subjects: subjects,
    );
  }
  
  void updateProfileImage(String imagePath) {
    state = state.copyWith(imagePath: imagePath);
  }
}

class ProfileScreenSimple extends ConsumerWidget {
  const ProfileScreenSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfile = ref.watch(userProfileProvider);
    final learningType = ref.watch(currentLearningTypeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 프로필 이미지
                    Stack(
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
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // 이름과 학년
                    Text(
                      userProfile.name,
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProfile.grade,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
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
            
            const SizedBox(height: 24),
            
            // 학습 유형
            Text('학습 유형', style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            
            Card(
              child: learningType == null
                  ? ListTile(
                      leading: Icon(
                        Icons.psychology_outlined,
                        color: theme.primaryColor,
                      ),
                      title: const Text('학습 유형 테스트'),
                      subtitle: const Text('나에게 맞는 학습법 찾기'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningTypeTestScreen(),
                          ),
                        );
                      },
                    )
                  : InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningTypeResultDetailScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
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
                            const SizedBox(width: 16),
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
                      ),
                    ),
            ),
            
          ],
        ),
      ),
    );
  }
  
  void _showEditProfile(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const ProfileEditDialog(),
    );
  }
}