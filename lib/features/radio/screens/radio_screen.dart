import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/user_service.dart';
import '../../../services/radio_service.dart';
import '../models/radio_model.dart';

/// Premium Radio Screen - Campus Radio Experience
class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Live Status
          SliverAppBar(
            expandedHeight: 360,
            floating: false,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false, // No back arrow for main nav screen
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.radioColor,
                      AppColors.radioColor.withValues(alpha: 0.85),
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.radio,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'MVGR Radio',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your campus vibes, on air',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Live Badge
                            _LiveBadge(),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _NowPlayingCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.radioColor,
                unselectedLabelColor: context.appColors.textSecondary,
                indicatorColor: AppColors.radioColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: '🎵 Song Requests'),
                  Tab(text: '💬 Shoutouts'),
                ],
              ),
            ),
          ),

          // Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _SongRequestsTab(),
                _ShoutoutsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionSheet(context),
        backgroundColor: AppColors.radioColor,
        icon: const Icon(Icons.add),
        label: const Text('Request'),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _ActionOption(
              icon: Icons.music_note,
              title: 'Request a Song',
              subtitle: 'Vote for your favorite song',
              color: AppColors.radioColor,
              onTap: () {
                Navigator.pop(context);
                _showSongRequestSheet(context);
              },
            ),
            const SizedBox(height: 12),
            _ActionOption(
              icon: Icons.campaign,
              title: 'Send a Shoutout',
              subtitle: 'Share a message on air',
              color: AppColors.accent,
              onTap: () {
                Navigator.pop(context);
                _showShoutoutSheet(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSongRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SongRequestSheet(),
    );
  }

  void _showShoutoutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ShoutoutSheet(),
    );
  }
}

/// Live Badge
class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Now Playing Card with Audio Player
class _NowPlayingCard extends StatefulWidget {
  @override
  State<_NowPlayingCard> createState() => _NowPlayingCardState();
}

