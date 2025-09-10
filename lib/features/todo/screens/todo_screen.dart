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
  String _selectedPriority = '보통';
  DateTime? _selectedDate;
  
  final List<String> _categories = ['전체', '공부', '과제', '시험', '기타'];
  final List<String> _priorities = ['낮음', '보통', '높음', '긴급'];
  
  final List<Map<String, dynamic>> _todos = [
    {
      'id': '1',
      'title': '수학 문제집 3단원 풀기',
      'category': '공부',
      'priority': '높음',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 1)),
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'title': '영어 단어 100개 암기',
      'category': '공부',
      'priority': '보통',
      'completed': true,
      'dueDate': DateTime.now(),
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '3',
      'title': '국어 독후감 제출',
      'category': '과제',
      'priority': '긴급',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 2)),
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': '4',
      'title': '모의고사 복습',
      'category': '시험',
      'priority': '높음',
      'completed': false,
      'dueDate': DateTime.now().add(const Duration(days: 3)),
      'createdAt': DateTime.now(),
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
        'category': _selectedCategory == '전체' ? '기타' : _selectedCategory,
        'priority': _selectedPriority,
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
  
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case '긴급':
        return Colors.red.shade400;
      case '높음':
        return Colors.orange.shade400;
      case '보통':
        return const Color(0xFF638ECB);
      case '낮음':
        return Colors.grey.shade400;
      default:
        return const Color(0xFF638ECB);
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
    
    final filteredTodos = _selectedCategory == '전체' 
        ? _todos 
        : _todos.where((todo) => todo['category'] == _selectedCategory).toList();
    
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
          '할 일 목록',
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
                      
                      // Add Todo Input
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
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _newTodoController,
                                    decoration: const InputDecoration(
                                      hintText: '새로운 할 일을 입력하세요',
                                      border: InputBorder.none,
                                    ),
                                    onSubmitted: (_) => _addTodo(),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        _selectedDate = date;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: _selectedDate != null 
                                        ? const Color(0xFF638ECB)
                                        : Colors.grey,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(_selectedPriority),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButton<String>(
                                    value: _selectedPriority,
                                    underline: const SizedBox(),
                                    dropdownColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    items: _priorities.map((priority) {
                                      return DropdownMenuItem(
                                        value: priority,
                                        child: Text(
                                          priority,
                                          style: TextStyle(
                                            color: _getPriorityColor(priority),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedPriority = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _addTodo,
                                  icon: const Icon(
                                    Icons.add_circle,
                                    color: Color(0xFF638ECB),
                                    size: 32,
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedDate != null)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD5DEEF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '마감일: ${_formatDate(_selectedDate)}',
                                  style: const TextStyle(
                                    color: Color(0xFF395886),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
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
                          color: const Color(0xFFD5DEEF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          todo['category'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF395886),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(todo['priority'])
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          todo['priority'],
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPriorityColor(todo['priority']),
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
}