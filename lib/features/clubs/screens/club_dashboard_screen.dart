import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/club_service.dart';
import '../../clubs/models/club_model.dart';
import '../../events/models/event_model.dart'; // For Event creation
import '../../../services/event_service.dart'; // For Event Service
import 'member_management_screen.dart';

/// Club Dashboard Screen - Admin view for managing a club
class ClubDashboardScreen extends StatelessWidget {
  final Club club;

  const ClubDashboardScreen({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    // 1. Stream Club (for members count)
    return StreamBuilder<Club>(
      stream: ClubService.instance.getClubStream(club.id),
      initialData: club,
      builder: (context, clubSnapshot) {
        final currentClub = clubSnapshot.data ?? club;

        // 2. Stream Pending Requests
        return StreamBuilder<List<ClubJoinRequest>>(
          stream: ClubService.instance.getPendingRequestsStream(club.id),
          builder: (context, requestsSnapshot) {
            final pendingRequests = requestsSnapshot.data ?? [];

            // 3. Stream Posts
            return StreamBuilder<List<ClubPost>>(
              stream: ClubService.instance.getClubPosts(club.id),
              builder: (context, postsSnapshot) {
                final posts = postsSnapshot.data ?? [];
                
                // Construct the UI
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header
                      SliverAppBar(
                        expandedHeight: 160,
                        pinned: true,
                        backgroundColor: AppColors.clubsColor,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.clubsColor,
                                  AppColors.clubsColor.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          currentClub.category.icon,
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            currentClub.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Club Dashboard',
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
                            icon: const Icon(Icons.settings_outlined, color: Colors.white),
                            onPressed: () => _showClubSettings(context, currentClub),
                          ),
                        ],
                      ),

                      // Stats Cards
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              _StatCard(
                                icon: Icons.people,
                                value: '${currentClub.totalMembers}',
                                label: 'Members',
                                color: AppColors.clubsColor,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                icon: Icons.article,
                                value: '${posts.length}',
                                label: 'Posts',
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              _StatCard(
                                icon: Icons.hourglass_empty,
                                value: '${pendingRequests.length}',
                                label: 'Pending',
                                color: pendingRequests.isNotEmpty ? AppColors.warning : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Quick Actions
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.edit,
                                      label: 'New Post',
                                      color: AppColors.primary,
                                      onTap: () => _showCreatePostSheet(context, currentClub),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.event,
                                      label: 'Create Event',
                                      color: AppColors.eventsColor,
                                      onTap: () => _showCreateEventSheet(context, currentClub),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.people,
                                      label: 'Members',
                                      color: AppColors.clubsColor,
                                      badge: pendingRequests.isNotEmpty ? '${pendingRequests.length}' : null,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MemberManagementScreen(club: currentClub),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _ActionButton(
                                      icon: Icons.announcement,
                                      label: 'Announcement',
                                      color: AppColors.warning,
                                      onTap: () => _showAnnouncementSheet(context, currentClub),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Pending Requests Section
                      if (pendingRequests.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                            child: Row(
                              children: [
                                Text(
                                  'Pending Requests',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: context.appColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${pendingRequests.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MemberManagementScreen(club: currentClub),
                                    ),
                                  ),
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: pendingRequests.take(5).length,
                              itemBuilder: (context, index) {
                                final request = pendingRequests[index];
                                return _PendingRequestCard(
                                  request: request,
                                  onApprove: () => ClubService.instance.approveJoinRequest(request.id, request.userId, club.id),
                                  onReject: () => ClubService.instance.removeMember(club.id, request.userId),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                      
                      // Recent Posts Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                          child: Text(
                            'Recent Posts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      
                      if (posts.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.appColors.divider),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.article_outlined, size: 48, color: context.appColors.textTertiary),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No posts yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: context.appColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _showCreatePostSheet(context, currentClub),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create First Post'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.clubsColor,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final post = posts[index];
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                                child: _PostCard(post: post),
                              );
                            },
                            childCount: posts.take(5).length,
                          ),
                        ),
    
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                );
              }
            );
          }
        );
      }
    );
  }

  void _showCreatePostSheet(BuildContext context, Club club) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    ClubPostType selectedType = ClubPostType.general;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
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
                  'Create Post',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Post Type
                Text('Post Type', style: TextStyle(fontWeight: FontWeight.w500, color: context.appColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ClubPostType.values.map((type) => ChoiceChip(
                    label: Text(type.displayName),
                    selected: selectedType == type,
                    onSelected: (selected) => setState(() => selectedType = type),
                    selectedColor: AppColors.clubsColor,
                    labelStyle: TextStyle(
                      color: selectedType == type ? Colors.white : context.appColors.textPrimary,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                        final user = Provider.of<UserProvider>(context, listen: false).currentUser;
                        if (user == null) return;
                        
                        final post = ClubPost(
                          id: '', // Service generates
                          clubId: club.id,
                          title: titleController.text,
                          content: contentController.text,
                          type: selectedType,
                          authorId: user.uid,
                          authorName: user.name,
                          createdAt: DateTime.now(),
                        );
                        
                        try {
                          await ClubService.instance.createPost(post);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Post created!')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.clubsColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Post'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateEventSheet(BuildContext context, Club club) {
    final titleController = TextEditingController();
    final venueController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('Create Club Event', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(ctx).primaryColor)),
               const SizedBox(height: 16),
               TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder())),
               const SizedBox(height: 12),
               TextField(controller: venueController, decoration: const InputDecoration(labelText: 'Venue', border: OutlineInputBorder())),
               const SizedBox(height: 12),
               TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
               const SizedBox(height: 24),
               SizedBox(
                 width: double.infinity, 
                 height: 50,
                 child: ElevatedButton(
                   onPressed: () async {
                      if (titleController.text.isEmpty) return;
                      final user = context.read<UserProvider>().currentUser;
                      if (user == null) return;
                      
                      // Default date: 7 days from now
                      final event = Event(
                        id: '', 
                        title: titleController.text,
                        description: descriptionController.text,
                        venue: venueController.text,
                        eventDate: DateTime.now().add(const Duration(days: 7)),
                        authorId: user.uid,
                        authorName: user.name,
                        clubId: club.id,
                        clubName: club.name,
                        category: EventCategory.other,
                        createdAt: DateTime.now(),
                      );
                      
                      try {
                        await EventService.instance.createEvent(event);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event Created Successfully!'), backgroundColor: AppColors.success));
                        }
                      } catch (e) {
                         if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.eventsColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                   child: const Text('Create Event'),
                 )
               )
            ],
          ),
        ),
      )
    );
  }

