import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _newTodoController = TextEditingController();
  String _selectedCategory = '전체';
  String _selectedSubject = '수학';
  DateTime? _selectedDate;
  
  final List<String> _categories = ['전체', '수학', '영어', '국어', '과학', '사회', '한국사', '기타'];
  final List<String> _subjects = ['수학', '영어', '국어', '과학', '사회', '한국사', '기타'];
  
  final List<Map<String, dynamic>> _todos = [
    {
      'id': '1',
      'title': '수학 문제집 3단원 풀기',
      'subject': '수학',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 1)),
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'title': '영어 단어 100개 암기',
      'subject': '영어',
      'completed': true,
      'dueDate': DateTime.now(),
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '3',
      'title': '국어 독후감 제출',
      'subject': '국어',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 2)),
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': '4',
      'title': '물리 실험 보고서 작성',
      'subject': '과학',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'createdAt': DateTime.now(),
    },
    {
      'id': '5',
      'title': '한국사 연표 정리',
      'subject': '한국사',
      'completed': false,
      'dueDate': DateTime.now().subtract(const Duration(days: 1)),
      'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'id': '6',
      'title': '영어 에세이 작성',
      'subject': '영어',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 5)),
      'createdAt': DateTime.now(),
    },
    {
      'id': '7',
      'title': '수학 공식 정리',
      'subject': '수학',
      'completed': true,
      'dueDate': DateTime.now().subtract(const Duration(days: 2)),
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '8',
      'title': '사회 발표 준비',
      'subject': '사회',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 4)),
      'createdAt': DateTime.now(),
    },
    {
      'id': '9',
      'title': '과학 실험 계획서',
      'subject': '과학',
      'completed': false,
      'dueDate': DateTime.now(),
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'id': '10',
      'title': '국어 시 암송',
      'subject': '국어',
      'completed': true,
      'dueDate': DateTime.now().subtract(const Duration(days: 3)),
      'createdAt': DateTime.now().subtract(const Duration(days: 4)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _newTodoController.dispose();
    super.dispose();
  }
  
  void _addTodo() {
    if (_newTodoController.text.isEmpty) return;
    
    setState(() {
      _todos.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': _newTodoController.text,
        'subject': _selectedSubject,
        'completed': false,
        'dueDate': _selectedDate,
        'createdAt': DateTime.now(),
      });
      _newTodoController.clear();
      _selectedDate = null;
    });
  }
  
  void _toggleTodo(String id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo['id'] == id);
      if (index != -1) {
        _todos[index]['completed'] = !_todos[index]['completed'];
      }
    });
  }
  
  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo['id'] == id);
    });
  }
  
  Color _getSubjectColor(String subject) {
    switch (subject) {
      case '수학':
        return const Color(0xFFFF6B6B);
      case '영어':
        return const Color(0xFF4ECDC4);
      case '국어':
        return const Color(0xFFFFBE0B);
      case '과학':
        return const Color(0xFF8338EC);
      case '사회':
        return const Color(0xFF3A86FF);
      case '한국사':
        return const Color(0xFFFB5607);
      default:
        return const Color(0xFF8AAEE0);
    }
  }
  
  String _formatDate(DateTime? date) {
    if (date == null) return '날짜 없음';
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return '오늘';
    if (difference == 1) return '내일';
    if (difference == -1) return '어제';
    if (difference > 0) return 'D-$difference';
    return '${-difference}일 지남';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    // 카테고리 필터링 (subject로 변경)
    var filteredTodos = _selectedCategory == '전체' 
        ? _todos 
        : _todos.where((todo) => todo['subject'] == _selectedCategory).toList();
    
    // 날짜 필터링 추가
    if (_selectedDate != null) {
      filteredTodos = filteredTodos.where((todo) {
        final dueDate = todo['dueDate'] as DateTime?;
        if (dueDate == null) return false;
        return dueDate.year == _selectedDate!.year &&
               dueDate.month == _selectedDate!.month &&
               dueDate.day == _selectedDate!.day;
      }).toList();
    }
    
    final incompleteTodos = filteredTodos.where((todo) => !todo['completed']).toList();
    final completedTodos = filteredTodos.where((todo) => todo['completed']).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF395886),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'To-Do',
          style: TextStyle(
            color: Color(0xFF395886),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.checklist_rounded,
                color: Color(0xFF638ECB),
                size: 28,
              ),
              onPressed: () {
                // Could add additional functionality here
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${incompleteTodos.length}개의 할 일이 남았습니다',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Category Filter
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final isSelected = _selectedCategory == category;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF638ECB)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected 
                                        ? Colors.white 
                                        : const Color(0xFF395886),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Calendar View
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Calendar Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left, color: Color(0xFF638ECB)),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = DateTime(
                                        _selectedDate?.year ?? DateTime.now().year,
                                        (_selectedDate?.month ?? DateTime.now().month) - 1,
                                        1,
                                      );
                                    });
                                  },
                                ),
                                Text(
                                  '${_selectedDate?.year ?? DateTime.now().year}년 ${_selectedDate?.month ?? DateTime.now().month}월',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF395886),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, color: Color(0xFF638ECB)),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDate = DateTime(
                                        _selectedDate?.year ?? DateTime.now().year,
                                        (_selectedDate?.month ?? DateTime.now().month) + 1,
                                        1,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // 선택된 날짜 표시
                            if (_selectedDate != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF638ECB).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF638ECB),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Color(0xFF638ECB),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_selectedDate!.month}월 ${_selectedDate!.day}일 할 일',
                                      style: const TextStyle(
                                        color: Color(0xFF638ECB),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedDate = null;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Color(0xFF638ECB),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Week Days Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                _WeekDayHeader(day: '일'),
                                _WeekDayHeader(day: '월'),
                                _WeekDayHeader(day: '화'),
                                _WeekDayHeader(day: '수'),
                                _WeekDayHeader(day: '목'),
                                _WeekDayHeader(day: '금'),
                                _WeekDayHeader(day: '토'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Calendar Grid
                            _buildCalendarGrid(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Todo List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 20,
                    ),
                    children: [
                      // Incomplete Todos
                      if (incompleteTodos.isNotEmpty) ...[
                        const Text(
                          '진행 중',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF395886),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...incompleteTodos.map((todo) => _buildTodoItem(todo)),
                      ],
                      
                      // Completed Todos
                      if (completedTodos.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          '완료됨',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF395886),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...completedTodos.map((todo) => _buildTodoItem(todo)),
                      ],
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTodoItem(Map<String, dynamic> todo) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Dismissible(
      key: Key(todo['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => _deleteTodo(todo['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleTodo(todo['id']),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: todo['completed'] 
                      ? const Color(0xFF638ECB)
                      : Colors.transparent,
                  border: Border.all(
                    color: todo['completed']
                        ? const Color(0xFF638ECB)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: todo['completed']
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo['title'],
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: todo['completed']
                          ? Colors.grey
                          : const Color(0xFF395886),
                      decoration: todo['completed']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSubjectColor(todo['subject'] ?? '기타')
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          todo['subject'] ?? '기타',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getSubjectColor(todo['subject'] ?? '기타'),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (todo['dueDate'] != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(todo['dueDate']),
                          style: TextStyle(
                            fontSize: 12,
                            color: todo['dueDate'].isBefore(DateTime.now()) &&
                                    !todo['completed']
                                ? Colors.red
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final currentMonth = _selectedDate?.month ?? now.month;
    final currentYear = _selectedDate?.year ?? now.year;
    
    final firstDayOfMonth = DateTime(currentYear, currentMonth, 1);
    final lastDayOfMonth = DateTime(currentYear, currentMonth + 1, 0);
    
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    
    final totalCells = ((daysInMonth + startWeekday) / 7).ceil() * 7;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < startWeekday) {
          return const SizedBox();
        }
        
        final day = index - startWeekday + 1;
        if (day > daysInMonth) {
          return const SizedBox();
        }
        
        final date = DateTime(currentYear, currentMonth, day);
        final isToday = date.year == now.year && 
                       date.month == now.month && 
                       date.day == now.day;
        final isSelected = _selectedDate != null &&
                          date.year == _selectedDate!.year &&
                          date.month == _selectedDate!.month &&
                          date.day == _selectedDate!.day;
        
        // Check if there are todos on this date
        final todosOnDate = _todos.where((todo) {
          final dueDate = todo['dueDate'] as DateTime?;
          return dueDate != null &&
                 dueDate.year == date.year &&
                 dueDate.month == date.month &&
                 dueDate.day == date.day;
        }).toList();
        
        return GestureDetector(
          onTap: () {
            setState(() {
              // 같은 날짜를 다시 클릭하면 필터 해제
              if (_selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day) {
                _selectedDate = null;
              } else {
                _selectedDate = date;
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF638ECB)
                  : isToday
                      ? const Color(0xFF8AAEE0).withOpacity(0.2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected || isToday
                    ? const Color(0xFF638ECB)
                    : Colors.transparent,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? const Color(0xFF638ECB)
                              : const Color(0xFF395886),
                      fontWeight: isToday || isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (todosOnDate.isNotEmpty)
                  Positioned(
                    bottom: 2,
                    right: 0,
                    left: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: todosOnDate.take(3).map((todo) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _getSubjectColor(todo['subject'] ?? '기타'),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTodosDialog(DateTime date, List<Map<String, dynamic>> todos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${date.month}월 ${date.day}일 할 일'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: todos.map((todo) {
            return ListTile(
              leading: Checkbox(
                value: todo['completed'],
                onChanged: (value) {
                  setState(() {
                    todo['completed'] = value;
                  });
                  Navigator.pop(context);
                },
              ),
              title: Text(todo['title']),
              subtitle: Text(todo['subject'] ?? '기타'),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddTodoDialog(date);
            },
            child: const Text('할 일 추가'),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog(DateTime date) {
    final controller = TextEditingController();
    String selectedSubject = _selectedSubject;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('${date.month}월 ${date.day}일 할 일 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: '할 일을 입력하세요',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedSubject,
                isExpanded: true,
                items: _subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedSubject = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _todos.insert(0, {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'title': controller.text,
                      'subject': selectedSubject,
                      'completed': false,
                      'dueDate': date,
                      'createdAt': DateTime.now(),
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}

// Week Day Header Widget
class _WeekDayHeader extends StatelessWidget {
  final String day;
  
  const _WeekDayHeader({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 30,
      alignment: Alignment.center,
      child: Text(
        day,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: day == '일' 
              ? Colors.red.shade400 
              : day == '토' 
                  ? Colors.blue.shade400 
                  : const Color(0xFF8AAEE0),
        ),
      ),
    );
  }
}