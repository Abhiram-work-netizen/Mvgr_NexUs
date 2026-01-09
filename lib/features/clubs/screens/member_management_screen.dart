import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/club_service.dart';
import '../models/club_model.dart';

/// Member Management Screen - Manage club members and join requests
class MemberManagementScreen extends StatefulWidget {
  final Club club;

  const MemberManagementScreen({super.key, required this.club});

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen>
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
    return StreamBuilder<Club>(
      stream: ClubService.instance.getClubStream(widget.club.id),
      initialData: widget.club,
      builder: (context, clubSnapshot) {
        final club = clubSnapshot.data ?? widget.club;

        return StreamBuilder<List<ClubJoinRequest>>(
          stream: ClubService.instance.getPendingRequestsStream(club.id),
          builder: (context, requestsSnapshot) {
            final pendingRequests = requestsSnapshot.data ?? [];
            final user = context.watch<UserProvider>().currentUser;
            if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                title: const Text('Members'),
                backgroundColor: AppColors.clubsColor,
                foregroundColor: Colors.white,
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'Members (${club.totalMembers})'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Requests'),
                          if (pendingRequests.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${pendingRequests.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.clubsColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Members Tab
                  _MembersTab(club: club, currentUserId: user.uid),
                  
                  // Requests Tab
                  _RequestsTab(
                    requests: pendingRequests,
                    onApprove: (requestId) => ClubService.instance.approveMember(club.id, requestUserId(requestId, pendingRequests)),
                    onReject: (requestId) => ClubService.instance.removeMember(club.id, requestId),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  // Helper to find userId from request list (since approve needs it)
  String requestUserId(String requestId, List<ClubJoinRequest> requests) {
    return requests.firstWhere((r) => r.id == requestId).userId;
  }
}

class _MembersTab extends StatelessWidget {
  final Club club;
  final String currentUserId;

  const _MembersTab({
    required this.club,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final allMembers = [...club.adminIds, ...club.memberIds];
    final uniqueMembers = allMembers.toSet().toList();

    if (uniqueMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: context.appColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No members yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: uniqueMembers.length,
      itemBuilder: (context, index) {
        final memberId = uniqueMembers[index];
        final isAdmin = club.isAdmin(memberId);
        final isCurrentUser = memberId == currentUserId;

        return _MemberTile(
          memberId: memberId,
          isAdmin: isAdmin,
          isCurrentUser: isCurrentUser,
          onPromote: isAdmin ? null : () => _promoteMember(context, memberId),
          onRemove: isCurrentUser ? null : () => _removeMember(context, memberId),
        );
      },
    );
  }

  void _promoteMember(BuildContext context, String memberId) {
    ClubService.instance.promoteMember(club.id, memberId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member promoted to admin')),
    );
  }

  void _removeMember(BuildContext context, String memberId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: const Text('Are you sure you want to remove this member from the club?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ClubService.instance.leaveClub(club.id, memberId); // Admin removing member = logic is same as leaving?
              // Currently leaveClub removes from array. Admin can force remove.
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Member removed')),
              );
            },
            child: Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final String memberId;
  final bool isAdmin;
  final bool isCurrentUser;
  final VoidCallback? onPromote;
  final VoidCallback? onRemove;

  const _MemberTile({
    required this.memberId,
    required this.isAdmin,
    required this.isCurrentUser,
    this.onPromote,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isAdmin ? AppColors.clubsColor : AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            color: isAdmin ? Colors.white : AppColors.primary,
          ),
        ),
        title: Row(
          children: [
            Text(
              'Member ${memberId.substring(0, 8)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'You',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          isAdmin ? 'Admin' : 'Member',
          style: TextStyle(
            color: isAdmin ? AppColors.clubsColor : context.appColors.textTertiary,
            fontWeight: isAdmin ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        trailing: isCurrentUser
            ? null
            : PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  if (!isAdmin)
                    PopupMenuItem(
                      onTap: onPromote,
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 20),
                          SizedBox(width: 8),
                          Text('Promote to Admin'),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    onTap: onRemove,
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle_outline, size: 20, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('Remove', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  final List<ClubJoinRequest> requests;
  final void Function(String) onApprove;
  final void Function(String) onReject;

  const _RequestsTab({
    required this.requests,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: context.appColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join requests will appear here',
              style: TextStyle(color: context.appColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _RequestCard(
          request: request,
          onApprove: () => onApprove(request.id),
          onReject: () => onReject(request.id),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ClubJoinRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                  child: const Icon(Icons.person_add, color: AppColors.warning),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.userName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Requested ${_formatDate(request.requestedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.appColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays} days ago';
  }
}
