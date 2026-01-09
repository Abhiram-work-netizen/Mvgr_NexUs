import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/club_service.dart';
import '../../../services/event_service.dart';
import '../../clubs/models/club_model.dart';
import '../../events/models/event_model.dart';

/// Content Moderation Screen - Review and moderate content
class ContentModerationScreen extends StatefulWidget {
  final int initialTab;

  const ContentModerationScreen({super.key, this.initialTab = 0});

  @override
  State<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends State<ContentModerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
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
      appBar: AppBar(
        title: const Text('Content Moderation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Clubs'),
            Tab(text: 'Flagged'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: StreamBuilder<List<Club>>(
        stream: ClubService.instance.getClubsStream(),
        builder: (context, clubSnapshot) {
          return StreamBuilder<List<Event>>(
            stream: EventService.instance.getEventsStream(),
            builder: (context, eventSnapshot) {
              final clubs = clubSnapshot.data ?? [];
              final pendingClubs = clubs.where((c) => !c.isApproved).toList();
              
              final events = eventSnapshot.data ?? [];
              final pendingEvents = events.where((e) => !e.isPast).toList();

              return TabBarView(
                controller: _tabController,
                children: [
                  // Clubs Tab
                  _ClubApprovalTab(
                    pendingClubs: pendingClubs,
                  ),
                  
                  // Flagged Content Tab
                  _FlaggedContentTab(),
                  
                  // Events Tab
                  _EventsTab(events: pendingEvents),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ClubApprovalTab extends StatelessWidget {
  final List<Club> pendingClubs;

  const _ClubApprovalTab({
    required this.pendingClubs,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingClubs.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline,
        title: 'All caught up!',
        subtitle: 'No pending club approvals',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingClubs.length,
      itemBuilder: (context, index) {
        final club = pendingClubs[index];
        return _ApprovalCard(
          icon: club.category.icon,
          title: club.name,
          subtitle: club.description,
          metadata: 'Category: ${club.category.displayName}',
          onApprove: () async {
            try {
              final approved = club.copyWith(isApproved: true);
              await ClubService.instance.updateClub(approved);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${club.name} approved!')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          onReject: () => _showRejectDialog(context, club.name),
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String name) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject $name?'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Provide feedback...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name rejected')),
              );
            },
            child: Text('Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _FlaggedContentTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For now, show empty state since we don't have reporting system yet
    return _EmptyState(
      icon: Icons.flag_outlined,
      title: 'No flagged content',
      subtitle: 'Content reported by users will appear here',
    );
  }
}

class _EventsTab extends StatelessWidget {
  final List<Event> events;

  const _EventsTab({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _EmptyState(
        icon: Icons.event_available,
        title: 'No pending events',
        subtitle: 'All events are approved',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.take(20).length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.eventsColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(event.category.icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              event.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${event.venue} • ${_formatDate(event.eventDate)}',
              style: TextStyle(
                color: context.appColors.textTertiary,
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _ApprovalCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String metadata;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.metadata,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.clubsColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(icon, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        metadata,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.clubsColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
              style: TextStyle(color: context.appColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
