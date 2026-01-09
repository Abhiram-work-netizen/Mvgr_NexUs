import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/mentorship_service.dart';
import '../models/mentorship_model.dart';
import '../../../core/utils/helpers.dart';

/// Premium Mentorship Screen - Find Your Guide
class MentorshipScreen extends StatefulWidget {
  const MentorshipScreen({super.key});

  @override
  State<MentorshipScreen> createState() => _MentorshipScreenState();
}

class _MentorshipScreenState extends State<MentorshipScreen> {
  MentorshipArea? _selectedArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false, // No back arrow for main nav screen
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mentorshipColor,
                      AppColors.mentorshipColor.withValues(alpha: 0.85),
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mentorship',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Connect with experienced guides',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats Row
                        Row(
                          children: [
                            _StatBadge(value: '12+', label: 'Mentors'),
                            const SizedBox(width: 10),
                            _StatBadge(value: '50+', label: 'Sessions'),
                            const SizedBox(width: 10),
                            _StatBadge(value: '6', label: 'Areas'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Area Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _AreaChip(
                      label: 'All',
                      icon: '🎯',
                      isSelected: _selectedArea == null,
                      onTap: () => setState(() => _selectedArea = null),
                    ),
                    ...MentorshipArea.values.map(
                      (area) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _AreaChip(
                          label: area.displayName,
                          icon: area.icon,
                          isSelected: _selectedArea == area,
                          onTap: () => setState(() => _selectedArea = area),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Mentors List
          _MentorsList(area: _selectedArea),
        ],
      ),
    );
  }
}

/// Stat Badge
class _StatBadge extends StatelessWidget {
  final String value;
  final String label;

  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// Area Chip
class _AreaChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AreaChip({
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
          color: isSelected
              ? AppColors.mentorshipColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.mentorshipColor
                : context.appColors.divider,
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
                fontSize: 12,
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

/// Mentors List
class _MentorsList extends StatelessWidget {
  final MentorshipArea? area;

  const _MentorsList({this.area});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Mentor>>(
      stream: MentorshipService.instance.getMentorsStream(area: area),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
           return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final mentors = snapshot.data ?? [];

        if (mentors.isEmpty) {
          return const SliverFillRemaining(
            child: _EmptyState(
              icon: Icons.school_outlined,
              title: 'No mentors available',
              subtitle: 'Check back later for new mentors',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < mentors.length - 1 ? 16 : 0,
                ),
                child: _MentorCard(mentor: mentors[index]),
              ),
              childCount: mentors.length,
            ),
          ),
        );
      },
    );
  }
}

/// Mentor Card
class _MentorCard extends StatelessWidget {
  final Mentor mentor;

