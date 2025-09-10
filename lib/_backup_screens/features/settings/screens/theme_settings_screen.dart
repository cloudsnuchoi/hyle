import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/theme_provider.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final currentPreset = ref.watch(themePresetProvider);
    final availablePresets = ref.watch(availablePresetsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('테마 설정'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 다크모드 설정
            Card(
              child: Padding(
                padding: AppSpacing.paddingMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('화면 모드', style: AppTypography.titleMedium),
                    AppSpacing.verticalGapMD,
                    RadioListTile<ThemeMode>(
                      title: const Text('시스템 설정 따르기'),
                      value: ThemeMode.system,
                      groupValue: currentThemeMode,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(value!);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('라이트 모드'),
                      value: ThemeMode.light,
                      groupValue: currentThemeMode,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(value!);
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: const Text('다크 모드'),
                      value: ThemeMode.dark,
                      groupValue: currentThemeMode,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).setThemeMode(value!);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 테마 프리셋 선택
            Text('테마 스타일', style: AppTypography.titleLarge),
            AppSpacing.verticalGapMD,
            
            // 추천 테마들 (상위 5개)
            ...availablePresets.take(5).map((preset) => 
              _ThemePresetCard(
                preset: preset,
                isSelected: currentPreset == preset,
                onTap: () {
                  ref.read(themePresetProvider.notifier).setThemePreset(preset);
                },
              ),
            ),
            
            AppSpacing.verticalGapLG,
            
            // 기타 테마들
            if (availablePresets.length > 5) ...[
              Text('기타 테마', style: AppTypography.titleMedium),
              AppSpacing.verticalGapMD,
              ...availablePresets.skip(5).map((preset) => 
                _ThemePresetCard(
                  preset: preset,
                  isSelected: currentPreset == preset,
                  onTap: () {
                    ref.read(themePresetProvider.notifier).setThemePreset(preset);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ThemePresetCard extends StatelessWidget {
  final ThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _ThemePresetCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = getPresetPreviewColors(preset);
    final description = getPresetDescription(preset);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? BorderSide(color: preset.primary, width: 2)
          : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Row(
            children: [
              // 색상 미리보기
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: colors[0].withOpacity(0.1),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors[0],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors[1],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 20,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colors[2],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              AppSpacing.horizontalGapMD,
              
              // 테마 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          preset.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected) ...[
                          AppSpacing.horizontalGapSM,
                          Icon(
                            Icons.check_circle,
                            color: preset.primary,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.verticalGapSM,
                    Text(
                      description,
                      style: AppTypography.caption.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
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
}