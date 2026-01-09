import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/meetup_service.dart';
import '../models/meetup_model.dart';

/// Premium Meetups Screen - Community Gatherings
class MeetupsScreen extends StatefulWidget {
  const MeetupsScreen({super.key});

  @override
  State<MeetupsScreen> createState() => _MeetupsScreenState();
}

class _MeetupsScreenState extends State<MeetupsScreen> {
  MeetupCategory? _selectedCategory;

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
                      AppColors.meetupsColor,
                      AppColors.meetupsColor.withValues(alpha: 0.8),
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
                          'Meetups',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find your tribe on campus',
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
                onPressed: () => _showCreateMeetupSheet(context),
                tooltip: 'Create Meetup',
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
                    ...MeetupCategory.values.map((category) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _CategoryChip(
                        label: category.displayName,
                        icon: category.icon,
                        isSelected: _selectedCategory == category,
                        onTap: () => setState(() => _selectedCategory = category),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),

          // Meetups List
          _MeetupsList(category: _selectedCategory),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateMeetupSheet(context),
        backgroundColor: AppColors.meetupsColor,
        icon: const Icon(Icons.add),
        label: const Text('Create Meetup'),
      ),
    );
  }

  void _showCreateMeetupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateMeetupSheet(),
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
          color: isSelected ? AppColors.meetupsColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.meetupsColor : context.appColors.divider,
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

/// Meetups List
class _MeetupsList extends StatelessWidget {
  final MeetupCategory? category;

  const _MeetupsList({this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Meetup>>(
      stream: MeetupService.instance.getMeetupsStream(category: category),
      builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const SliverToBoxAdapter(child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())));
         }

        var meetups = snapshot.data ?? [];
        meetups.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

        if (meetups.isEmpty) {
          return SliverFillRemaining(
            child: _EmptyState(
              icon: Icons.groups_outlined,
              title: 'No meetups scheduled',
              subtitle: 'Be the first to create one!',
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(bottom: index < meetups.length - 1 ? 16 : 0),
                child: _MeetupCard(meetup: meetups[index]),
              ),
              childCount: meetups.length,
            ),
          ),
        );
      },
    );
  }
}

/// Meetup Card
class _MeetupCard extends StatelessWidget {
  final Meetup meetup;

