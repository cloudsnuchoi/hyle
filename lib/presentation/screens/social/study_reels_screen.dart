import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

// Study Reels Provider
final studyReelsProvider = StateNotifierProvider<StudyReelsNotifier, StudyReelsState>((ref) {
  return StudyReelsNotifier();
});

class StudyReelsState {
  final List<StudyReel> reels;
  final int currentIndex;
  final bool isLoading;
  final Map<String, VideoPlayerController> videoControllers;

  StudyReelsState({
    this.reels = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.videoControllers = const {},
  });

  StudyReelsState copyWith({
    List<StudyReel>? reels,
    int? currentIndex,
    bool? isLoading,
    Map<String, VideoPlayerController>? videoControllers,
  }) {
    return StudyReelsState(
      reels: reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      videoControllers: videoControllers ?? this.videoControllers,
    );
  }
}

class StudyReelsNotifier extends StateNotifier<StudyReelsState> {
  StudyReelsNotifier() : super(StudyReelsState()) {
    loadReels();
  }

  void loadReels() {
    // Mock data - in production, load from API
    state = state.copyWith(
      reels: [
        StudyReel(
          id: '1',
          videoUrl: 'https://example.com/math-tips.mp4',
          thumbnailUrl: 'https://example.com/math-thumb.jpg',
          title: 'Quick Calculus Trick',
          description: 'Learn this 30-second trick to solve derivatives faster! 🚀',
          creator: ReelCreator(
            id: 'u1',
            name: 'MathPro',
            avatar: '👨‍🏫',
            verified: true,
          ),
          subject: 'Mathematics',
          difficulty: 'Advanced',
          duration: 45,
          likes: 2341,
          comments: 156,
          shares: 89,
          saves: 412,
          isLiked: false,
          isSaved: false,
          hashtags: ['#calculus', '#mathtricks', '#study'],
          learningPoints: [
            'Power rule shortcut',
            'Chain rule visualization',
            'Common mistakes to avoid',
          ],
        ),
        StudyReel(
          id: '2',
          videoUrl: 'https://example.com/english-vocab.mp4',
          thumbnailUrl: 'https://example.com/english-thumb.jpg',
          title: '5 SAT Words in 60 Seconds',
          description: 'Master these high-frequency SAT vocabulary words! 📚',
          creator: ReelCreator(
            id: 'u2',
            name: 'WordWizard',
            avatar: '📖',
            verified: false,
          ),
          subject: 'English',
          difficulty: 'Intermediate',
          duration: 60,
          likes: 1892,
          comments: 98,
          shares: 67,
          saves: 523,
          isLiked: true,
          isSaved: true,
          hashtags: ['#SAT', '#vocabulary', '#english'],
          learningPoints: [
            'Ubiquitous - everywhere',
            'Ephemeral - short-lived',
            'Pragmatic - practical',
            'Ambivalent - mixed feelings',
            'Ostentatious - showy',
          ],
        ),
      ],
    );
  }

  void updateIndex(int index) {
    state = state.copyWith(currentIndex: index);
    // Play video at new index
    _playVideoAtIndex(index);
  }

  void _playVideoAtIndex(int index) {
    // Pause all videos
    state.videoControllers.values.forEach((controller) {
      controller.pause();
    });

    // Play current video
    final reelId = state.reels[index].id;
    state.videoControllers[reelId]?.play();
  }

  void toggleLike(String reelId) {
    state = state.copyWith(
      reels: state.reels.map((reel) {
        if (reel.id == reelId) {
          return reel.copyWith(
            isLiked: !reel.isLiked,
            likes: reel.isLiked ? reel.likes - 1 : reel.likes + 1,
          );
        }
        return reel;
      }).toList(),
    );
  }

  void toggleSave(String reelId) {
    state = state.copyWith(
      reels: state.reels.map((reel) {
        if (reel.id == reelId) {
          return reel.copyWith(
            isSaved: !reel.isSaved,
            saves: reel.isSaved ? reel.saves - 1 : reel.saves + 1,
          );
        }
        return reel;
      }).toList(),
    );
  }
}

