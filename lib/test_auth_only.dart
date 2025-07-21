import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// Amplify 설정을 직접 포함
const amplifyconfig = '''{
  "auth": {
    "user_pool_id": "ap-northeast-2_fGuO7nfAZ",
    "aws_region": "ap-northeast-2",
    "user_pool_client_id": "4jk2gfde1m4l1apn5o5u50g58o",
    "identity_pool_id": "ap-northeast-2:78a2f533-b086-4e2b-a46f-a08bce33b3be",
    "mfa_methods": [
      "TOTP"
    ],
    "standard_required_attributes": [
      "email"
    ],
    "username_attributes": [
      "email"
    ],
    "user_verification_types": [
      "email"
    ],
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
      print('Successfully configured');
    } on Exception catch (e) {
      print('Error configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amplify Auth Test',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isSignedUp = false;
  bool _showLoginButton = false;
  String _message = '';

  Future<void> signUp() async {
    try {
      final userAttributes = <AuthUserAttributeKey, String>{
        AuthUserAttributeKey.email: _emailController.text,
      };
      
      final result = await Amplify.Auth.signUp(
        username: _emailController.text,
        password: _passwordController.text,
        options: SignUpOptions(userAttributes: userAttributes),
      );
      
      setState(() {
        _isSignedUp = true;
        _message = '인증 코드가 이메일로 발송되었습니다.';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
      });
    }
  }

  Future<void> confirmSignUp() async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: _emailController.text,
        confirmationCode: _codeController.text,
      );
      
      setState(() {
        _message = '회원가입 완료! 이제 로그인할 수 있습니다.';
        _showLoginButton = true;
      });
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
      });
    }
  }

  Future<void> signIn() async {
    try {
      final result = await Amplify.Auth.signIn(
        username: _emailController.text,
        password: _passwordController.text,
      );
      
      setState(() {
        _message = '로그인 성공!';
      });
    } on AuthException catch (e) {
      setState(() {
        _message = e.message;
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
                  'Amplify 회원가입 테스트',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
                
                if (!_isSignedUp) ...[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      helperText: '8자 이상, 대소문자, 숫자, 특수문자 포함',
                      helperMaxLines: 2,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signUp,
                    child: const Text('회원가입'),
                  ),
                ] else ...[
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: '인증 코드',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: confirmSignUp,
                    child: const Text('인증 확인'),
                  ),
                ],
                
                const SizedBox(height: 20),
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.contains('오류') || _message.contains('invalid') 
                      ? Colors.red : Colors.green,
                  ),
                ),
                
                if (_showLoginButton) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('로그인 테스트'),
                  ),
                ],
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
    _codeController.dispose();
    super.dispose();
  }
}