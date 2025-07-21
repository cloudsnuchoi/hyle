import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'services/amplify_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Amplify 초기화
  try {
    await AmplifyService().configureAmplify();
    print('Amplify configured successfully');
  } catch (e) {
    print('Amplify configuration error: $e');
  }
  
  runApp(const SimpleAuthApp());
}

class SimpleAuthApp extends StatelessWidget {
  const SimpleAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyle 회원가입 테스트',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const SignUpTestScreen(),
    );
  }
}

class SignUpTestScreen extends StatefulWidget {
  const SignUpTestScreen({super.key});

  @override
  State<SignUpTestScreen> createState() => _SignUpTestScreenState();
}

class _SignUpTestScreenState extends State<SignUpTestScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isLoading = false;
  bool _showConfirmation = false;
  String _message = '';

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await AmplifyService().signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      setState(() {
        _showConfirmation = true;
        _message = '이메일로 인증 코드가 발송되었습니다.';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = '오류: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _message = '오류: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmSignUp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await AmplifyService().confirmSignUp(
        email: _emailController.text,
        confirmationCode: _codeController.text,
      );

      setState(() {
        _message = '인증 완료! 이제 로그인할 수 있습니다.';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = '오류: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _message = '오류: $e';
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
        title: const Text('Hyle 회원가입 테스트'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 80,
                color: Colors.purple,
              ),
              const SizedBox(height: 32),
              
              if (!_showConfirmation) ...[
                // 회원가입 폼
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    hintText: 'your@email.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    hintText: '8자 이상, 대소문자, 숫자, 특수문자',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    hintText: '표시될 이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('회원가입'),
                ),
              ] else ...[
                // 인증 코드 입력
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '인증 코드',
                    hintText: '6자리 숫자',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmSignUp,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('인증 완료'),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // 메시지 표시
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _message.contains('오류') 
                      ? Colors.red.shade100 
                      : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('오류') 
                        ? Colors.red.shade900 
                        : Colors.green.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // 안내사항
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '테스트 안내:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• 실제 이메일을 사용하세요'),
                    Text('• 비밀번호: Test1234!'),
                    Text('• 이메일로 6자리 코드가 발송됩니다'),
                    Text('• 스팸함도 확인하세요'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}