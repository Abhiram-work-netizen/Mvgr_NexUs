import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/user_service.dart';
import '../../../services/suggestion_service.dart';
import '../../../services/event_service.dart';
import '../../../services/club_service.dart';
import '../../clubs/models/club_model.dart';
import '../../events/models/event_model.dart';

/// Section Title Widget - Reusable across home sections
class HomeSectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const HomeSectionTitle({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.appColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text('See all'),
          ),
      ],
    );
  }
}

/// Quick Access Grid - Grid of navigation items
class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      QuickItem(
        icon: Icons.groups_outlined,
        label: 'Clubs',
        color: AppColors.clubsColor,
        route: '/clubs',
      ),
      QuickItem(
        icon: Icons.event_outlined,
        label: 'Events',
        color: AppColors.eventsColor,
        route: '/events',
      ),
      QuickItem(
        icon: Icons.forum_outlined,
        label: 'Forum',
        color: AppColors.forumColor,
        route: '/forum',
      ),
      QuickItem(
        icon: Icons.folder_outlined,
        label: 'Vault',
        color: AppColors.vaultColor,
        route: '/vault',
      ),
      QuickItem(
        icon: Icons.search,
        label: 'Lost & Found',
        color: AppColors.lostFoundColor,
        route: '/lost_found',
      ),
      QuickItem(
        icon: Icons.school_outlined,
        label: 'Study Buddy',
        color: AppColors.studyBuddyColor,
        route: '/study_buddy',
      ),
      QuickItem(
        icon: Icons.sports_esports_outlined,
        label: 'Teams',
        color: AppColors.playBuddyColor,
        route: '/teams',
      ),
      QuickItem(
        icon: Icons.radio_outlined,
        label: 'Radio',
        color: AppColors.radioColor,
        route: '/radio',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }
}

/// Quick Access Item
class QuickItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const QuickItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: context.appColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Announcements Section
class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Announcement>>(
      stream: EventService.instance.getAnnouncementsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final announcements = snapshot.data!.take(3).toList();

        if (announcements.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionTitle(title: 'Announcements'),
            const SizedBox(height: 16),
            ...announcements.map(
              (announcement) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnnouncementCard(
                  title: announcement.title,
                  source: announcement.authorRole,
                  isPinned: announcement.isPinned,
                  isUrgent: announcement.isUrgent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Announcement Card
class AnnouncementCard extends StatelessWidget {
  final String title;
  final String source;
  final bool isPinned;
  final bool isUrgent;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.source,
    this.isPinned = false,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.warning.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUrgent
              ? AppColors.warning.withValues(alpha: 0.3)
              : context.appColors.divider,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPinned
                  ? AppColors.accent.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPinned ? Icons.push_pin : Icons.campaign_outlined,
              color: isPinned ? AppColors.accent : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.appColors.textPrimary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  source,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.appColors.textTertiary,
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

/// Upcoming Events Section
class UpcomingEventsSection extends StatelessWidget {
  const UpcomingEventsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.userId;
    final userName = userProvider.userName;

    return StreamBuilder<List<Event>>(
      stream: EventService.instance.getEventsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); 
        }

        final events = snapshot.data!.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionTitle(
              title: 'Upcoming Events',
              onSeeAll: () => Navigator.pushNamed(context, '/events'),
            ),
            const SizedBox(height: 16),
            if (events.isEmpty)
              HomeEmptyCard(
                icon: Icons.event_outlined,
                message: 'No upcoming events',
              )
            else
              ...events.map((event) {
                final hasRSVP = event.hasRSVP(userId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventCard(
                    title: event.title,
                    date: event.eventDate,
                    venue: event.venue,
                    rsvpCount: event.rsvpCount,
                    hasRSVP: hasRSVP,
                    onRSVP: () async {
                      try {
                        await EventService.instance.toggleRSVP(event.id, userId, userName);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

/// Event Card
class EventCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String venue;
  final int rsvpCount;
  final bool hasRSVP;
  final VoidCallback onRSVP;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.venue,
    required this.rsvpCount,
    required this.hasRSVP,
    required this.onRSVP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date Badge
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.eventsColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.eventsColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getMonthAbbr(date.month),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.eventsColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Event Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.appColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: context.appColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          venue,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.appColors.textTertiary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$rsvpCount going',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.appColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // RSVP Button
            SizedBox(
              height: 36,
              child: hasRSVP
                  ? OutlinedButton(
                      onPressed: onRSVP,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'Going',
                        style: TextStyle(fontSize: 13),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onRSVP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('RSVP', style: TextStyle(fontSize: 13)),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return months[month - 1];
  }
}

/// Active Clubs Section
class ActiveClubsSection extends StatelessWidget {
  const ActiveClubsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Club>>(
      stream: ClubService.instance.getClubsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final clubs = snapshot.data!.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeSectionTitle(
              title: 'Active Clubs',
              onSeeAll: () => Navigator.pushNamed(context, '/clubs'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 94,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: clubs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final club = clubs[index];
                  return ClubChip(
                    name: club.name,
                    icon: club.category.icon,
                    memberCount: club.totalMembers,
                    onTap: () => Navigator.pushNamed(context, '/clubs'),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Club Chip - No overflow, compact design
class ClubChip extends StatelessWidget {
  final String name;
  final String icon;
  final int memberCount;
  final VoidCallback onTap;

  const ClubChip({
    super.key,
    required this.name,
    required this.icon,
    required this.memberCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.appColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.appColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty Card - Shows when section has no content
class HomeEmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const HomeEmptyCard({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.divider),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: context.appColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: context.appColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// For You Section - Interest-based recommendations
class ForYouSection extends StatelessWidget {
  const ForYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final interests = userProvider.currentUser?.interests ?? [];
    
    return StreamBuilder<List<Club>>(
      stream: ClubService.instance.getClubsStream(),
      builder: (context, clubSnapshot) {
        return StreamBuilder<List<Event>>(
          stream: EventService.instance.getEventsStream(),
          builder: (context, eventSnapshot) {
            
            final allClubs = clubSnapshot.data ?? [];
            final allEvents = eventSnapshot.data ?? [];
            
            final suggestionService = SuggestionService();

            if (interests.isEmpty) {
              return const SetInterestsPrompt();
            }

            final suggestions = suggestionService.getAllRecommendations(
              interests,
              allClubs,
              allEvents,
              [] // Meetups ignored for now
            );

            if (suggestions.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'For You',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/interests'),
                      child: const Text('Edit Interests'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your interests: ${interests.take(3).join(', ')}${interests.length > 3 ? '...' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.appColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 16),

                // Recommended Clubs
                if (suggestions.clubs.isNotEmpty) ...[
                  Text(
                    'Clubs for you',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 95,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: suggestions.clubs.length,
                      separatorBuilder: (_, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final club = suggestions.clubs[index];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/clubs'),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.appColors.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      club.category.iconData,
                                      size: 16,
                                      color: AppColors.clubsColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        club.category.displayName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.clubsColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  club.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Recommended Events
                if (suggestions.events.isNotEmpty) ...[
                  Text(
                    'Events for you',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.appColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: suggestions.events.length,
                      separatorBuilder: (_, i) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final event = suggestions.events[index];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/events'),
                          child: Container(
                            width: 160,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: context.appColors.divider),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      event.category.iconData,
                                      size: 16,
                                      color: AppColors.eventsColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatEventDate(event.eventDate),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.eventsColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  String _formatEventDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class SetInterestsPrompt extends StatelessWidget {
  const SetInterestsPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personalize Your Feed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select interests to get better recommendations',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/interests'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
