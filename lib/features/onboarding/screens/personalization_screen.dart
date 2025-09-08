import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleIn;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  final int _totalSteps = 5;

  // Step 1: Learning Goals
  final Set<String> _selectedGoals = {};
  
  // Step 2: Subjects
  final Set<String> _selectedSubjects = {};
  
  // Step 3: Study Schedule
  String _studyFrequency = 'Daily';
  int _studyDuration = 30;
  String _preferredTime = 'Evening';
  
  // Step 4: Learning Style
  String _learningPace = 'Moderate';
  String _contentType = 'Mixed';
  bool _wantsReminders = true;
  
  // Step 5: Difficulty Level
  String _difficultyLevel = 'Intermediate';
  String _priorKnowledge = 'Some';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

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

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _controller.reset();
      _controller.forward();
      _progressController.forward();
    } else {
      _completePersonalization();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _controller.reset();
      _controller.forward();
    }
  }

  void _completePersonalization() {
    // Save personalization data and navigate to home
    Navigator.pushReplacementNamed(context, '/home');
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
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressBar(),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideIn.value),
                      child: Opacity(
                        opacity: _fadeIn.value,
                        child: _buildCurrentStep(),
                      ),
                    );
                  },
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Personalize Your Experience',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF638ECB),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: (_currentStep + _progressAnimation.value) / _totalSteps,
            backgroundColor: const Color(0xFFD5DEEF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
            minHeight: 6,
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildGoalsStep();
      case 1:
        return _buildSubjectsStep();
      case 2:
        return _buildScheduleStep();
      case 3:
        return _buildLearningStyleStep();
      case 4:
        return _buildDifficultyStep();
      default:
        return _buildGoalsStep();
    }
  }

  Widget _buildGoalsStep() {
    final goals = [
      {'id': 'exam', 'title': 'Exam Preparation', 'icon': Icons.school},
      {'id': 'skill', 'title': 'Skill Development', 'icon': Icons.build},
      {'id': 'career', 'title': 'Career Advancement', 'icon': Icons.trending_up},
      {'id': 'hobby', 'title': 'Personal Interest', 'icon': Icons.favorite},
      {'id': 'language', 'title': 'Language Learning', 'icon': Icons.language},
      {'id': 'certification', 'title': 'Get Certified', 'icon': Icons.card_membership},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are your learning goals?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select all that apply',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8AAEE0),
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final isSelected = _selectedGoals.contains(goal['id']);
              
              return Transform.scale(
                scale: _scaleIn.value,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(goal['id']);
                      } else {
                        _selectedGoals.add(goal['id'] as String);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF638ECB) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected
                              ? const Color(0xFF638ECB)
                              : const Color(0xFF395886))
                              .withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          goal['icon'] as IconData,
                          size: 40,
                          color: isSelected ? Colors.white : const Color(0xFF638ECB),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          goal['title'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF395886),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsStep() {
    final subjects = [
      'Mathematics', 'Science', 'History', 'Literature',
      'Programming', 'Business', 'Art', 'Music',
      'Psychology', 'Philosophy', 'Economics', 'Languages',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Which subjects interest you?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your preferred subjects',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8AAEE0),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: subjects.map((subject) {
              final isSelected = _selectedSubjects.contains(subject);
              
              return Transform.scale(
                scale: _scaleIn.value,
                child: FilterChip(
                  label: Text(subject),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSubjects.add(subject);
                      } else {
                        _selectedSubjects.remove(subject);
                      }
                    });
                  },
                  selectedColor: const Color(0xFF638ECB),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF395886),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Set your study schedule',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 24),
          _buildScheduleCard(
            title: 'Study Frequency',
            child: Row(
              children: ['Daily', 'Weekdays', '3-4 days', 'Weekends'].map((freq) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _studyFrequency = freq),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _studyFrequency == freq
                              ? const Color(0xFF638ECB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _studyFrequency == freq
                                ? const Color(0xFF638ECB)
                                : const Color(0xFFD5DEEF),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            freq,
                            style: TextStyle(
                              fontSize: 12,
                              color: _studyFrequency == freq
                                  ? Colors.white
                                  : const Color(0xFF395886),
                              fontWeight: _studyFrequency == freq
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _buildScheduleCard(
            title: 'Daily Study Time',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF395886),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF638ECB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_studyDuration min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF638ECB),
                    inactiveTrackColor: const Color(0xFFD5DEEF),
                    thumbColor: const Color(0xFF395886),
                    overlayColor: const Color(0xFF638ECB).withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _studyDuration.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 7,
                    onChanged: (value) => setState(() => _studyDuration = value.round()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildScheduleCard(
            title: 'Preferred Time',
            child: Row(
              children: ['Morning', 'Afternoon', 'Evening', 'Night'].map((time) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _preferredTime = time),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _preferredTime == time
                              ? const Color(0xFF638ECB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _preferredTime == time
                                ? const Color(0xFF638ECB)
                                : const Color(0xFFD5DEEF),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              fontSize: 12,
                              color: _preferredTime == time
                                  ? Colors.white
                                  : const Color(0xFF395886),
                              fontWeight: _preferredTime == time
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStyleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How do you prefer to learn?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 24),
          _buildStyleOption(
            title: 'Learning Pace',
            options: ['Slow', 'Moderate', 'Fast'],
            selected: _learningPace,
            onSelect: (value) => setState(() => _learningPace = value),
          ),
          const SizedBox(height: 16),
          _buildStyleOption(
            title: 'Content Type',
            options: ['Visual', 'Text', 'Audio', 'Mixed'],
            selected: _contentType,
            onSelect: (value) => setState(() => _contentType = value),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF395886).withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Study Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF395886),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Get notifications to stay on track',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8AAEE0),
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _wantsReminders,
                  onChanged: (value) => setState(() => _wantsReminders = value),
                  activeColor: const Color(0xFF638ECB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s your level?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 24),
          _buildLevelCard(
            level: 'Beginner',
            description: 'New to the subject',
            icon: Icons.star_border,
            isSelected: _difficultyLevel == 'Beginner',
            onTap: () => setState(() => _difficultyLevel = 'Beginner'),
          ),
          const SizedBox(height: 12),
          _buildLevelCard(
            level: 'Intermediate',
            description: 'Some experience',
            icon: Icons.star_half,
            isSelected: _difficultyLevel == 'Intermediate',
            onTap: () => setState(() => _difficultyLevel = 'Intermediate'),
          ),
          const SizedBox(height: 12),
          _buildLevelCard(
            level: 'Advanced',
            description: 'Experienced learner',
            icon: Icons.star,
            isSelected: _difficultyLevel == 'Advanced',
            onTap: () => setState(() => _difficultyLevel = 'Advanced'),
          ),
          const SizedBox(height: 24),
          const Text(
            'Prior Knowledge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['None', 'Some', 'Extensive'].map((knowledge) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _priorKnowledge = knowledge),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _priorKnowledge == knowledge
                            ? const Color(0xFF638ECB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _priorKnowledge == knowledge
                              ? const Color(0xFF638ECB)
                              : const Color(0xFFD5DEEF),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          knowledge,
                          style: TextStyle(
                            fontSize: 14,
                            color: _priorKnowledge == knowledge
                                ? Colors.white
                                : const Color(0xFF395886),
                            fontWeight: _priorKnowledge == knowledge
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStyleOption({
    required String title,
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: options.map((option) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => onSelect(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected == option
                            ? const Color(0xFF638ECB)
                            : const Color(0xFFF0F3FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 12,
                            color: selected == option
                                ? Colors.white
                                : const Color(0xFF395886),
                            fontWeight: selected == option
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required String level,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF638ECB) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF638ECB) : const Color(0xFFD5DEEF),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected
                  ? const Color(0xFF638ECB)
                  : const Color(0xFF395886))
                  .withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : const Color(0xFF638ECB),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : const Color(0xFF395886),
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFF8AAEE0),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF638ECB), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: Color(0xFF638ECB),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF638ECB),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _canProceed() ? 4 : 0,
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? 'Get Started' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedGoals.isNotEmpty;
      case 1:
        return _selectedSubjects.isNotEmpty;
      case 2:
      case 3:
      case 4:
        return true;
      default:
        return false;
    }
  }
}