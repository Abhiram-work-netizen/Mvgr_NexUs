import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/club_service.dart';
import '../../../services/user_service.dart';
import '../models/club_model.dart';
import '../widgets/club_widgets.dart';
import '../../../core/constants/app_constants.dart';
import 'club_members_screen.dart';

/// Club Detail Screen - Full club information view
class ClubDetailScreen extends StatelessWidget {
  final Club club;

  const ClubDetailScreen({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.userId;

    return StreamBuilder<Club>(
      stream: ClubService.instance.getClubStream(club.id),
      initialData: club,
      builder: (context, clubSnapshot) {
        final currentClub = clubSnapshot.data ?? club;

        return StreamBuilder<List<ClubPost>>(
          stream: ClubService.instance.getClubPosts(currentClub.id),
          builder: (context, postsSnapshot) {
            final posts = postsSnapshot.data ?? [];

            return Scaffold(
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.clubsColor,
                              AppColors.clubsColor.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            currentClub.category.icon,
                            style: const TextStyle(fontSize: 80),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Club Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          currentClub.name,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: context.appColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (currentClub.isOfficial) ...[
                                        const SizedBox(width: 8),
                                        Icon(Icons.verified, color: AppColors.clubsColor),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentClub.category.displayName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: AppColors.clubsColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Dynamic Member/Admin Buttons
                            _buildActionButtons(context, currentClub, userId),
                          ],
                        ),
                        
                        // Admin Controls - show if user can manage this club
                        if (userProvider.currentUser?.canManageClub(currentClub.id) == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Edit Club Logic Here')),
                                      );
                                    },
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit Details'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ClubMembersScreen(club: currentClub)),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.clubsColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.people_alt),
                                    label: const Text('Manage Members'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Stats
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.appColors.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ClubStat(value: '${currentClub.totalMembers}', label: 'Members'),
                              Container(width: 1, height: 30, color: context.appColors.divider),
                              ClubStat(value: '${posts.length}', label: 'Posts'),
                              Container(width: 1, height: 30, color: context.appColors.divider),
                              ClubStat(value: '12', label: 'Events'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // About
                        Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentClub.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: context.appColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Contact
                        if (currentClub.contactEmail != null || currentClub.instagramHandle != null) ...[
                          Text(
                            'Contact',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (currentClub.contactEmail != null)
                            ContactRow(
                              icon: Icons.email_outlined,
                              value: currentClub.contactEmail!,
                            ),
                          if (currentClub.instagramHandle != null)
                            ContactRow(
                              icon: Icons.camera_alt_outlined,
                              value: '@${currentClub.instagramHandle}',
                            ),
                          const SizedBox(height: 24),
                        ],

                        // Recent Posts
                        Text(
                          'Recent Posts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (posts.isEmpty)
                          ClubEmptyCard(message: 'No posts yet')
                        else
                          ...posts.take(3).map((post) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: PostCard(post: post),
                          )),

                        const SizedBox(height: 60),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, Club club, String userId) {
    if (userId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<String?>(
      stream: ClubService.instance.getMembershipStatus(club.id, userId),
      builder: (context, snapshot) {
        final status = snapshot.data;
        
        if (status == 'approved') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text('Member', style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        } else if (status == 'pending') {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange),
            ),
            child: Text('Requested', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
          );
        } else {
          return ElevatedButton(
            onPressed: () => ClubService.instance.requestToJoin(club.id, userId), 
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.clubsColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            ),
            child: const Text('Join Club', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          );
        }
      },
    );
  }
}