// Data models
class StudyReel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final ReelCreator creator;
  final String subject;
  final String difficulty;
  final int duration;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final bool isLiked;
  final bool isSaved;
  final List<String> hashtags;
  final List<String> learningPoints;

  StudyReel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.creator,
    required this.subject,
    required this.difficulty,
    required this.duration,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saves,
    required this.isLiked,
    required this.isSaved,
    required this.hashtags,
    required this.learningPoints,
  });

  StudyReel copyWith({
    bool? isLiked,
    bool? isSaved,
    int? likes,
    int? saves,
  }) {
    return StudyReel(
      id: id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      title: title,
      description: description,
      creator: creator,
      subject: subject,
      difficulty: difficulty,
      duration: duration,
      likes: likes ?? this.likes,
      comments: comments,
      shares: shares,
      saves: saves ?? this.saves,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      hashtags: hashtags,
      learningPoints: learningPoints,
    );
  }
}

class ReelCreator {
  final String id;
  final String name;
  final String avatar;
  final bool verified;

  ReelCreator({
    required this.id,
    required this.name,
    required this.avatar,
    required this.verified,
  });
}

class StudyReelsScreen extends ConsumerStatefulWidget {
  const StudyReelsScreen({super.key});

  @override
  ConsumerState<StudyReelsScreen> createState() => _StudyReelsScreenState();
}

class _StudyReelsScreenState extends ConsumerState<StudyReelsScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Lock to portrait mode for reels
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studyReelsProvider);

    if (state.reels.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Reels PageView
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              ref.read(studyReelsProvider.notifier).updateIndex(index);
            },
            itemCount: state.reels.length,
            itemBuilder: (context, index) {
              final reel = state.reels[index];
              return _ReelView(reel: reel);
            },
          ),

          // Top bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Study Reels',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // TODO: Show search
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
}

class _ReelView extends ConsumerWidget {
  final StudyReel reel;

  const _ReelView({required this.reel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player placeholder
        Container(
          color: Colors.grey.shade900,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  'Video Player',
                  style: AppTypography.body.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),

        // Content overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left side - Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Creator info
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                reel.creator.avatar,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    reel.creator.name,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (reel.creator.verified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(reel.difficulty)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getDifficultyColor(reel.difficulty),
                                  ),
                                ),
                                child: Text(
                                  '${reel.subject} • ${reel.difficulty}',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {
                              // TODO: Follow creator
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                            ),
                            child: const Text('Follow'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Title and description
                      Text(
                        reel.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reel.description,
                        style: AppTypography.body.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Hashtags
                      Wrap(
                        spacing: 8,
                        children: reel.hashtags.map((tag) => Text(
                          tag,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        )).toList(),
                      ),

                      const SizedBox(height: 12),

                      // Learning points
                      if (reel.learningPoints.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Key Points',
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...reel.learningPoints.map((point) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: AppTypography.caption.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right side - Actions
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionButton(
                      icon: reel.isLiked ? Icons.favorite : Icons.favorite_border,
                      label: _formatCount(reel.likes),
                      color: reel.isLiked ? Colors.red : Colors.white,
                      onTap: () {
                        ref.read(studyReelsProvider.notifier).toggleLike(reel.id);
                      },
                    ),
                    const SizedBox(height: 20),
                    _ActionButton(
                      icon: Icons.comment_outlined,
                      label: _formatCount(reel.comments),
                      onTap: () {
                        _showComments(context, reel);
                      },
                    ),
                    const SizedBox(height: 20),
                    _ActionButton(
                      icon: Icons.share_outlined,
                      label: _formatCount(reel.shares),
                      onTap: () {
                        // TODO: Share reel
                      },
                    ),
                    const SizedBox(height: 20),
                    _ActionButton(
                      icon: reel.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      label: _formatCount(reel.saves),
                      color: reel.isSaved ? Colors.amber : Colors.white,
                      onTap: () {
                        ref.read(studyReelsProvider.notifier).toggleSave(reel.id);
                      },
                    ),
                    const SizedBox(height: 20),
                    _ActionButton(
                      icon: Icons.more_vert,
                      label: '',
                      onTap: () {
                        _showMoreOptions(context, reel);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Progress indicator
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: LinearProgressIndicator(
            value: 0.3, // Mock progress
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 2,
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _showComments(BuildContext context, StudyReel reel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Comments',
                style: AppTypography.titleMedium,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Comments feature coming soon',
                  style: AppTypography.body.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context, StudyReel reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block creator'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy link'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ).animate(target: color == Colors.white ? 0 : 1)
            .scale(duration: 200.ms, begin: 1, end: 1.2)
            .then()
            .scale(duration: 200.ms, begin: 1.2, end: 1),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}