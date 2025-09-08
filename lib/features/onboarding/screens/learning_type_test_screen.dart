import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LearningTypeTestScreen extends ConsumerStatefulWidget {
  const LearningTypeTestScreen({super.key});

  @override
  ConsumerState<LearningTypeTestScreen> createState() => _LearningTypeTestScreenState();
}

class _LearningTypeTestScreenState extends ConsumerState<LearningTypeTestScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late AnimationController _resultController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideIn;
  late Animation<double> _scaleIn;
  late Animation<double> _progressAnimation;

  int _currentQuestionIndex = 0;
  final Map<String, int> _scores = {
    'visual': 0,
    'auditory': 0,
    'kinesthetic': 0,
    'reading': 0,
    'social': 0,
    'solitary': 0,
    'logical': 0,
    'creative': 0,
  };

  String? _learningType;
  bool _showResult = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'When learning something new, I prefer to:',
      'answers': [
        {'text': 'Watch videos or demonstrations', 'type': 'visual'},
        {'text': 'Listen to explanations or podcasts', 'type': 'auditory'},
        {'text': 'Try it myself hands-on', 'type': 'kinesthetic'},
        {'text': 'Read instructions or manuals', 'type': 'reading'},
      ],
    },
    {
      'question': 'I remember things best when I:',
      'answers': [
        {'text': 'See diagrams and charts', 'type': 'visual'},
        {'text': 'Hear them explained', 'type': 'auditory'},
        {'text': 'Practice or do them', 'type': 'kinesthetic'},
        {'text': 'Write them down', 'type': 'reading'},
      ],
    },
    {
      'question': 'My ideal study environment is:',
      'answers': [
        {'text': 'With a study group', 'type': 'social'},
        {'text': 'Alone in a quiet space', 'type': 'solitary'},
        {'text': 'With background music', 'type': 'auditory'},
        {'text': 'Organized with visual aids', 'type': 'visual'},
      ],
    },
    {
      'question': 'When solving problems, I tend to:',
      'answers': [
        {'text': 'Use logic and reasoning', 'type': 'logical'},
        {'text': 'Think outside the box', 'type': 'creative'},
        {'text': 'Draw or visualize solutions', 'type': 'visual'},
        {'text': 'Talk through the problem', 'type': 'auditory'},
      ],
    },
    {
      'question': 'I prefer assignments that involve:',
      'answers': [
        {'text': 'Creating presentations', 'type': 'visual'},
        {'text': 'Writing essays', 'type': 'reading'},
        {'text': 'Building or making things', 'type': 'kinesthetic'},
        {'text': 'Group discussions', 'type': 'social'},
      ],
    },
    {
      'question': 'When I need to focus, I:',
      'answers': [
        {'text': 'Need complete silence', 'type': 'solitary'},
        {'text': 'Like some background noise', 'type': 'auditory'},
        {'text': 'Move around or fidget', 'type': 'kinesthetic'},
        {'text': 'Organize my workspace', 'type': 'logical'},
      ],
    },
    {
      'question': 'I express ideas best through:',
      'answers': [
        {'text': 'Art or design', 'type': 'creative'},
        {'text': 'Written words', 'type': 'reading'},
        {'text': 'Verbal explanation', 'type': 'auditory'},
        {'text': 'Physical demonstration', 'type': 'kinesthetic'},
      ],
    },
    {
      'question': 'My approach to learning is:',
      'answers': [
        {'text': 'Step-by-step and systematic', 'type': 'logical'},
        {'text': 'Intuitive and imaginative', 'type': 'creative'},
        {'text': 'Collaborative and interactive', 'type': 'social'},
        {'text': 'Independent and self-paced', 'type': 'solitary'},
      ],
    },
  ];

  final Map<String, Map<String, dynamic>> _learningTypes = {
    'Visual Explorer': {
      'primary': 'visual',
      'secondary': 'creative',
      'description': 'You learn best through images, diagrams, and visual representations.',
      'icon': Icons.remove_red_eye,
      'color': const Color(0xFF8AAEE0),
    },
    'Auditory Processor': {
      'primary': 'auditory',
      'secondary': 'social',
      'description': 'You excel when learning through listening and verbal communication.',
      'icon': Icons.headphones,
      'color': const Color(0xFF638ECB),
    },
    'Kinesthetic Doer': {
      'primary': 'kinesthetic',
      'secondary': 'creative',
      'description': 'You learn by doing and need hands-on experiences.',
      'icon': Icons.sports_handball,
      'color': const Color(0xFF395886),
    },
    'Reading Scholar': {
      'primary': 'reading',
      'secondary': 'logical',
      'description': 'You prefer learning through written text and documentation.',
      'icon': Icons.menu_book,
      'color': const Color(0xFF8AAEE0),
    },
    'Social Collaborator': {
      'primary': 'social',
      'secondary': 'auditory',
      'description': 'You thrive in group settings and learn through interaction.',
      'icon': Icons.groups,
      'color': const Color(0xFF638ECB),
    },
    'Solitary Thinker': {
      'primary': 'solitary',
      'secondary': 'logical',
      'description': 'You prefer self-study and individual learning.',
      'icon': Icons.person,
      'color': const Color(0xFF395886),
    },
    'Logical Analyst': {
      'primary': 'logical',
      'secondary': 'reading',
      'description': 'You excel with systematic reasoning and problem-solving.',
      'icon': Icons.analytics,
      'color': const Color(0xFF8AAEE0),
    },
    'Creative Innovator': {
      'primary': 'creative',
      'secondary': 'visual',
      'description': 'You learn through creativity and artistic expression.',
      'icon': Icons.palette,
      'color': const Color(0xFF638ECB),
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    _resultController.dispose();
    super.dispose();
  }

  void _selectAnswer(String type) {
    setState(() {
      _scores[type] = (_scores[type] ?? 0) + 1;
      
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _controller.reset();
        _controller.forward();
        _progressController.forward();
      } else {
        _calculateResult();
      }
    });
  }

  void _calculateResult() {
    // Find the highest scoring type
    String topType = '';
    int maxScore = 0;
    
    _scores.forEach((type, score) {
      if (score > maxScore) {
        maxScore = score;
        topType = type;
      }
    });

    // Find second highest for hybrid type
    String secondType = '';
    int secondScore = 0;
    
    _scores.forEach((type, score) {
      if (type != topType && score > secondScore) {
        secondScore = score;
        secondType = type;
      }
    });

    // Determine learning type based on scores
    String? determinedType;
    _learningTypes.forEach((name, data) {
      if (data['primary'] == topType || 
          (data['primary'] == topType && data['secondary'] == secondType)) {
        determinedType = name;
      }
    });

    setState(() {
      _learningType = determinedType ?? 'Visual Explorer';
      _showResult = true;
    });

    _resultController.forward();
  }

  void _restartTest() {
    setState(() {
      _currentQuestionIndex = 0;
      _scores.clear();
      _scores.addAll({
        'visual': 0,
        'auditory': 0,
        'kinesthetic': 0,
        'reading': 0,
        'social': 0,
        'solitary': 0,
        'logical': 0,
        'creative': 0,
      });
      _learningType = null;
      _showResult = false;
    });
    _controller.forward();
    _progressController.forward();
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
          child: _showResult ? _buildResultScreen() : _buildQuestionScreen(),
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_currentQuestionIndex];
    
    return Column(
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuestionCard(question),
                        const SizedBox(height: 32),
                        _buildAnswerOptions(question['answers']),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        _buildNavigationInfo(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Discover Your Learning Type',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
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
            value: (_currentQuestionIndex + _progressAnimation.value) / _questions.length,
            backgroundColor: const Color(0xFFD5DEEF),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
            minHeight: 6,
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Transform.scale(
      scale: _scaleIn.value,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF395886).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF638ECB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Color(0xFF638ECB),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              question['question'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOptions(List<Map<String, String>> answers) {
    return Column(
      children: answers.asMap().entries.map((entry) {
        final index = entry.key;
        final answer = entry.value;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Transform.scale(
            scale: _scaleIn.value,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectAnswer(answer['type']!),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD5DEEF),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF395886).withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF638ECB),
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            answer['text']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF395886),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_currentQuestionIndex > 0)
            TextButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex--;
                  _controller.reset();
                  _controller.forward();
                });
              },
              child: const Text(
                'Previous',
                style: TextStyle(
                  color: Color(0xFF638ECB),
                  fontSize: 16,
                ),
              ),
            ),
          const SizedBox(width: 20),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Skip Test',
              style: TextStyle(
                color: Color(0xFF8AAEE0),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final typeData = _learningTypes[_learningType]!;
    
    return AnimatedBuilder(
      animation: _resultController,
      builder: (context, child) {
        return Opacity(
          opacity: _resultController.value,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Your Learning Type',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF8AAEE0),
                  ),
                ),
                const SizedBox(height: 20),
                Transform.scale(
                  scale: 0.8 + (_resultController.value * 0.2),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: typeData['color'],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (typeData['color'] as Color).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      typeData['icon'],
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _learningType!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF395886),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF395886).withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Text(
                    typeData['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF395886),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                _buildScoreBreakdown(),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _restartTest,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF638ECB), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Retake Test',
                          style: TextStyle(
                            color: Color(0xFF638ECB),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/personalization');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF638ECB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreBreakdown() {
    final sortedScores = _scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Your Learning Profile',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 16),
          ...sortedScores.take(3).map((entry) {
            final percentage = (entry.value / _questions.length * 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF395886),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: entry.value / _questions.length,
                      backgroundColor: const Color(0xFFD5DEEF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF638ECB)),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF638ECB),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}