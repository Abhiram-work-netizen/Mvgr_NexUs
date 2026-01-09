import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/study_buddy_service.dart';
import '../../../services/matching_service.dart';
import '../models/study_buddy_model.dart';

/// Premium Study Buddy Screen - Topic-First Matching
class StudyBuddyScreen extends StatefulWidget {
  const StudyBuddyScreen({super.key});

  @override
  State<StudyBuddyScreen> createState() => _StudyBuddyScreenState();
}

class _StudyBuddyScreenState extends State<StudyBuddyScreen>
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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Header
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.studyBuddyColor,
                      AppColors.studyBuddyColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Study Buddy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find someone to study with',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => _showCreateRequestSheet(context),
                tooltip: 'Post Request',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.studyBuddyColor,
                unselectedLabelColor: context.appColors.textSecondary,
                indicatorColor: AppColors.studyBuddyColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Browse Requests'),
                  Tab(text: 'My Requests'),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _BrowseRequestsTab(),
            _MyRequestsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRequestSheet(context),
        backgroundColor: AppColors.studyBuddyColor,
        icon: const Icon(Icons.person_add),
        label: const Text('Post Request'),
      ),
    );
  }

  void _showCreateRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateRequestSheet(),
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

/// Browse Requests Tab
class _BrowseRequestsTab extends StatelessWidget {
  const _BrowseRequestsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudyRequest>>(
      stream: StudyBuddyService.instance.getRequestsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allRequests = snapshot.data ?? [];
        final user = context.read<UserProvider>().currentUser;

        if (user == null) {
          return const Center(child: Text('Please login to browse requests'));
        }

        const matchingService = MatchingService();
        
        // Get matched requests with scores
        // We pass the full list; the service filters out own requests
        final matches = matchingService.getStudyBuddyMatches(user, allRequests, limit: 50);
        
        // Also get requests without scores (remaining ones) for browsing
        // Filter out own requests and inactive ones
        final requests = allRequests.where((r) {
          return r.isActive && !r.isOwnedBy(user.uid);
        }).toList();

        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.search_off,
            title: 'No requests yet',
            subtitle: 'Be the first to find a study buddy!',
          );
        }

        // Build a map of request ID to match score
        final scoreMap = <String, StudyBuddyMatch>{};
        for (final match in matches) {
          scoreMap[match.request.id] = match;
        }

        // Sort: matched requests first (by score), then others by date
        requests.sort((a, b) {
          final aMatch = scoreMap[a.id];
          final bMatch = scoreMap[b.id];
          if (aMatch != null && bMatch == null) return -1;
          if (aMatch == null && bMatch != null) return 1;
          if (aMatch != null && bMatch != null) {
            return bMatch.compatibilityScore.compareTo(aMatch.compatibilityScore);
          }
          return b.createdAt.compareTo(a.createdAt);
        });

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final request = requests[index];
            final match = scoreMap[request.id];
            return _RequestCard(
              request: request,
              showConnect: true,
              matchScore: match?.scorePercentage,
              matchReason: match?.matchReason,
            );
          },
        );
      },
    );
  }
}

/// My Requests Tab
class _MyRequestsTab extends StatelessWidget {
  const _MyRequestsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StudyRequest>>(
      stream: StudyBuddyService.instance.getRequestsStream(includeExpired: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final user = context.read<UserProvider>().currentUser;
        if (user == null) return const SizedBox.shrink(); // Should not happen if guarded

        final allRequests = snapshot.data ?? [];
        final requests = allRequests.where((r) {
          return r.isOwnedBy(user.uid);
        }).toList();

        requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (requests.isEmpty) {
          return const _EmptyState(
            icon: Icons.note_add_outlined,
            title: 'No requests posted',
            subtitle: 'Post a request to find study partners',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _RequestCard(
            request: requests[index],
            showConnect: false,
          ),
        );
      },
    );
  }
}

/// Request Card
class _RequestCard extends StatelessWidget {
  final StudyRequest request;
  final bool showConnect;
  final int? matchScore;
  final String? matchReason;

