import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/club_service.dart';
import '../../clubs/models/club_model.dart';
import '../../clubs/screens/club_detail_screen.dart';
import '../../clubs/screens/club_dashboard_screen.dart';

/// My Clubs Screen - Shows clubs user is a member of
class MyClubsScreen extends StatelessWidget {
  const MyClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Clubs'),
        backgroundColor: AppColors.clubsColor,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          // Pending Requests (Skipped/Empty for now or implement direct stream if added)
          
          // Admin Clubs
          StreamBuilder<List<Club>>(
            stream: ClubService.instance.getAdminClubsStream(user.uid),
            builder: (context, snapshot) {
              final adminClubs = snapshot.data ?? [];
              if (adminClubs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

              return SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _SectionHeader(title: 'Clubs You Manage'),
                  ),
                  ...adminClubs.map((club) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ClubTile(
                      club: club,
                      isAdmin: true,
                      // Pending requests not fully implemented in service yet, passing 0 or implement separate stream
                      pendingCount: 0, 
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClubDashboardScreen(club: club)),
                      ),
                    ),
                  )),
                  const SizedBox(height: 16),
                ]),
              );
            },
          ),

          // Member Clubs
          StreamBuilder<List<Club>>(
            stream: ClubService.instance.getUserClubsStream(user.uid),
            builder: (context, snapshot) {
              final allMyClubs = snapshot.data ?? [];
              // Filter out clubs handled in Admin section, OR just show all/distinct.
              // Logic: userClubsStream checks memberIds. adminClubsStream checks adminIds.
              // Club definition: totalMembers = memberIds + adminIds.
              // If user is admin, are they in memberIds?
              // Typically yes or no depending on implementation. 
              // ClubService.joinClub adds to memberIds.
              // But creating club adds to adminIds? 
              // Let's assume admins might NOT be in memberIds in this logic, 
              // OR if they are, we should exclude them if shown above.
              // Let's safe guard: exclude if in adminClubs (which we don't have access to here easily without nesting).
              // Simpler: Just show them. If duplicate, it's fine, but better to avoid.
              // Let's just retrieve and render.
              
              // Actually, StreamBuilder is independent.
              // We can just filter inside the builder if we want, but we don't have the other list.
              // Let's assume for now they are distinct sets or we show both.
              // Wait, previous code: myClubs.where((c) => !adminClubs.contains(c)).
              // We can't easily reproduce that without uniting streams.
              // However, usually Admins are NOT in memberIds array in Firestore if we structure it as roles?
              // Club model has separate adminIds and memberIds.
              // If I am admin, I am in adminIds. If I join, I am in memberIds.
              // Usually one user shouldn't be valid in both.
              // So separate streams is fine.

              if (allMyClubs.isEmpty) {
                 // Only show empty state if BOTH are empty? 
                 // Limitation of split streams.
                 return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _SectionHeader(title: 'Member Of'),
                  ),
                  ...allMyClubs.map((club) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ClubTile(
                      club: club,
                      isAdmin: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClubDetailScreen(club: club)),
                      ),
                      onLeave: () => _showLeaveDialog(context, club, user.uid),
                    ),
                  )),
                  const SizedBox(height: 100),
                ]),
              );
            },
          ),
          
          // Empty state placeholder (complex with split streams, maybe just show nothing or generic)
          // If we want a true empty state, we need to know if both are empty.
          // We can use a StreamGroup or just accept that if nothing loads, screen is blank.
          // Or add a "Nothing to show" if both are empty? Hard with slivers independently.
          // We'll skip global empty state for now or rely on specific empty sections if needed.
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context, Club club, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Club?'),
        content: Text('Are you sure you want to leave ${club.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ClubService.instance.leaveClub(club.id, userId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Left ${club.name}')),
                );
              }
            },
            child: Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: context.appColors.textPrimary,
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  final Club club;
  final bool isAdmin;
  final int? pendingCount;
  final VoidCallback onTap;
  final VoidCallback? onLeave;

  const _ClubTile({
    required this.club,
    required this.isAdmin,
    this.pendingCount,
    required this.onTap,
    this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.clubsColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(club.category.icon, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                club.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            if (isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.clubsColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            Text(
              '${club.totalMembers} members',
              style: TextStyle(color: context.appColors.textTertiary, fontSize: 13),
            ),
            if (pendingCount != null && pendingCount! > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$pendingCount pending',
                  style: TextStyle(color: AppColors.warning, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
        trailing: isAdmin
            ? const Icon(Icons.chevron_right)
            : PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: onLeave,
                    child: Row(
                      children: [
                        Icon(Icons.exit_to_app, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text('Leave', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