class _NowPlayingCardState extends State<_NowPlayingCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  bool _hasError = false;
  int _currentTrackIndex = 0;
  
  // Playlist with Google Drive tracks
  // Google Drive direct download format: https://drive.google.com/uc?export=download&id=FILE_ID
  static final List<Map<String, String>> _playlist = [
    {
      'title': 'English',
      'artist': 'MVGR Radio',
      'url': 'https://drive.google.com/uc?export=download&id=102cOmxEPSljpKH5HLgGqq2pdRa5E6RK3',
    },
    {
      'title': 'Telugu',
      'artist': 'MVGR Radio',
      'url': 'https://drive.google.com/uc?export=download&id=1l4zo9da_ngKQDGSS1B6eOQnmozb-Z6v5',
    },
  ];
  
  String get _currentTrackTitle => _playlist[_currentTrackIndex]['title'] ?? 'Unknown';
  String get _currentTrackArtist => _playlist[_currentTrackIndex]['artist'] ?? 'MVGR Radio';
  String get _currentTrackUrl => _playlist[_currentTrackIndex]['url'] ?? '';
  
  @override
  void initState() {
    super.initState();
    _initAudio();
  }
  
  Future<void> _initAudio() async {
    try {
      setState(() => _isLoading = true);
      await _audioPlayer.setUrl(_currentTrackUrl);
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }
  
  void _switchTrack(int index) async {
    if (index == _currentTrackIndex) return;
    await _audioPlayer.stop();
    setState(() {
      _currentTrackIndex = index;
    });
    await _initAudio();
  }
  
  void _nextTrack() {
    final nextIndex = (_currentTrackIndex + 1) % _playlist.length;
    _switchTrack(nextIndex);
  }
  
  void _previousTrack() {
    final prevIndex = (_currentTrackIndex - 1 + _playlist.length) % _playlist.length;
    _switchTrack(prevIndex);
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    String minutes = duration.inMinutes.toString().padLeft(1, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Album Art / Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.music_note, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              // Track Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentTrackTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentTrackArtist,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Play/Pause Button
              StreamBuilder<PlayerState>(
                stream: _audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing ?? false;
                  
                  if (_isLoading || processingState == ProcessingState.loading || 
                      processingState == ProcessingState.buffering) {
                    return Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(12),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  } else if (_hasError) {
                    return IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
                      onPressed: _initAudio,
                    );
                  } else if (playing) {
                    return IconButton(
                      icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 48),
                      onPressed: _audioPlayer.pause,
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                      onPressed: _audioPlayer.play,
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          StreamBuilder<Duration?>(
            stream: _audioPlayer.positionStream,
            builder: (context, positionSnapshot) {
              final position = positionSnapshot.data ?? Duration.zero;
              final duration = _audioPlayer.duration ?? Duration.zero;
              
              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Track Selection Chips
          Row(
            children: List.generate(_playlist.length, (index) {
              final isSelected = index == _currentTrackIndex;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 4,
                    right: index == _playlist.length - 1 ? 0 : 4,
                  ),
                  child: GestureDetector(
                    onTap: () => _switchTrack(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white 
                            : Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _playlist[index]['title'] ?? 'Track ${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? AppColors.radioColor 
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Sliver Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

/// Action Option
class _ActionOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: context.appColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// Song Requests Tab
class _SongRequestsTab extends StatelessWidget {
  const _SongRequestsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SongVote>>(
      stream: RadioService.instance.getSongRequestsStream(),
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         }
        
        final requests = snapshot.data ?? [];
        requests.sort((a, b) => b.voteCount.compareTo(a.voteCount));

        if (requests.isEmpty) {
          return _EmptyState(
            icon: Icons.queue_music,
            title: 'No song requests yet',
            subtitle: 'Be the first to request a song!',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _SongCard(
            song: requests[index],
            rank: index + 1,
          ),
        );
      },
    );
  }
}

/// Song Card
class _SongCard extends StatelessWidget {
  final SongVote song;
  final int rank;

  const _SongCard({required this.song, required this.rank});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    final hasVoted = song.voterIds.contains(user.uid);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank <= 3 ? AppColors.accent.withValues(alpha: 0.3) : context.appColors.divider,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _getRankColor(rank),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Song Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.songName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (song.artistName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    song.artistName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Vote Button
          GestureDetector(
            onTap: () async {
              if (!hasVoted) {
                 await RadioService.instance.voteSong(song.id, user.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Voted for ${song.songName}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: hasVoted 
                    ? AppColors.radioColor.withValues(alpha: 0.1)
                    : AppColors.radioColor,
                borderRadius: BorderRadius.circular(20),
                border: hasVoted ? Border.all(color: AppColors.radioColor) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasVoted ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: hasVoted ? AppColors.radioColor : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${song.voteCount}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: hasVoted ? AppColors.radioColor : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textSecondaryLight;
  }
}

/// Shoutouts Tab
class _ShoutoutsTab extends StatelessWidget {
  const _ShoutoutsTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    final isModerator = user?.role.canModerate ?? false;

    return StreamBuilder<List<Shoutout>>(
      stream: RadioService.instance.getAllShoutoutsStream(), // Get all and filter client side for better UX if needed, or query specifically.
      // Actually strictly speaking, normal users shouldn't read pending shoutouts.
      // But we can filter here.
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         }

        var shoutouts = snapshot.data ?? [];
        
        // Filter: Moderators see all. Users see Approved.
        // Also users should probably see their own pending/rejected?
        // Let's simplified: Moderators see all. Users see Approved.
        if (!isModerator) {
          shoutouts = shoutouts.where((s) => s.status == ModerationStatus.approved || (user != null && s.authorId == user.uid)).toList();
        }

        shoutouts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (shoutouts.isEmpty) {
          return _EmptyState(
            icon: Icons.campaign_outlined,
            title: 'No shoutouts yet',
            subtitle: 'Send a message to be read on air!',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: shoutouts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ShoutoutCard(shoutout: shoutouts[index]),
        );
      },
    );
  }
}

/// Shoutout Card
class _ShoutoutCard extends StatelessWidget {
  final Shoutout shoutout;

  const _ShoutoutCard({required this.shoutout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: shoutout.isRead 
              ? AppColors.accent.withValues(alpha: 0.3) 
              : context.appColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shoutout.isRead)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, size: 12, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(
                    'Read on Air',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            '"${shoutout.message}"',
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: context.appColors.textPrimary,
              height: 1.4,
            ),
          ),
          if (shoutout.dedicatedTo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.favorite, size: 14, color: AppColors.radioColor),
                const SizedBox(width: 4),
                Text(
                  'Dedicated to ${shoutout.dedicatedTo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.radioColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.radioColor.withValues(alpha: 0.1),
                child: Text(
                  shoutout.displayAuthor[0],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.radioColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                shoutout.displayAuthor,
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                _formatTime(shoutout.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textTertiary,
                ),
              ),
            ],
          ),
          // Moderation controls for Council/Faculty
          if ((context.watch<UserProvider>().currentUser?.role.canModerate ?? false) &&
              shoutout.status == ModerationStatus.pending) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.pending, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Text(
                    'Pending Review',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  // Approve button
                  GestureDetector(
                    onTap: () => _moderateShoutout(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Reject button
                  GestureDetector(
                    onTap: () => _moderateShoutout(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Show rejected badge for rejected shoutouts
          if (shoutout.status == ModerationStatus.rejected) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 12, color: AppColors.error),
                  const SizedBox(width: 4),
                  Text(
                    'Rejected',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _moderateShoutout(BuildContext context, bool approve) async {
    try {
      await RadioService.instance.moderateShoutout(shoutout.id, approve);
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve ? 'Shoutout approved!' : 'Shoutout rejected'),
            backgroundColor: approve ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: context.appColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Song Request Sheet
class _SongRequestSheet extends StatefulWidget {
  const _SongRequestSheet();

  @override
  State<_SongRequestSheet> createState() => _SongRequestSheetState();
}

class _SongRequestSheetState extends State<_SongRequestSheet> {
  final _songController = TextEditingController();
  final _artistController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _songController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Request a Song',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _FormField(
              controller: _songController,
              label: 'Song Name',
              hint: 'e.g. Blinding Lights',
            ),
            const SizedBox(height: 16),
            _FormField(
              controller: _artistController,
              label: 'Artist (optional)',
              hint: 'e.g. The Weeknd',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.radioColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Request'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_songController.text.isEmpty) return;
    
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;
    
    setState(() => _isLoading = true);
    
    final vote = SongVote(
      id: '', // Service generates
      sessionId: 'current',
      songName: _songController.text,
      artistName: _artistController.text.isNotEmpty ? _artistController.text : null,
      requesterId: user.uid,
      requesterName: user.name,
      requestedAt: DateTime.now(),
    );

    try {
      await RadioService.instance.requestSong(vote);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Requested "${vote.songName}"!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Shoutout Sheet
class _ShoutoutSheet extends StatefulWidget {
  const _ShoutoutSheet();

  @override
  State<_ShoutoutSheet> createState() => _ShoutoutSheetState();
}

class _ShoutoutSheetState extends State<_ShoutoutSheet> {
  final _messageController = TextEditingController();
  final _dedicatedToController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _dedicatedToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Send a Shoutout',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _FormField(
              controller: _messageController,
              label: 'Your Message',
              hint: 'What do you want to say on air?',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _FormField(
              controller: _dedicatedToController,
              label: 'Dedicate to (optional)',
              hint: 'e.g. My friends in CSE-A',
            ),
            const SizedBox(height: 16),
            // Anonymous Toggle
            GestureDetector(
              onTap: () => setState(() => _isAnonymous = !_isAnonymous),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.appColors.divider),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isAnonymous ? Icons.visibility_off : Icons.visibility,
                      color: context.appColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Post Anonymously',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isAnonymous,
                      onChanged: (v) => setState(() => _isAnonymous = v),
                      activeThumbColor: AppColors.radioColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Shoutout'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_messageController.text.isEmpty) return;
    
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    
    final shoutout = Shoutout(
      id: '', // Service generates
      authorId: user.uid,
      authorName: _isAnonymous ? 'Anonymous' : user.name,
      message: _messageController.text,
      dedicatedTo: _dedicatedToController.text.isNotEmpty ? _dedicatedToController.text : null,
      isAnonymous: _isAnonymous,
      createdAt: DateTime.now(),
    );

    try {
      await RadioService.instance.submitShoutout(shoutout);
      
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shoutout submitted for review!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// Form Field Widget
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: context.appColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.appColors.textTertiary),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.appColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.radioColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
