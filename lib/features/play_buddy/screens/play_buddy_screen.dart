import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/play_buddy_service.dart';
import '../models/play_buddy_model.dart';

/// Premium Team Finder Screen
class PlayBuddyScreen extends StatefulWidget {
  const PlayBuddyScreen({super.key});

  @override
  State<PlayBuddyScreen> createState() => _PlayBuddyScreenState();
}

class _PlayBuddyScreenState extends State<PlayBuddyScreen> {
  TeamCategory? _selectedCategory;

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
                      AppColors.playBuddyColor,
                      AppColors.playBuddyColor.withValues(alpha: 0.8),
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
                          'Team Finder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find teammates for any challenge',
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
                onPressed: () => _showCreateTeamSheet(context),
                tooltip: 'Create Team',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Category Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryChip(
                      label: 'All',
                      icon: '🎯',
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                    ),
                    ...TeamCategory.values.map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: cat.displayName,
                        icon: cat.icon,
                        isSelected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),

          // Teams List
          _TeamsList(category: _selectedCategory),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTeamSheet(context),
        backgroundColor: AppColors.playBuddyColor,
        icon: const Icon(Icons.group_add),
        label: const Text('Create Team'),
      ),
    );
  }

  void _showCreateTeamSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateTeamSheet(),
    );
  }
}

/// Category Chip
class _CategoryChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.playBuddyColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.playBuddyColor : context.appColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : context.appColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Teams List
class _TeamsList extends StatelessWidget {
  final TeamCategory? category;

  const _TeamsList({this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeamRequest>>(
      stream: PlayBuddyService.instance.getTeamsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        var allTeams = snapshot.data ?? [];
        
        var teams = allTeams.where((t) {
          final matchesCategory = category == null || t.category == category;
          return matchesCategory && t.status == 'open';
        }).toList();

        // Optional: Sort by compatibility if matching logic is strong, 
        // but for now we sort by date (newest first) as requested or default.
        // We can also use MatchingService to sort by score if we want "Best Matches"
        
        // Let's do simple date sort for now to match previous behavior
        teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (teams.isEmpty) {
          return const SliverFillRemaining(
            child: _EmptyState(
              icon: Icons.groups_outlined,
              title: 'No teams looking for members',
              subtitle: 'Create one and find your squad!',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(bottom: index < teams.length - 1 ? 16 : 0),
                child: _TeamCard(team: teams[index]),
              ),
              childCount: teams.length,
            ),
          ),
        );
      },
    );
  }
}

/// Team Card
class _TeamCard extends StatelessWidget {
  final TeamRequest team;

  const _TeamCard({required this.team});

  @override
  Widget build(BuildContext context) {
    final spotsLeft = team.teamSize - team.currentMembers;
    
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.playBuddyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(team.category.iconData, size: 24, color: AppColors.playBuddyColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.title,
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
                      team.category.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.playBuddyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Spots Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: spotsLeft <= 2 
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$spotsLeft spot${spotsLeft != 1 ? 's' : ''} left',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: spotsLeft <= 2 ? AppColors.warning : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Event Name
          if (team.eventName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, size: 12, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      team.eventName!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Description
          Text(
            team.description,
            style: TextStyle(
              fontSize: 14,
              color: context.appColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Required Skills
          if (team.requiredSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: team.requiredSkills.take(4).map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.appColors.textSecondary,
                  ),
                ),
              )).toList(),
            ),
          ],
          const SizedBox(height: 14),

