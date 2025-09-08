import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PDFViewerScreen extends ConsumerStatefulWidget {
  const PDFViewerScreen({super.key});

  @override
  ConsumerState<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends ConsumerState<PDFViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  
  int _currentPage = 1;
  final int _totalPages = 25;
  double _zoomLevel = 1.0;
  bool _isNightMode = false;
  bool _showThumbnails = false;
  bool _showOutline = false;
  final TextEditingController _pageController = TextEditingController(text: '1');
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _bookmarks = [
    {'page': 3, 'title': 'Introduction'},
    {'page': 7, 'title': 'Chapter 1: Basics'},
    {'page': 15, 'title': 'Chapter 2: Advanced Topics'},
  ];

  final List<Map<String, dynamic>> _annotations = [
    {'page': 1, 'type': 'highlight', 'color': Colors.yellow},
    {'page': 3, 'type': 'note', 'text': 'Important concept'},
    {'page': 5, 'type': 'highlight', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isNightMode ? const Color(0xFF1a1a2e) : const Color(0xFFF0F3FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              _buildHeader(),
              _buildToolbar(),
              Expanded(
                child: Row(
                  children: [
                    if (_showThumbnails) _buildThumbnailPanel(),
                    if (_showOutline) _buildOutlinePanel(),
                    Expanded(child: _buildPDFViewer()),
                  ],
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isNightMode ? const Color(0xFF16213e) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF395886).withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: _isNightMode ? Colors.white : const Color(0xFF395886),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Calculus Textbook.pdf',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isNightMode ? Colors.white : const Color(0xFF395886),
                  ),
                ),
                Text(
                  '15.2 MB • $_totalPages pages',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isNightMode ? Colors.white70 : const Color(0xFF8AAEE0),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.download,
              color: _isNightMode ? Colors.white : const Color(0xFF638ECB),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: _isNightMode ? Colors.white : const Color(0xFF638ECB),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isNightMode ? const Color(0xFF16213e) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _isNightMode ? Colors.white12 : const Color(0xFFD5DEEF),
          ),
        ),
      ),
      child: Row(
        children: [
          // Search bar
          Container(
            width: 200,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isNightMode 
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFF0F3FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 14,
                color: _isNightMode ? Colors.white : const Color(0xFF395886),
              ),
              decoration: InputDecoration(
                hintText: 'Search in document...',
                hintStyle: TextStyle(
                  color: _isNightMode ? Colors.white54 : const Color(0xFF8AAEE0),
                ),
                border: InputBorder.none,
                icon: Icon(
                  Icons.search,
                  size: 18,
                  color: _isNightMode ? Colors.white54 : const Color(0xFF8AAEE0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // View controls
          IconButton(
            icon: Icon(
              Icons.view_sidebar,
              color: _showThumbnails 
                  ? const Color(0xFF638ECB)
                  : (_isNightMode ? Colors.white54 : const Color(0xFF8AAEE0)),
            ),
            onPressed: () {
              setState(() {
                _showThumbnails = !_showThumbnails;
                if (_showThumbnails) _showOutline = false;
              });
            },
            tooltip: 'Thumbnails',
          ),
          IconButton(
            icon: Icon(
              Icons.list,
              color: _showOutline 
                  ? const Color(0xFF638ECB)
                  : (_isNightMode ? Colors.white54 : const Color(0xFF8AAEE0)),
            ),
            onPressed: () {
              setState(() {
                _showOutline = !_showOutline;
                if (_showOutline) _showThumbnails = false;
              });
            },
            tooltip: 'Outline',
          ),
          
          const Spacer(),
          
          // Annotation tools
          IconButton(
            icon: Icon(
              Icons.highlight,
              color: _isNightMode ? Colors.yellow : Colors.yellow[700],
            ),
            onPressed: () {},
            tooltip: 'Highlight',
          ),
          IconButton(
            icon: Icon(
              Icons.edit_note,
              color: _isNightMode ? Colors.white54 : const Color(0xFF638ECB),
            ),
            onPressed: () {},
            tooltip: 'Add Note',
          ),
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: _isNightMode ? Colors.white54 : const Color(0xFF638ECB),
            ),
            onPressed: () {},
            tooltip: 'Bookmark',
          ),
          
          const SizedBox(width: 16),
          
          // View mode
          IconButton(
            icon: Icon(
              _isNightMode ? Icons.light_mode : Icons.dark_mode,
              color: _isNightMode ? Colors.white : const Color(0xFF395886),
            ),
            onPressed: () {
              setState(() => _isNightMode = !_isNightMode);
            },
            tooltip: 'Toggle Night Mode',
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailPanel() {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: _isNightMode ? const Color(0xFF16213e) : Colors.white,
        border: Border(
          right: BorderSide(
            color: _isNightMode ? Colors.white12 : const Color(0xFFD5DEEF),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Pages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isNightMode ? Colors.white : const Color(0xFF395886),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _totalPages,
              itemBuilder: (context, index) {
                final pageNum = index + 1;
                final isCurrentPage = pageNum == _currentPage;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCurrentPage 
                          ? const Color(0xFF638ECB)
                          : (_isNightMode ? Colors.white24 : const Color(0xFFD5DEEF)),
                      width: isCurrentPage ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentPage = pageNum;
                        _pageController.text = pageNum.toString();
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          height: 150,
                          color: _isNightMode 
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.description,
                              size: 40,
                              color: _isNightMode ? Colors.white24 : Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'Page $pageNum',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isNightMode ? Colors.white70 : const Color(0xFF395886),
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
        ],
      ),
    );
  }

  Widget _buildOutlinePanel() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: _isNightMode ? const Color(0xFF16213e) : Colors.white,
        border: Border(
          right: BorderSide(
            color: _isNightMode ? Colors.white12 : const Color(0xFFD5DEEF),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Outline',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isNightMode ? Colors.white : const Color(0xFF395886),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildOutlineItem('Introduction', 1, 0),
                _buildOutlineItem('1. Mathematical Foundations', 3, 0),
                _buildOutlineItem('1.1 Basic Concepts', 4, 1),
                _buildOutlineItem('1.2 Advanced Topics', 7, 1),
                _buildOutlineItem('2. Calculus Fundamentals', 10, 0),
                _buildOutlineItem('2.1 Derivatives', 11, 1),
                _buildOutlineItem('2.2 Integrals', 15, 1),
                _buildOutlineItem('3. Applications', 20, 0),
                _buildOutlineItem('Summary', 24, 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineItem(String title, int page, int level) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentPage = page;
          _pageController.text = page.toString();
        });
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 8.0 + (level * 16.0),
          right: 8.0,
          top: 6.0,
          bottom: 6.0,
        ),
        child: Row(
          children: [
            if (level == 0)
              Icon(
                Icons.folder,
                size: 16,
                color: _isNightMode ? Colors.white54 : const Color(0xFF638ECB),
              )
            else
              Icon(
                Icons.description,
                size: 14,
                color: _isNightMode ? Colors.white38 : const Color(0xFF8AAEE0),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: level == 0 ? FontWeight.w600 : FontWeight.normal,
                  color: _isNightMode ? Colors.white : const Color(0xFF395886),
                ),
              ),
            ),
            Text(
              page.toString(),
              style: TextStyle(
                fontSize: 11,
                color: _isNightMode ? Colors.white38 : const Color(0xFFD5DEEF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPDFViewer() {
    return Container(
      color: _isNightMode ? Colors.black : Colors.grey[300],
      child: Stack(
        children: [
          // PDF page placeholder
          Center(
            child: Container(
              width: 600 * _zoomLevel,
              height: 800 * _zoomLevel,
              decoration: BoxDecoration(
                color: _isNightMode ? const Color(0xFF2a2a3e) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Text(
                      'Page $_currentPage',
                      style: TextStyle(
                        fontSize: 24 * _zoomLevel,
                        fontWeight: FontWeight.bold,
                        color: _isNightMode ? Colors.white : const Color(0xFF395886),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Icon(
                        Icons.description,
                        size: 100 * _zoomLevel,
                        color: _isNightMode ? Colors.white24 : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Floating zoom controls
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: _isNightMode ? const Color(0xFF16213e) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.zoom_out,
                      color: _isNightMode ? Colors.white : const Color(0xFF638ECB),
                    ),
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel - 0.25).clamp(0.5, 3.0);
                      });
                    },
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      '${(_zoomLevel * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isNightMode ? Colors.white : const Color(0xFF395886),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.zoom_in,
                      color: _isNightMode ? Colors.white : const Color(0xFF638ECB),
                    ),
                    onPressed: () {
                      setState(() {
                        _zoomLevel = (_zoomLevel + 0.25).clamp(0.5, 3.0);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: _isNightMode ? const Color(0xFF16213e) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _isNightMode ? Colors.white : const Color(0xFF638ECB),
            ),
            onPressed: _currentPage > 1 
                ? () {
                    setState(() {
                      _currentPage--;
                      _pageController.text = _currentPage.toString();
                    });
                  }
                : null,
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 36,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isNightMode ? Colors.white24 : const Color(0xFFD5DEEF),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _pageController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _isNightMode ? Colors.white : const Color(0xFF395886),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value);
                if (page != null && page >= 1 && page <= _totalPages) {
                  setState(() => _currentPage = page);
                } else {
                  _pageController.text = _currentPage.toString();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '/ $_totalPages',
            style: TextStyle(
              fontSize: 14,
              color: _isNightMode ? Colors.white70 : const Color(0xFF8AAEE0),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _isNightMode ? Colors.white : const Color(0xFF638ECB),
            ),
            onPressed: _currentPage < _totalPages 
                ? () {
                    setState(() {
                      _currentPage++;
                      _pageController.text = _currentPage.toString();
                    });
                  }
                : null,
          ),
          const Spacer(),
          // Annotations indicator
          if (_annotations.any((a) => a['page'] == _currentPage)) ...[
            Icon(
              Icons.comment,
              size: 16,
              color: _isNightMode ? Colors.yellow : Colors.orange,
            ),
            const SizedBox(width: 4),
            Text(
              '${_annotations.where((a) => a['page'] == _currentPage).length} annotations',
              style: TextStyle(
                fontSize: 12,
                color: _isNightMode ? Colors.white70 : const Color(0xFF8AAEE0),
              ),
            ),
            const SizedBox(width: 16),
          ],
          // View options
          IconButton(
            icon: Icon(
              Icons.fullscreen,
              color: _isNightMode ? Colors.white54 : const Color(0xFF638ECB),
            ),
            onPressed: () {},
            tooltip: 'Fullscreen',
          ),
          IconButton(
            icon: Icon(
              Icons.print,
              color: _isNightMode ? Colors.white54 : const Color(0xFF638ECB),
            ),
            onPressed: () {},
            tooltip: 'Print',
          ),
        ],
      ),
    );
  }
}