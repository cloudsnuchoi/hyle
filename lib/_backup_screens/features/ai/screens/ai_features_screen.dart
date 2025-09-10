import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gap.dart';
import '../../../services/ai_service_stub.dart';
import '../../../services/supabase_service.dart';
import '../../../providers/auth_provider.dart';

class AIFeaturesScreen extends ConsumerStatefulWidget {
  const AIFeaturesScreen({super.key});

  @override
  ConsumerState<AIFeaturesScreen> createState() => _AIFeaturesScreenState();
}

class _AIFeaturesScreenState extends ConsumerState<AIFeaturesScreen> {
  bool _isServiceConfigured = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    setState(() {
      // TODO: Check Supabase configuration
      _isServiceConfigured = SupabaseService().client.auth.currentUser != null;
    });
  }

  Future<void> _configureService() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // TODO: Initialize Supabase service if needed
      await Future.delayed(const Duration(seconds: 1)); // Placeholder
      setState(() {
        _isServiceConfigured = true;
        _successMessage = '서비스 구성이 완료되었습니다!';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '서비스 구성 실패: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAIFeature() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final user = ref.read(authStateProvider).user;
      
      if (user == null) {
        throw Exception('로그인이 필요합니다');
      }

      // Test study plan generation
      final studyPlan = await aiService.generateStudyPlan(
        userPrompt: '내일 수학 시험이 있어요. 오늘 3시간 공부할 수 있습니다.',
        context: UserContext(
          level: 10,
          learningType: 'VISUAL',
          availableHours: 3.0,
          subjects: ['Mathematics'],
          examDate: DateTime.now().add(const Duration(days: 1)),
        ),
      );

      setState(() {
        _successMessage = '''
AI 테스트 성공!
생성된 학습 계획:
- 총 ${studyPlan.totalHours}시간
- ${studyPlan.tasks.length}개의 학습 작업
- 추천사항: ${studyPlan.recommendations.join(', ')}
''';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'AI 기능 테스트 실패: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 기능 베타 테스트'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            Gap.md,
            _buildFeaturesList(),
            Gap.md,
            _buildActionButtons(),
            if (_errorMessage != null) ...[
              Gap.md,
              _buildErrorMessage(),
            ],
            if (_successMessage != null) ...[
              Gap.md,
              _buildSuccessMessage(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isServiceConfigured ? Icons.check_circle : Icons.warning,
                  color: _isServiceConfigured ? Colors.green : Colors.orange,
                ),
                Gap.sm,
                Text(
                  'Amplify 상태',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            Gap.sm,
            Text(
              _isServiceConfigured
                  ? 'Amplify가 구성되어 AI 기능을 사용할 준비가 되었습니다.'
                  : 'Amplify 구성이 필요합니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용 가능한 AI 기능',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Gap.md,
            _buildFeatureItem(
              icon: Icons.calendar_today,
              title: 'AI 학습 계획 생성',
              description: '자연어로 학습 계획을 요청하고 개인화된 일정을 받습니다',
            ),
            _buildFeatureItem(
              icon: Icons.analytics,
              title: '실시간 세션 분석',
              description: '학습 중 생산성과 집중도를 실시간으로 분석합니다',
            ),
            _buildFeatureItem(
              icon: Icons.timer,
              title: '작업 시간 예측',
              description: '과거 데이터를 기반으로 작업 완료 시간을 예측합니다',
            ),
            _buildFeatureItem(
              icon: Icons.psychology,
              title: '학습 패턴 분석',
              description: '학습 패턴을 분석하고 개선 사항을 추천합니다',
            ),
            _buildFeatureItem(
              icon: Icons.lightbulb,
              title: '실시간 학습 조언',
              description: '현재 상황에 맞는 맞춤형 학습 조언을 제공합니다',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          Gap.sm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isServiceConfigured)
          ElevatedButton(
            onPressed: _isLoading ? null : _configureService,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Amplify 구성하기'),
          ),
        if (_isServiceConfigured) ...[
          ElevatedButton(
            onPressed: _isLoading ? null : _testAIFeature,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('AI 기능 테스트'),
          ),
          Gap.sm,
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/ai-planner');
            },
            child: const Text('AI 학습 플래너 열기'),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          Gap.sm,
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
          Gap.sm,
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }
}