import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  int _currentStep = 0;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이용약관에 동의해주세요')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // TODO: Implement actual signup
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isLoading = false);
    
    // Navigate to onboarding
    // Navigator.pushReplacementNamed(context, '/onboarding');
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
              Color(0xFFF0F3FA), // primary50
              Color(0xFFD5DEEF), // primary100
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button and Progress
              _buildHeader(),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // Title
                        _buildTitle(),
                        
                        const SizedBox(height: 32),
                        
                        // Signup Form
                        _buildSignupForm(),
                        
                        const SizedBox(height: 24),
                        
                        // Terms Agreement
                        _buildTermsAgreement(),
                        
                        const SizedBox(height: 32),
                        
                        // Signup Button
                        _buildSignupButton(),
                        
                        const SizedBox(height: 24),
                        
                        // Login Link
                        _buildLoginLink(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < 2 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? const Color(0xFF395886) // primary500
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildTitle() {
    final titles = [
      '계정 정보 입력',
      '비밀번호 설정',
      '약관 동의',
    ];
    
    return Column(
      children: [
        Text(
          titles[_currentStep],
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF262626), // gray800
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'HYLE과 함께 학습을 시작해보세요',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF737373).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Step 1: Name & Email
          if (_currentStep == 0) ...[
            _buildTextField(
              controller: _nameController,
              hintText: '이름',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이름을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              hintText: '이메일',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력해주세요';
                }
                if (!value.contains('@')) {
                  return '올바른 이메일 형식이 아닙니다';
                }
                return null;
              },
            ),
          ],
          
          // Step 2: Password
          if (_currentStep == 1) ...[
            _buildTextField(
              controller: _passwordController,
              hintText: '비밀번호',
              prefixIcon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible 
                    ? Icons.visibility_off_outlined 
                    : Icons.visibility_outlined,
                  color: const Color(0xFF737373),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호를 입력해주세요';
                }
                if (value.length < 8) {
                  return '비밀번호는 8자 이상이어야 합니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _confirmPasswordController,
              hintText: '비밀번호 확인',
              prefixIcon: Icons.lock_outline,
              obscureText: !_isConfirmPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible 
                    ? Icons.visibility_off_outlined 
                    : Icons.visibility_outlined,
                  color: const Color(0xFF737373),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return '비밀번호가 일치하지 않습니다';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildPasswordStrength(),
          ],
          
          // Step 3: Terms
          if (_currentStep == 2) ...[
            _buildTermsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF262626),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF737373).withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF638ECB), // primary400
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrength() {
    final password = _passwordController.text;
    int strength = 0;
    String message = '비밀번호 강도';
    Color color = const Color(0xFFE5E5E5);
    
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*()]'))) strength++;
    
    switch (strength) {
      case 1:
        message = '약함';
        color = Colors.red;
        break;
      case 2:
        message = '보통';
        color = Colors.orange;
        break;
      case 3:
        message = '강함';
        color = Colors.blue;
        break;
      case 4:
        message = '매우 강함';
        color = Colors.green;
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength / 4,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 4,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '• 8자 이상\n• 대문자 포함\n• 숫자 포함\n• 특수문자 포함',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF737373).withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsSection() {
    return Column(
      children: [
        _buildTermsItem(
          title: '전체 동의',
          isChecked: _agreeToTerms,
          onChanged: (value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
          isMain: true,
        ),
        const Divider(height: 32),
        _buildTermsItem(
          title: '[필수] 이용약관 동의',
          isChecked: _agreeToTerms,
          onChanged: null,
        ),
        _buildTermsItem(
          title: '[필수] 개인정보 처리방침 동의',
          isChecked: _agreeToTerms,
          onChanged: null,
        ),
        _buildTermsItem(
          title: '[선택] 마케팅 정보 수신 동의',
          isChecked: _agreeToTerms,
          onChanged: null,
        ),
      ],
    );
  }

  Widget _buildTermsItem({
    required String title,
    required bool isChecked,
    required void Function(bool?)? onChanged,
    bool isMain = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: const Color(0xFF395886),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMain ? 16 : 14,
                fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF262626),
              ),
            ),
          ),
          if (!isMain)
            TextButton(
              onPressed: () {
                // Show terms detail
              },
              child: const Text(
                '보기',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF638ECB),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTermsAgreement() {
    if (_currentStep != 2) return const SizedBox.shrink();
    return const SizedBox.shrink(); // Already included in form
  }

  Widget _buildSignupButton() {
    final buttonText = _currentStep < 2 ? '다음' : '회원가입 완료';
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : () {
          if (_currentStep < 2) {
            if (_formKey.currentState!.validate()) {
              setState(() {
                _currentStep++;
              });
            }
          } else {
            _handleSignup();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF395886), // primary500
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF395886).withValues(alpha: 0.3),
        ),
        child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있으신가요?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF737373), // gray500
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            '로그인',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF395886), // primary500
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}