  const _MentorCard({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _MentorDetailScreen(mentor: mentor)),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
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
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getTypeColor(mentor.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      NameHelpers.getInitials(mentor.name),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _getTypeColor(mentor.type),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mentor.designation ?? mentor.type.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          color: _getTypeColor(mentor.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (mentor.department != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          mentor.department!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.appColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(mentor.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    mentor.type.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(mentor.type),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Bio
            Text(
              mentor.bio,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),

            // Areas
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mentor.areas
                  .map(
                    (area) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mentorshipColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            area.iconData,
                            size: 14,
                            color: AppColors.mentorshipColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            area.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.mentorshipColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),

            // Footer
            Row(
              children: [
                // Slots
                Icon(
                  Icons.people_outline,
                  size: 14,
                  color: context.appColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${mentor.availableSlots} slots left',
                  style: TextStyle(
                    fontSize: 12,
                    color: mentor.hasCapacity
                        ? AppColors.success
                        : context.appColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Connect Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: mentor.hasCapacity
                        ? AppColors.mentorshipColor
                        : context.appColors.textTertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    mentor.hasCapacity ? 'Connect' : 'Full',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: mentor.hasCapacity
                          ? Colors.white
                          : context.appColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(MentorType type) {
    switch (type) {
      case MentorType.faculty:
        return AppColors.info;
      case MentorType.senior:
        return AppColors.success;
      case MentorType.alumni:
        return AppColors.accent;
    }
  }
}

/// Mentor Detail Screen
class _MentorDetailScreen extends StatelessWidget {
  final Mentor mentor;

  const _MentorDetailScreen({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mentor Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _getTypeColor(mentor.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      NameHelpers.getInitials(mentor.name),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: _getTypeColor(mentor.type),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  mentor.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mentor.designation ?? mentor.type.displayName,
                  style: TextStyle(
                    fontSize: 15,
                    color: _getTypeColor(mentor.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (mentor.department != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    mentor.department!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  value: '${mentor.currentMentees}/${mentor.maxMentees}',
                  label: 'Mentees',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.star,
                  value: '${mentor.areas.length}',
                  label: 'Areas',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.workspace_premium,
                  value: '${mentor.expertise.length}',
                  label: 'Skills',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bio
          Text(
            'About',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            mentor.bio,
            style: TextStyle(
              fontSize: 15,
              color: context.appColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Areas
          Text(
            'Mentorship Areas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mentor.areas
                .map(
                  (area) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mentorshipColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          area.iconData,
                          size: 18,
                          color: AppColors.mentorshipColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          area.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mentorshipColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          // Expertise
          if (mentor.expertise.isNotEmpty) ...[
            Text(
              'Expertise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: mentor.expertise
                  .map(
                    (skill) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.appColors.divider),
                      ),
                      child: Text(
                        skill,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Request Button
          if (mentor.hasCapacity)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _showRequestSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mentorshipColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Request Mentorship'),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _getTypeColor(MentorType type) {
    switch (type) {
      case MentorType.faculty:
        return AppColors.info;
      case MentorType.senior:
        return AppColors.success;
      case MentorType.alumni:
        return AppColors.accent;
    }
  }

  void _showRequestSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RequestMentorshipSheet(mentor: mentor),
    );
  }
}

/// Stat Card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.mentorshipColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: context.appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: context.appColors.textTertiary),
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

/// Request Mentorship Sheet
class _RequestMentorshipSheet extends StatefulWidget {
  final Mentor mentor;

  const _RequestMentorshipSheet({required this.mentor});

  @override
  State<_RequestMentorshipSheet> createState() =>
      _RequestMentorshipSheetState();
}

class _RequestMentorshipSheetState extends State<_RequestMentorshipSheet> {
  final _messageController = TextEditingController();
  final _goalController = TextEditingController();
  MentorshipArea? _selectedArea;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedArea = widget.mentor.areas.first;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              'Request Mentorship',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.appColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'with ${widget.mentor.name}',
              style: TextStyle(
                fontSize: 15,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Area Selection
            Text(
              'What area do you need help with?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.appColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.mentor.areas
                  .map(
                    (area) => GestureDetector(
                      onTap: () => setState(() => _selectedArea = area),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedArea == area
                              ? AppColors.mentorshipColor
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedArea == area
                                ? AppColors.mentorshipColor
                                : context.appColors.divider,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              area.iconData,
                              size: 18,
                              color: _selectedArea == area
                                  ? Colors.white
                                  : AppColors.mentorshipColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              area.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _selectedArea == area
                                    ? Colors.white
                                    : context.appColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            _FormField(
              controller: _messageController,
              label: 'Why do you want this mentorship?',
              hint:
                  'Tell the mentor about yourself and why you\'re reaching out...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            _FormField(
              controller: _goalController,
              label: 'What do you hope to achieve?',
              hint: 'Describe your goals...',
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mentorshipColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Send Request'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_selectedArea == null || _messageController.text.isEmpty) return;

    final user = context.read<UserProvider>().currentUser;
    if (user == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login')));
       return;
    }

    setState(() => _isLoading = true);
    
    final request = MentorshipRequest(
      id: '', // Service generates
      mentorId: widget.mentor.id,
      menteeId: user.uid,
      menteeName: user.name,
      area: _selectedArea!,
      message: _messageController.text,
      goal: _goalController.text,
      createdAt: DateTime.now(),
    );

    try {
      await MentorshipService.instance.submitRequest(request);

      if (!mounted) return;
      Navigator.pop(context); // Close sheet
      
      // Need to make sure we don't pop twice if not needed, structure seems to show sheet is pushed.
      // Actually previous code popped twice?
      // Navigator.pop(context); // Previous code had 2 pops? 
      // check previous code
      // Navigator.pop(context);
      // Navigator.pop(context);
      
      // The sheet is shown with showModalBottomSheet. Pop once.
      // If previous code popped twice, maybe it was navigating back from Detail Screen too?
      // The button is in Detail Screen.
      // _showRequestSheet calls showModalBottomSheet. 
      // DetailScreen handles the UI.
      // If I pop once, I'm back to DetailScreen.
      // If I pop twice, I'm back to List.
      // Previous code:
      // Navigator.pop(context);
      // Navigator.pop(context);
      // Maybe intentional to close sheet AND detail screen to show snackbar on list?
      // Or maybe detail screen uses sheet? No.
      // Let's stick to popping the sheet first. If user wants to go back they can.
      // But let's follow the previous logic if it made sense. Mentorship requests usually don't need to close the profile.
      // Wait, let's look at previous code again.
      // It popped twice.
      // Let's do pop once for now, it feels safer.
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent to ${widget.mentor.name}!'),
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

/// Form Field Widget
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
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
              borderSide: const BorderSide(
                color: AppColors.mentorshipColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
