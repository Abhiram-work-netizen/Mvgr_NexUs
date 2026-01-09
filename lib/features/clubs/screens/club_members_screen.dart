import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/club_service.dart';
import '../../clubs/models/club_model.dart';
import 'package:provider/provider.dart';
import '../../../services/user_service.dart';

class ClubMembersScreen extends StatelessWidget {
  final Club club;

  const ClubMembersScreen({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Manage ${club.name}'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          bottom: TabBar(
            labelColor: AppColors.clubsColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.clubsColor,
            tabs: const [
              Tab(text: 'Requests'),
              Tab(text: 'Members'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RequestsTab(clubId: club.id),
            _MembersTab(clubId: club.id),
          ],
        ),
      ),
    );
  }
}

class _RequestsTab extends StatelessWidget {
  final String clubId;
  const _RequestsTab({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ClubService.instance.getPendingRequests(clubId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final uid = req['uid'] as String;
            // Ideally fetch User Profile for name/details, here showing UID/Time
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text('User: $uid'), // TODO: Resolve name
                subtitle: Text('Requested: ${req['joinedAt'] ?? 'Now'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => ClubService.instance.approveMember(clubId, uid),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => ClubService.instance.removeMember(clubId, uid), 
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MembersTab extends StatelessWidget {
  final String clubId;
  const _MembersTab({required this.clubId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ClubService.instance.getMembersStream(clubId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        // Filter approved members
        final members = snapshot.data!.where((m) => m['status'] == 'approved').toList();

        if (members.isEmpty) return const Center(child: Text('No approved members'));

        return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(member['uid'] ?? 'Unknown'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => ClubService.instance.removeMember(clubId, member['uid']),
              ),
            );
          },
        );
      },
    );
  }
}
