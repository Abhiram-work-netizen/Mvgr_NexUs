import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/event_service.dart';
import '../../events/models/event_model.dart';

/// Premium Announcements Screen
class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                      AppColors.primary,
                      AppColors.primaryLight,
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
                        Row(
                          children: [
                            const Text(
                              'Announcements',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.campaign, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Official',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Campus updates & important notices',
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
          ),

          // Announcements List
          StreamBuilder<List<Announcement>>(
            stream: EventService.instance.getAnnouncementsStream(),
            builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              final announcements = snapshot.data ?? [];
              
              // Sort: pinned first, then by date (if not already handled by query)
              // Query orders by createdAt descending. Pinned logic needs manual sort if not indexed.
              // Let's do client side sort for pinned.
              announcements.sort((a, b) {
                if (a.isPinned && !b.isPinned) return -1;
                if (!a.isPinned && b.isPinned) return 1;
                return b.createdAt.compareTo(a.createdAt);
              });

              if (announcements.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: EdgeInsets.only(bottom: index < announcements.length - 1 ? 16 : 0),
                      child: _AnnouncementCard(announcement: announcements[index]),
                    ),
                    childCount: announcements.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      // FAB for Council/Faculty to create announcements
      floatingActionButton: context.watch<UserProvider>().currentUser?.role.canPostAnnouncement ?? false
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateAnnouncementSheet(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.campaign, color: Colors.white),
              label: const Text('Post', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  void _showCreateAnnouncementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateAnnouncementSheet(),
    );
  }
}

/// Announcement Card
class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: announcement.isPinned 
              ? AppColors.accent.withValues(alpha: 0.4)
              : announcement.isUrgent
                  ? AppColors.error.withValues(alpha: 0.4)
                  : context.appColors.divider,
          width: announcement.isPinned || announcement.isUrgent ? 1.5 : 1,
        ),
        boxShadow: announcement.isPinned ? [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badges
          Row(
            children: [
              // Author info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getRoleColor(announcement.authorRole).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getRoleIcon(announcement.authorRole),
                  color: _getRoleColor(announcement.authorRole),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.authorName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    Text(
                      announcement.authorRole,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getRoleColor(announcement.authorRole),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Badges
              if (announcement.isPinned)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, size: 10, color: AppColors.accent),
                      const SizedBox(width: 2),
                      Text(
                        'Pinned',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              if (announcement.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.priority_high, size: 10, color: AppColors.error),
                      const SizedBox(width: 2),
                      Text(
                        'Urgent',
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
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            announcement.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Content
          Text(
            announcement.content,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),

          // Footer
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: context.appColors.textTertiary),
              const SizedBox(width: 6),
              Text(
                _formatTime(announcement.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textTertiary,
                ),
              ),
              if (announcement.expiresAt != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.timer_off_outlined, size: 14, color: context.appColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  'Expires ${_formatDate(announcement.expiresAt!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'faculty':
      case 'academic office':
        return AppColors.info;
      case 'student council':
        return AppColors.primary;
      case 'administration':
        return AppColors.secondary;
      default:
        return AppColors.textSecondaryLight;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'faculty':
      case 'academic office':
        return Icons.school;
      case 'student council':
        return Icons.groups;
      case 'administration':
        return Icons.account_balance;
      default:
        return Icons.campaign;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

/// Empty State
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: context.appColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for updates',
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

/// Create Announcement Sheet for Council/Faculty
class _CreateAnnouncementSheet extends StatefulWidget {
  const _CreateAnnouncementSheet();

  @override
  State<_CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends State<_CreateAnnouncementSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isPinned = false;
  bool _isUrgent = false;
  int _expiryDays = 7;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.appColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.campaign, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Announcement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Posting as ${user.role.displayName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Form
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Title
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title *',
                    hintText: 'Enter announcement title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),

                // Content
                TextField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Content *',
                    hintText: 'Enter announcement details...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Pinned toggle
                SwitchListTile(
                  value: _isPinned,
                  onChanged: (v) => setState(() => _isPinned = v),
                  title: const Text('Pin this announcement'),
                  subtitle: const Text('Pinned posts stay at top'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.push_pin, size: 20, color: AppColors.accent),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),

                // Urgent toggle
                SwitchListTile(
                  value: _isUrgent,
                  onChanged: (v) => setState(() => _isUrgent = v),
                  title: const Text('Mark as urgent'),
                  subtitle: const Text('Shows with red indicator'),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.warning, size: 20, color: AppColors.error),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // Expiry
                Row(
                  children: [
                    Icon(Icons.timer, size: 20, color: context.appColors.textSecondary),
                    const SizedBox(width: 12),
                    const Text('Expires in:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: _expiryDays,
                      items: [3, 7, 14, 30].map((d) => DropdownMenuItem(
                        value: d,
                        child: Text('$d days'),
                      )).toList(),
                      onChanged: (v) => setState(() => _expiryDays = v ?? 7),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Post Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: context.appColors.divider)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _postAnnouncement,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Post Announcement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _postAnnouncement() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in title and content'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;
    
    final announcement = Announcement(
      id: '', // Service generates
      title: _titleController.text,
      content: _contentController.text,
      authorId: user.uid,
      authorName: user.name,
      authorRole: user.role.displayName,
      isPinned: _isPinned,
      isUrgent: _isUrgent,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(Duration(days: _expiryDays)),
    );

    try {
      await EventService.instance.createAnnouncement(announcement);
      if (!mounted) return;
      Navigator.pop(context);
    
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Announcement posted successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