  const _RequestCard({
    required this.request, 
    required this.showConnect,
    this.matchScore,
    this.matchReason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: matchScore != null && matchScore! >= 60 
              ? AppColors.success.withValues(alpha: 0.4) 
              : context.appColors.divider,
          width: matchScore != null && matchScore! >= 60 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.studyBuddyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: AppColors.studyBuddyColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.subject,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request.topic,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.studyBuddyColor,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Match Score Badge (if available)
              if (matchScore != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: matchScore! >= 70 
                        ? AppColors.success.withValues(alpha: 0.1)
                        : matchScore! >= 40 
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : context.appColors.textTertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        matchScore! >= 70 ? Icons.stars : Icons.trending_up,
                        size: 12,
                        color: matchScore! >= 70 
                            ? AppColors.success 
                            : matchScore! >= 40 
                                ? AppColors.warning 
                                : context.appColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$matchScore%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: matchScore! >= 70 
                              ? AppColors.success 
                              : matchScore! >= 40 
                                  ? AppColors.warning 
                                  : context.appColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Mode Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getModeColor(request.preferredMode).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getModeIcon(request.preferredMode),
                      size: 12,
                      color: _getModeColor(request.preferredMode),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      request.preferredMode.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getModeColor(request.preferredMode),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            request.description,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Availability
          if (request.availableDays.isNotEmpty || request.preferredTime != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...request.availableDays.take(3).map((day) => _Chip(
                  label: day.substring(0, 3),
                  color: context.appColors.textTertiary,
                )),
                if (request.preferredTime != null)
                  _Chip(
                    label: request.preferredTime!,
                    color: AppColors.accent,
                  ),
              ],
            ),
          const SizedBox(height: 14),

          // Footer
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.studyBuddyColor.withValues(alpha: 0.1),
                child: Text(
                  request.userName[0],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.studyBuddyColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                request.userName,
                style: TextStyle(
                  fontSize: 13,
                  color: context.appColors.textTertiary,
                ),
              ),
              const Spacer(),
              if (showConnect)
                _ConnectButton(request: request)
              else ...[
                // Delete button for own requests
                IconButton(
                  onPressed: () => _showDeleteDialog(context, request),
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  iconSize: 20,
                  tooltip: 'Delete Request',
                ),
                const SizedBox(width: 8),
                _StatusBadge(status: request.status),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, StudyRequest request) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Request'),
        content: const Text('Are you sure you want to delete this study request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await StudyBuddyService.instance.deleteRequest(request.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Request deleted successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getModeColor(StudyMode mode) {
    switch (mode) {
      case StudyMode.online:
        return AppColors.info;
      case StudyMode.inPerson:
        return AppColors.success;
      case StudyMode.hybrid:
        return AppColors.accent;
    }
  }

  IconData _getModeIcon(StudyMode mode) {
    switch (mode) {
      case StudyMode.online:
        return Icons.videocam;
      case StudyMode.inPerson:
        return Icons.people;
      case StudyMode.hybrid:
        return Icons.device_hub;
    }
  }
}

/// Connect Button
class _ConnectButton extends StatelessWidget {
  final StudyRequest request;

  const _ConnectButton({required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connect Request'),
            content: Text(
              'Send a study request to ${request.userName} for ${request.topic}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Request sent to ${request.userName}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.studyBuddyColor,
                ),
                child: const Text('Send Request'),
              ),
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.studyBuddyColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Connect',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Status Badge
class _StatusBadge extends StatelessWidget {
  final RequestStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case RequestStatus.active:
        color = AppColors.success;
        break;
      case RequestStatus.matched:
        color = AppColors.studyBuddyColor;
        break;
      case RequestStatus.expired:
      case RequestStatus.cancelled:
        color = context.appColors.textTertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Chip Widget
class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
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

/// Create Request Sheet
class _CreateRequestSheet extends StatefulWidget {
  const _CreateRequestSheet();

  @override
  State<_CreateRequestSheet> createState() => _CreateRequestSheetState();
}

class _CreateRequestSheetState extends State<_CreateRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _descriptionController = TextEditingController();
  StudyMode _mode = StudyMode.hybrid;
  String? _preferredTime;
  final List<String> _selectedDays = [];
  bool _isLoading = false;

  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final _times = ['Morning', 'Afternoon', 'Evening', 'Night'];

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
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
                'Find a Study Buddy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              _FormField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'e.g. Data Structures',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _FormField(
                controller: _topicController,
                label: 'Topic',
                hint: 'e.g. Binary Search Trees',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Study Mode
              Text(
                'Preferred Mode',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: StudyMode.values.map((mode) => Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mode = mode),
                    child: Container(
                      margin: EdgeInsets.only(right: mode != StudyMode.hybrid ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _mode == mode 
                            ? AppColors.studyBuddyColor 
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _mode == mode 
                              ? AppColors.studyBuddyColor 
                              : context.appColors.divider,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mode.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _mode == mode 
                                ? Colors.white 
                                : context.appColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // Available Days
              Text(
                'Available Days',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _days.map((day) => GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_selectedDays.contains(day)) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays.add(day);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedDays.contains(day) 
                          ? AppColors.studyBuddyColor 
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedDays.contains(day) 
                            ? AppColors.studyBuddyColor 
                            : context.appColors.divider,
                      ),
                    ),
                    child: Text(
                      day.substring(0, 3),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _selectedDays.contains(day) 
                            ? Colors.white 
                            : context.appColors.textSecondary,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // Preferred Time
              Text(
                'Preferred Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _times.map((time) => GestureDetector(
                  onTap: () => setState(() => _preferredTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _preferredTime == time 
                          ? AppColors.accent 
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _preferredTime == time 
                            ? AppColors.accent 
                            : context.appColors.divider,
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _preferredTime == time 
                            ? Colors.white 
                            : context.appColors.textSecondary,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              _FormField(
                controller: _descriptionController,
                label: 'What do you need help with?',
                hint: 'Describe what you want to study together...',
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.studyBuddyColor,
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
                      : const Text('Post Request'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = context.read<UserProvider>().currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login')));
        return;
      }

      setState(() => _isLoading = true);
      
      final request = StudyRequest(
        id: '', // Service generates ID
        userId: user.uid,
        userName: user.name,
        subject: _subjectController.text,
        topic: _topicController.text,
        description: _descriptionController.text,
        preferredMode: _mode,
        availableDays: _selectedDays,
        preferredTime: _preferredTime,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 14)),
      );

      try {
        await StudyBuddyService.instance.createRequest(request);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request posted! We\'ll notify you when someone connects.'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

/// Form Field Widget
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
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
          validator: validator,
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
              borderSide: const BorderSide(color: AppColors.studyBuddyColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
