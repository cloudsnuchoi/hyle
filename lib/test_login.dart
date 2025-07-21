import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

void main() {
  runApp(const LoginTestApp());
}

class LoginTestApp extends StatefulWidget {
  const LoginTestApp({super.key});

  @override
  State<LoginTestApp> createState() => _LoginTestAppState();
}

class _LoginTestAppState extends State<LoginTestApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      if (!Amplify.isConfigured) {
        final auth = AmplifyAuthCognito();
        await Amplify.addPlugin(auth);
        
        const amplifyconfig = '''{
          "auth": {
            "user_pool_id": "ap-northeast-2_fGuO7nfAZ",
            "aws_region": "ap-northeast-2",
            "user_pool_client_id": "4jk2gfde1m4l1apn5o5u50g58o",
            "identity_pool_id": "ap-northeast-2:78a2f533-b086-4e2b-a46f-a08bce33b3be",
            "mfa_methods": ["TOTP"],
            "standard_required_attributes": ["email"],
            "username_attributes": ["email"],
            "user_verification_types": ["email"],
            "groups": [],
            "mfa_configuration": "OPTIONAL",
            "password_policy": {
              "min_length": 8,
              "require_lowercase": true,
              "require_numbers": true,
              "require_symbols": true,
              "require_uppercase": true
            },
            "unauthenticated_identities_enabled": true
          },
          "version": "1.4"
        }''';
        
        await Amplify.configure(amplifyconfig);
        print('Amplify configured successfully');
      }
    } on Exception catch (e) {
      print('Error configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amplify 로그인 테스트',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  bool _isLoading = false;
  bool _isSignedIn = false;

  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await Amplify.Auth.signIn(
        username: _emailController.text,
        password: _passwordController.text,
      );
      
      if (result.isSignedIn) {
        setState(() {
          _message = '로그인 성공!';
          _isSignedIn = true;
        });
        
        // 현재 사용자 정보 가져오기
        final user = await Amplify.Auth.getCurrentUser();
        setState(() {
          _message += '\n사용자 ID: ${user.userId}';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _message = '로그인 실패: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      setState(() {
        _message = '로그아웃되었습니다';
        _isSignedIn = false;
      });
    } on AuthException catch (e) {
      setState(() {
        _message = '로그아웃 실패: ${e.message}';
      });
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      setState(() {
        _isSignedIn = session.isSignedIn;
        _message = session.isSignedIn ? '현재 로그인 상태입니다' : '로그인이 필요합니다';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = '인증 상태 확인 실패: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '로그인 테스트',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
                
                if (!_isSignedIn) ...[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? null : signIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator()
                      : const Text('로그인'),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('로그아웃'),
                  ),
                ],
                
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: checkAuthStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('인증 상태 확인'),
                ),
                
                const SizedBox(height: 20),
                
                if (_message.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _message.contains('실패') || _message.contains('오류')
                        ? Colors.red.shade100 
                        : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _message,
                      style: TextStyle(
                        color: _message.contains('실패') || _message.contains('오류')
                          ? Colors.red.shade900 
                          : Colors.green.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}