          // Footer
          Row(
            children: [
              // Team Progress
              Flexible(
                child: Row(
                  children: [
                    ...List.generate(team.teamSize.clamp(0, 6), (i) => Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsets.only(right: i < team.teamSize.clamp(0, 6) - 1 ? 4 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < team.currentMembers
                            ? AppColors.playBuddyColor
                            : context.appColors.divider,
                        border: Border.all(
                          color: i < team.currentMembers
                              ? AppColors.playBuddyColor
                              : context.appColors.divider,
                          width: 2,
                        ),
                      ),
                      child: i < team.currentMembers
                          ? Icon(Icons.person, size: 12, color: Colors.white)
                          : null,
                    )),
                    if (team.teamSize > 6)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          '+${team.teamSize - 6}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Deadline
              Text(
                'Deadline: ${_formatDate(team.deadline)}',
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Join Button
          Row(
            children: [
              Text(
                'by ${team.creatorName}',
                style: TextStyle(
                  fontSize: 12,
                  color: context.appColors.textTertiary,
                ),
              ),
              const Spacer(),
              _JoinButton(team: team),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.inDays <= 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return '${diff.inDays} days';
    return '${date.day}/${date.month}';
  }
}

/// Join Button
class _JoinButton extends StatelessWidget {
  final TeamRequest team;

  const _JoinButton({required this.team});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();

    final isCreator = team.creatorId == user.uid;
    final isMember = team.memberIds.contains(user.uid);

    if (isCreator) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Delete button for creator
          IconButton(
            onPressed: () => _showDeleteDialog(context, team),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            iconSize: 20,
            tooltip: 'Delete Team',
            visualDensity: VisualDensity.compact,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  'Creator',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isMember) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, size: 12, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              'Joined',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<bool>(
      future: PlayBuddyService.instance.hasRequested(team.id, user.uid),
      builder: (context, snapshot) {
        final hasRequested = snapshot.data ?? false;
        
        if (hasRequested) {
           return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Requested',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () async {
            // Simple join request for now
            // Ideally show a dialog to add message
            try {
              final joinRequest = JoinRequest(
                id: '', // Service generates
                teamRequestId: team.id, 
                userId: user.uid, 
                userName: user.name, 
                message: 'I would like to join', // Default message
                createdAt: DateTime.now()
              );
              await PlayBuddyService.instance.requestToJoin(joinRequest);
              
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Request to join "${team.title}" sent!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                // Trigger rebuild? FutureBuilder should re-run if parent rebuilds or handle state locally
                // Ideally convert this widget to StatefulWidget to update local state immediately
              }
            } catch (e) {
               if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
               }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.playBuddyColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Join Team',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    );
  }

  void _showDeleteDialog(BuildContext context, TeamRequest team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team.title}"? This will also remove all join requests. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await PlayBuddyService.instance.deleteTeam(team.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Team deleted successfully'),
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

/// Create Team Sheet
class _CreateTeamSheet extends StatefulWidget {
  const _CreateTeamSheet();

  @override
  State<_CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<_CreateTeamSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _eventNameController = TextEditingController();
  TeamCategory _category = TeamCategory.hackathon;
  int _teamSize = 4;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _eventNameController.dispose();
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
                'Find Teammates',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              _FormField(
                controller: _titleController,
                label: 'Team Name',
                hint: 'e.g. Code Crushers',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Category
              Text(
                'Category',
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
                children: TeamCategory.values.map((cat) => GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _category == cat 
                          ? AppColors.playBuddyColor 
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _category == cat 
                            ? AppColors.playBuddyColor 
                            : context.appColors.divider,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.iconData, size: 16, color: _category == cat ? Colors.white : AppColors.playBuddyColor),
                        const SizedBox(width: 4),
                        Text(
                          cat.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _category == cat 
                                ? Colors.white 
                                : context.appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              _FormField(
                controller: _eventNameController,
                label: 'Event/Competition Name (optional)',
                hint: 'e.g. Smart India Hackathon',
              ),
              const SizedBox(height: 16),

              // Team Size
              Text(
                'Team Size',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [2, 3, 4, 5, 6].map((size) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _teamSize = size),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _teamSize == size 
                            ? AppColors.playBuddyColor 
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _teamSize == size 
                              ? AppColors.playBuddyColor 
                              : context.appColors.divider,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$size',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _teamSize == size 
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

              // Deadline
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => _deadline = date);
                },
                child: _PickerField(
                  label: 'Deadline',
                  value: '${_deadline.day}/${_deadline.month}/${_deadline.year}',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(height: 16),

              _FormField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your team and what you\'re looking for...',
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
                    backgroundColor: AppColors.playBuddyColor,
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
                      : const Text('Create Team'),
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
      
      final team = TeamRequest(
        id: '', // Service generates ID
        creatorId: user.uid,
        creatorName: user.name,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        eventName: _eventNameController.text.isNotEmpty ? _eventNameController.text : null,
        teamSize: _teamSize,
        deadline: _deadline,
        createdAt: DateTime.now(),
      );

      try {
        await PlayBuddyService.instance.createTeam(team);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Team "${team.title}" created!'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
              borderSide: const BorderSide(color: AppColors.playBuddyColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

/// Picker Field
class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appColors.divider),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: context.appColors.textTertiary),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