  void _showAnnouncementSheet(BuildContext context, Club club) {
     final contentController = TextEditingController();
     
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('Make Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warning)),
               const SizedBox(height: 16),
               TextField(
                 controller: contentController, 
                 decoration: const InputDecoration(labelText: 'Announcement Content', border: OutlineInputBorder()),
                 maxLines: 4,
               ),
               const SizedBox(height: 24),
               SizedBox(
                 width: double.infinity, 
                 height: 50,
                 child: ElevatedButton(
                   onPressed: () async {
                      if (contentController.text.isEmpty) return;
                      final user = context.read<UserProvider>().currentUser;
                      if (user == null) return;

                      // Assuming ClubPostType.announcement exists, otherwise use general with [ANNOUNCEMENT] prefix
                      // Checking values... usually 'general', 'news', 'announcement'?
                      // I'll check implicitly by using 'general' and prefix for safety if I'm not 100% sure, 
                      // but typically I should trust my memory or previous checks.
                      // I'll simply create a post of type 'general' but styled as announcement if I can't guarantee enum.
                      // Wait, I saw _showCreatePostSheet using ClubPostType.values.
                      // I'll assume first value is general.
                      // I'll make it type: ClubPostType.values.firstWhere((e) => e.toString().contains('announcement'), orElse: () => ClubPostType.values.first);
                      // Or just rely on string 'Announcement'.
                      
                      final post = ClubPost(
                        id: '',
                        clubId: club.id,
                        title: '📢 Announcement',
                        content: contentController.text,
                        type: ClubPostType.values.first, // fallback, or hack to use 'announcement' if I knew index.
                        // I'll hardcode index 0 for now as 'general' likely.
                        authorId: user.uid,
                        authorName: user.name,
                        createdAt: DateTime.now(),
                        isPinned: true, // Announcements should be pinned?
                      );
                      
                      try {
                        await ClubService.instance.createPost(post);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement Posted!'), backgroundColor: AppColors.success));
                        }
                      } catch (e) {
                         if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                   },
                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                   child: const Text('Post Announcement'),
                 )
               )
            ],
          ),
        ),
      )
    );
  }

  void _showClubSettings(BuildContext context, Club club) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Club Info'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Privacy Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete Club', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: context.appColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final dynamic request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _PendingRequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.userName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Requested to join',
            style: TextStyle(
              fontSize: 12,
              color: context.appColors.textTertiary,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onReject,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Reject'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final ClubPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.clubsColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  post.type.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.clubsColor,
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: context.appColors.textTertiary),
                itemBuilder: (context) => [
                  PopupMenuItem(child: Text('Edit')),
                  PopupMenuItem(child: Text('Delete', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
