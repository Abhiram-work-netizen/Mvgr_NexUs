import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/club_service.dart';
import '../../../services/event_service.dart';
import '../../../services/user_service.dart';
import '../../clubs/models/club_model.dart';
import '../../events/models/event_model.dart';
import 'content_moderation_screen.dart';
import 'create_announcement_screen.dart';

/// Moderation Dashboard - Main hub for council members
class ModerationDashboardScreen extends StatelessWidget {
  const ModerationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null || !user.role.canModerate) {
      return Scaffold(
        appBar: AppBar(title: const Text('Moderation')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: context.appColors.textTertiary),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'You need council or faculty privileges',
                style: TextStyle(color: context.appColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<Club>>(
      stream: ClubService.instance.getClubsStream(),
      builder: (context, clubSnapshot) {
        return StreamBuilder<List<Announcement>>(
          stream: EventService.instance.getAnnouncementsStream(),
          builder: (context, announcementSnapshot) {
            
            final clubs = clubSnapshot.data ?? [];
            final announcementsList = announcementSnapshot.data ?? [];

            // Get pending items for moderation
            // Assuming Club model has isApproved field. If not, this needs adjustment.
            // Based on ContentModerationScreen refactor plan, we assume it exists or will check.
            // If Club model doesn't have it, we might need to filter by something else or add it.
            // For now, assuming isApproved exists as per previous context.
            final pendingClubs = clubs.where((c) => !c.isApproved).length;
            final announcements = announcementsList.length;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  SliverAppBar(
                    expandedHeight: 160,
                    pinned: true,
                    backgroundColor: AppColors.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
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
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Moderation Hub',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            user.role.displayName,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Stats Overview
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          _StatCard(
                            icon: Icons.pending_actions,
                            value: '$pendingClubs',
                            label: 'Pending Clubs',
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.campaign,
                            value: '$announcements',
                            label: 'Announcements',
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.flag,
                            value: '0',
                            label: 'Flagged',
                            color: AppColors.error,
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
                            'Moderation Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _ActionTile(
                            icon: Icons.campaign,
                            title: 'Create Announcement',
                            subtitle: 'Send important updates to everyone',
                            color: AppColors.primary,
                            badge: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          _ActionTile(
                            icon: Icons.groups,
                            title: 'Club Approvals',
                            subtitle: 'Review pending club requests',
                            color: AppColors.clubsColor,
                            badge: pendingClubs > 0 ? '$pendingClubs' : null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ContentModerationScreen(initialTab: 0)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          _ActionTile(
                            icon: Icons.flag_outlined,
                            title: 'Flagged Content',
                            subtitle: 'Review reported posts and content',
                            color: AppColors.error,
                            badge: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ContentModerationScreen(initialTab: 1)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          _ActionTile(
                            icon: Icons.event,
                            title: 'Event Approvals',
                            subtitle: 'Review pending events',
                            color: AppColors.eventsColor,
                            badge: null,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ContentModerationScreen(initialTab: 2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent Activity
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.appColors.divider),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.history, size: 48, color: context.appColors.textTertiary),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No recent activity',
                                    style: TextStyle(
                                      color: context.appColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        );
      },
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
                fontSize: 11,
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
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
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right, color: context.appColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
