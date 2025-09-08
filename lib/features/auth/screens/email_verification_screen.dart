import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _iconController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleIn;
  late Animation<double> _iconRotation;

  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;
  String _email = 'user@example.com';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _iconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

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

    _scaleIn = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.linear,
    ));

    _controller.forward();
    _startResendTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimer = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    bool allFilled = _codeControllers.every((controller) => controller.text.isNotEmpty);
    if (allFilled) {
      _verifyCode();
    }
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isVerifying = true;
    });

    String code = _codeControllers.map((c) => c.text).join();
    
    // Simulate verification
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isVerifying = false;
      });

      // Show success and navigate
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF638ECB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Email Verified!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF395886),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your email has been successfully verified.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8AAEE0),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    if (_resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    // Simulate resending
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isResending = false;
      });
      _startResendTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent!'),
          backgroundColor: Color(0xFF638ECB),
        ),
      );
    }
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
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      _buildHeader(),
                      const SizedBox(height: 40),
                      Transform.translate(
                        offset: Offset(0, _slideIn.value),
                        child: Opacity(
                          opacity: _fadeIn.value,
                          child: Column(
                            children: [
                              _buildEmailIcon(),
                              const SizedBox(height: 32),
                              _buildInstructions(),
                              const SizedBox(height: 32),
                              _buildCodeInput(),
                              const SizedBox(height: 24),
                              _buildResendSection(),
                              const SizedBox(height: 32),
                              _buildVerifyButton(),
                              const SizedBox(height: 16),
                              _buildChangeEmailButton(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF395886)),
              onPressed: () => Navigator.pop(context),
            ),
            const Spacer(),
          ],
        ),
        const Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailIcon() {
    return Transform.scale(
      scale: _scaleIn.value,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF395886).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.email_outlined,
              color: Color(0xFF638ECB),
              size: 60,
            ),
            Positioned(
              right: 25,
              top: 25,
              child: AnimatedBuilder(
                animation: _iconController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _iconRotation.value,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8AAEE0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: [
        const Text(
          'Enter Verification Code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF395886),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a 6-digit code to',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFF8AAEE0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF638ECB),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 45,
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _codeControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _focusNodes[index].hasFocus
                      ? const Color(0xFF638ECB)
                      : const Color(0xFFD5DEEF),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD5DEEF),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF638ECB),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length > 1) {
                _codeControllers[index].text = value[0];
                _codeControllers[index].selection = TextSelection.fromPosition(
                  TextPosition(offset: _codeControllers[index].text.length),
                );
              }
              _onCodeChanged(value, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Didn\'t receive the code?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF8AAEE0),
          ),
        ),
        const SizedBox(width: 8),
        if (_resendTimer > 0)
          Text(
            'Resend in ${_resendTimer}s',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF638ECB),
            ),
          )
        else
          TextButton(
            onPressed: _isResending ? null : _resendCode,
            child: _isResending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
                    ),
                  )
                : const Text(
                    'Resend Code',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF638ECB),
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF8AAEE0), Color(0xFF638ECB)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF638ECB).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isVerifying ? null : _verifyCode,
          child: Center(
            child: _isVerifying
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text(
                    'Verify Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildChangeEmailButton() {
    return TextButton(
      onPressed: () {
        // Handle change email
      },
      child: const Text(
        'Change Email Address',
        style: TextStyle(
          color: Color(0xFF638ECB),
          fontSize: 14,
        ),
      ),
    );
  }
}