  const _MeetupCard({required this.meetup});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _MeetupDetailScreen(meetup: meetup)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.meetupsColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(meetup.category.iconData, size: 24, color: AppColors.meetupsColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meetup.title,
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
                        meetup.category.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.meetupsColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Recurrence Badge
                if (meetup.recurrence != RecurrenceType.once)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      meetup.recurrence.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Description
            Text(
              meetup.description,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            
            // Info Row
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: context.appColors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  _formatDate(meetup.scheduledAt),
                  style: TextStyle(fontSize: 12, color: context.appColors.textTertiary),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 14, color: context.appColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    meetup.venue,
                    style: TextStyle(fontSize: 12, color: context.appColors.textTertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            
            // Footer
            Row(
              children: [
                // Participants
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 16, color: context.appColors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      meetup.maxParticipants != null
                          ? '${meetup.participantCount}/${meetup.maxParticipants}'
                          : '${meetup.participantCount} going',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Join Button
                _JoinButton(meetup: meetup),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    
    if (diff.inDays == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (diff.inDays == 1) {
      return 'Tomorrow at ${_formatTime(date)}';
    } else if (diff.inDays < 7) {
      return '${_getDayName(date.weekday)} at ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month} at ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

/// Join Button
class _JoinButton extends StatelessWidget {
  final Meetup meetup;

  const _JoinButton({required this.meetup});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().currentUser;
    if (user == null) return const SizedBox.shrink();
    
    // We need to listen to updates for this meetup to know if I joined
    // Pass 'meetup' which comes from StreamBuilder in list or detail
    // Assuming 'meetup' passed here is fresh from StreamBuilder.
    
    final isParticipant = meetup.isParticipant(user.uid);
    final isOrganizer = meetup.isOrganizer(user.uid);

    if (isOrganizer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              'Organizer',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      );
    }

    if (isParticipant) {
      return GestureDetector(
        onTap: () async {
          await MeetupService.instance.leaveMeetup(meetup.id, user.uid);
        },
        child: Container(
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
              Text(
                'Joined',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (meetup.isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.appColors.textTertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Full',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.appColors.textTertiary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () async {
        await MeetupService.instance.joinMeetup(meetup.id, user.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined ${meetup.title}!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.meetupsColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Join',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Meetup Detail Screen
class _MeetupDetailScreen extends StatelessWidget {
  final Meetup meetup;

  const _MeetupDetailScreen({required this.meetup});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Meetup>(
      stream: MeetupService.instance.getMeetupStream(meetup.id),
      initialData: meetup,
      builder: (context, snapshot) {
        final currentMeetup = snapshot.data ?? meetup;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Meetup Details'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Category Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.meetupsColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    currentMeetup.category.icon,
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                currentMeetup.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Category & Recurrence
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.meetupsColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      currentMeetup.category.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.meetupsColor,
                      ),
                    ),
                  ),
                  if (currentMeetup.recurrence != RecurrenceType.once) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        currentMeetup.recurrence.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Info Cards
              _InfoCard(
                icon: Icons.calendar_today,
                title: 'When',
                value: _formatDateTime(currentMeetup.scheduledAt),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.access_time,
                title: 'Duration',
                value: _formatDuration(currentMeetup.duration),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.location_on_outlined,
                title: 'Where',
                value: currentMeetup.venueDetails != null
                    ? '${currentMeetup.venue} (${currentMeetup.venueDetails})'
                    : currentMeetup.venue,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.person_outline,
                title: 'Organized by',
                value: currentMeetup.organizerName,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                icon: Icons.people_outline,
                title: 'Participants',
                value: currentMeetup.maxParticipants != null
                    ? '${currentMeetup.participantCount}/${currentMeetup.maxParticipants} (${currentMeetup.spotsLeft} spots left)'
                    : '${currentMeetup.participantCount} going',
              ),
              const SizedBox(height: 24),

              // Description
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
                currentMeetup.description,
                style: TextStyle(
                  fontSize: 15,
                  color: context.appColors.textSecondary,
                  height: 1.5,
                ),
              ),

              // Tags
              if (currentMeetup.tags.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: currentMeetup.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.appColors.textTertiary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  )).toList(),
                ),
              ],

              const SizedBox(height: 32),

              // Join Button (using update object)
              Center(child: _JoinButton(meetup: currentMeetup)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${date.day} ${months[date.month - 1]} ${date.year} at $displayHour:$minute $period';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      final hours = duration.inHours;
      final mins = duration.inMinutes % 60;
      return mins > 0 ? '$hours hr $mins min' : '$hours hour${hours > 1 ? 's' : ''}';
    }
    return '${duration.inMinutes} minutes';
  }
}

/// Info Card
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.meetupsColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.meetupsColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ],
            ),
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

/// Create Meetup Sheet
class _CreateMeetupSheet extends StatefulWidget {
  const _CreateMeetupSheet();

  @override
  State<_CreateMeetupSheet> createState() => _CreateMeetupSheetState();
}

class _CreateMeetupSheetState extends State<_CreateMeetupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _venueController = TextEditingController();
  MeetupCategory _category = MeetupCategory.studyCircle;
  RecurrenceType _recurrence = RecurrenceType.once;
  DateTime _scheduledAt = DateTime.now().add(const Duration(days: 1, hours: 2));
  int? _maxParticipants;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
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
                'Create Meetup',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              _FormField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g. DSA Study Circle',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _DropdownField(
                label: 'Category',
                value: _category,
                items: MeetupCategory.values,
                displayBuilder: (c) => c.displayName,
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),

              _FormField(
                controller: _venueController,
                label: 'Venue',
                hint: 'e.g. Library Discussion Room',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Date/Time Picker
              GestureDetector(
                onTap: _pickDateTime,
                child: _PickerField(
                  label: 'When',
                  value: _formatDateTime(_scheduledAt),
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(height: 16),

              _DropdownField(
                label: 'Recurrence',
                value: _recurrence,
                items: RecurrenceType.values,
                displayBuilder: (r) => r.displayName,
                onChanged: (v) => setState(() => _recurrence = v!),
              ),
              const SizedBox(height: 16),

              _FormField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'What will you do at this meetup?',
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
                    backgroundColor: AppColors.meetupsColor,
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
                      : const Text('Create Meetup'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      if (!mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledAt),
      );
      if (time != null) {
        setState(() {
          _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${date.day}/${date.month}/${date.year} at $displayHour:$minute $period';
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final user = context.read<UserProvider>().currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final meetup = Meetup(
        id: '', // Service generates ID
        organizerId: user.uid,
        organizerName: user.name,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        venue: _venueController.text,
        scheduledAt: _scheduledAt,
        recurrence: _recurrence,
        maxParticipants: _maxParticipants,
        createdAt: DateTime.now(),
        participantIds: [user.uid],
        tags: [], // Add tags field if needed later
      );

      try {
        await MeetupService.instance.createMeetup(meetup);

        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meetup.title} created!'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
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
              borderSide: const BorderSide(color: AppColors.meetupsColor, width: 1.5),
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

/// Dropdown Field
class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) displayBuilder;
  final void Function(T?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.displayBuilder,
    required this.onChanged,
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
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.appColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(displayBuilder(item)),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
