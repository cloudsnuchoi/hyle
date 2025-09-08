import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _progressController;
  late Animation<double> _fadeIn;
  
  bool _isPlaying = false;
  bool _showControls = true;
  double _currentPosition = 45.0; // seconds
  double _totalDuration = 180.0; // 3 minutes
  double _playbackSpeed = 1.0;
  bool _isFullscreen = false;
  double _volume = 0.8;

  final List<Map<String, dynamic>> _chapters = [
    {'title': 'Introduction', 'time': 0, 'duration': 30},
    {'title': 'Main Concepts', 'time': 30, 'duration': 60},
    {'title': 'Examples', 'time': 90, 'duration': 45},
    {'title': 'Practice Problems', 'time': 135, 'duration': 35},
    {'title': 'Summary', 'time': 170, 'duration': 10},
  ];

  final List<Map<String, dynamic>> _notes = [
    {'time': 15, 'text': 'Important formula here'},
    {'time': 45, 'text': 'Remember this concept'},
    {'time': 120, 'text': 'Practice this example'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

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
    _progressController.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toInt().toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            children: [
              _buildVideoPlayer(),
              if (!_isFullscreen) ...[
                _buildVideoInfo(),
                _buildChapterList(),
                _buildNotesSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Expanded(
      flex: _isFullscreen ? 1 : 0,
      child: Container(
        height: _isFullscreen ? double.infinity : 250,
        color: Colors.black,
        child: Stack(
          children: [
            // Video placeholder
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: Colors.white30,
                ),
              ),
            ),
            
            // Controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    _buildTopControls(),
                    const Spacer(),
                    _buildCenterControls(),
                    const Spacer(),
                    _buildBottomControls(),
                  ],
                ),
              ),
            ),
            
            // Tap detector
            GestureDetector(
              onTap: () {
                setState(() => _showControls = !_showControls);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Advanced Mathematics - Lesson 5',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.cast, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10, color: Colors.white),
          iconSize: 40,
          onPressed: () {
            setState(() {
              _currentPosition = (_currentPosition - 10).clamp(0, _totalDuration);
            });
          },
        ),
        const SizedBox(width: 40),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 45,
            onPressed: () {
              setState(() => _isPlaying = !_isPlaying);
            },
          ),
        ),
        const SizedBox(width: 40),
        IconButton(
          icon: const Icon(Icons.forward_10, color: Colors.white),
          iconSize: 40,
          onPressed: () {
            setState(() {
              _currentPosition = (_currentPosition + 10).clamp(0, _totalDuration);
            });
          },
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _formatTime(_currentPosition),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF638ECB),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                    thumbColor: const Color(0xFF638ECB),
                    overlayColor: const Color(0xFF638ECB).withValues(alpha: 0.3),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _currentPosition,
                    min: 0,
                    max: _totalDuration,
                    onChanged: (value) {
                      setState(() => _currentPosition = value);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(_totalDuration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
        
        // Bottom button controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _volume = _volume > 0 ? 0 : 0.8;
                  });
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_playbackSpeed == 1.0) {
                        _playbackSpeed = 1.25;
                      } else if (_playbackSpeed == 1.25) {
                        _playbackSpeed = 1.5;
                      } else if (_playbackSpeed == 1.5) {
                        _playbackSpeed = 2.0;
                      } else {
                        _playbackSpeed = 1.0;
                      }
                    });
                  },
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.subtitles, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.picture_in_picture, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() => _isFullscreen = !_isFullscreen);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Advanced Mathematics - Lesson 5',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF395886),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF8AAEE0)),
              const SizedBox(width: 4),
              const Text(
                'Prof. Johnson',
                style: TextStyle(fontSize: 14, color: Color(0xFF8AAEE0)),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.visibility, size: 16, color: Color(0xFF8AAEE0)),
              const SizedBox(width: 4),
              const Text(
                '1.2K views',
                style: TextStyle(fontSize: 14, color: Color(0xFF8AAEE0)),
              ),
              const SizedBox(width: 16),
              Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              const Text(
                '4.8',
                style: TextStyle(fontSize: 14, color: Color(0xFF8AAEE0)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF638ECB),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border, size: 16),
                label: const Text('Save'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF638ECB),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF638ECB),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    return Container(
      height: 120,
      color: const Color(0xFFF0F3FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Chapters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF395886),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                final isActive = _currentPosition >= chapter['time'] &&
                    _currentPosition < chapter['time'] + chapter['duration'];
                
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF638ECB) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF395886).withValues(alpha: 0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chapter ${index + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? Colors.white70 : const Color(0xFF8AAEE0),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapter['title'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : const Color(0xFF395886),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(chapter['time'].toDouble()),
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? Colors.white70 : const Color(0xFFD5DEEF),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF395886),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Note'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF638ECB),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF638ECB).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatTime(note['time'].toDouble()),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF638ECB),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            note['text'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF395886),
                            ),
                          ),
                        ),
                      ],
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
}