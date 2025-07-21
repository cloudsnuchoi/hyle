import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/amplify_service.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await AmplifyService().configureAmplify();
  } catch (e) {
    print('Amplify configuration error: $e');
  }
  
  runApp(const ProviderScope(child: TestAmplifyApp()));
}

class TestAmplifyApp extends ConsumerWidget {
  const TestAmplifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final themePreset = ref.watch(themePresetProvider);
    
    return MaterialApp(
      title: 'Hyle Auth Test',
      theme: AppTheme.lightTheme(preset: themePreset),
      darkTheme: AppTheme.darkTheme(preset: themePreset),
      themeMode: themeMode,
      home: const AuthTestScreen(),
    );
  }
}

class AuthTestScreen extends StatelessWidget {
  const AuthTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AWS Amplify 인증 테스트'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AWS Cognito 인증 테스트',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: const Text('회원가입 테스트', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('로그인 테스트', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 40),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('테스트 안내:', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('1. 회원가입: 실제 이메일 주소를 사용하세요'),
                      Text('2. 비밀번호: 8자 이상, 대소문자, 숫자, 특수문자 포함'),
                      Text('3. 이메일로 받은 인증 코드를 입력하세요'),
                      Text('4. 로그인 후 앱을 사용할 수 있습니다'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}