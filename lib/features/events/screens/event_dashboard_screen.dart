import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/event_service.dart';
import '../models/event_model.dart';
import 'attendee_management_screen.dart';

/// Event Dashboard Screen - Organizer view for managing an event
class EventDashboardScreen extends StatelessWidget {
  final Event event;

  const EventDashboardScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
      stream: EventService.instance.getEventStream(event.id),
      initialData: event,
      builder: (context, eventSnapshot) {
        final currentEvent = eventSnapshot.data ?? event;

        return StreamBuilder<List<EventRegistration>>(
          stream: EventService.instance.getEventAttendeesStream(event.id),
          builder: (context, attendeesSnapshot) {
            final attendees = attendeesSnapshot.data ?? [];
            final checkedInCount = attendees.where((a) => a.isCheckedIn).length;

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    backgroundColor: AppColors.eventsColor,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.eventsColor,
                              AppColors.eventsColor.withValues(alpha: 0.8),
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
                                    Text(
                                      currentEvent.category.icon,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            currentEvent.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatEventDate(currentEvent.eventDate),
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.85),
                                              fontSize: 13,
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
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.white),
                        onPressed: () => _showEditEventSheet(context, currentEvent),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () => _showEventOptions(context, currentEvent),
                      ),
                    ],
                  ),

                  // Stats Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          _StatCard(
                            icon: Icons.people,
                            value: '${currentEvent.rsvpIds.length}',
                            label: 'RSVPs',
                            color: AppColors.eventsColor,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.check_circle,
                            value: '$checkedInCount',
                            label: 'Checked In',
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          _StatCard(
                            icon: Icons.visibility,
                            value: '${currentEvent.rsvpIds.length}', // Using RSVP as views proxy for now, implies interest
                            label: 'Views',
                            color: AppColors.primary,
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
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.qr_code_scanner,
                                  label: 'Check-in',
                                  color: AppColors.success,
                                  onTap: () => _showCheckInSheet(context, currentEvent),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.people,
                                  label: 'Attendees',
                                  color: AppColors.eventsColor,
                                  badge: attendees.isNotEmpty ? '${attendees.length}' : null,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AttendeeManagementScreen(event: currentEvent),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.notifications_active,
                                  label: 'Notify All',
                                  color: AppColors.warning,
                                  onTap: () => _showNotifySheet(context, currentEvent),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.download,
                                  label: 'Export List',
                                  color: AppColors.primary,
                                  onTap: () => _exportAttendees(context, currentEvent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Event Details
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Event Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: context.appColors.divider),
                            ),
                            child: Column(
                              children: [
                                _DetailRow(
                                  icon: Icons.calendar_today,
                                  label: 'Date',
                                  value: _formatEventDate(currentEvent.eventDate),
                                ),
                                const Divider(height: 24),
                                _DetailRow(
                                  icon: Icons.access_time,
                                  label: 'Time',
                                  value: _formatEventTime(currentEvent.eventDate),
                                ),
                                const Divider(height: 24),
                                _DetailRow(
                                  icon: Icons.location_on,
                                  label: 'Venue',
                                  value: currentEvent.venue,
                                ),
                                const Divider(height: 24),
                                _DetailRow(
                                  icon: Icons.category,
                                  label: 'Category',
                                  value: currentEvent.category.displayName,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent Check-ins
                  if (attendees.where((a) => a.isCheckedIn).isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: Text(
                          'Recent Check-ins',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: attendees.where((a) => a.isCheckedIn).take(10).length,
                          itemBuilder: (context, index) {
                            final attendee = attendees.where((a) => a.isCheckedIn).toList()[index];
                            return Container(
                              width: 60,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.success.withValues(alpha: 0.1),
                                    child: Icon(Icons.check, color: AppColors.success),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    attendee.userName.split(' ').first,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.appColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          }
        );
      },
    );
  }

  String _formatEventDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatEventTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  void _showCheckInSheet(BuildContext context, Event event) {
    final searchController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.appColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Check-in Attendees',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.appColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<EventRegistration>>(
                stream: EventService.instance.getEventAttendeesStream(event.id),
                builder: (context, snapshot) {
                  final attendees = snapshot.data ?? [];
                  if (attendees.isEmpty) {
                    return Center(
                      child: Text(
                        'No RSVPs yet',
                        style: TextStyle(color: context.appColors.textTertiary),
                      ),
                    );
                  }
                  
                  // Filter by search (simple local filtering)
                  // In real app, consider backend search if list is huge
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: attendees.length,
                    itemBuilder: (context, index) {
                      final attendee = attendees[index];
                      // Should implement search filter here if `searchController` changes (needs setState/ValueListenable)
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: attendee.isCheckedIn
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.eventsColor.withValues(alpha: 0.1),
                            child: Icon(
                              attendee.isCheckedIn ? Icons.check : Icons.person,
                              color: attendee.isCheckedIn ? AppColors.success : AppColors.eventsColor,
                            ),
                          ),
                          title: Text(
                            attendee.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.appColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            attendee.isCheckedIn ? 'Checked in' : 'Not checked in',
                            style: TextStyle(
                              color: attendee.isCheckedIn ? AppColors.success : context.appColors.textTertiary,
                            ),
                          ),
                          trailing: attendee.isCheckedIn
                              ? Icon(Icons.check_circle, color: AppColors.success)
                              : ElevatedButton(
                                  onPressed: () {
                                    EventService.instance.checkInAttendee(event.id, attendee.userId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Checked in!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Check In'),
                                ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditEventSheet(BuildContext context, Event event) {
    final titleController = TextEditingController(text: event.title);
    final venueController = TextEditingController(text: event.venue);
    final descriptionController = TextEditingController(text: event.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                 'Edit Event', 
                 style: TextStyle(
                   fontSize: 20, 
                   fontWeight: FontWeight.bold, 
                   color: Theme.of(ctx).primaryColor
                 )
               ), 
               const SizedBox(height: 16),
               TextField(
                 controller: titleController, 
                 decoration: InputDecoration(
                   labelText: 'Title', 
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                 )
               ),
               const SizedBox(height: 12),
               TextField(
                 controller: venueController, 
                 decoration: InputDecoration(
                   labelText: 'Venue', 
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                 )
               ),
               const SizedBox(height: 12),
               TextField(
                 controller: descriptionController, 
                 decoration: InputDecoration(
                   labelText: 'Description', 
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                 ), 
                 maxLines: 3
               ),
               const SizedBox(height: 24),
               SizedBox(
                 width: double.infinity, 
                 height: 50,
                 child: ElevatedButton(
                   onPressed: () async {
                      try {
                        final updated = event.copyWith(
                          title: titleController.text,
                          venue: venueController.text,
                          description: descriptionController.text,
                        );
                        await EventService.instance.updateEvent(updated);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Event updated successfully!'), backgroundColor: AppColors.success)
                          );
                        }
                      } catch (e) {
                         if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error)
                            );
                         }
                      }
                   },
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppColors.eventsColor,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                   ),
                   child: const Text('Save Changes'),
                 )
               ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventOptions(BuildContext context, Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Event'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Event'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined, color: AppColors.warning),
              title: Text('Cancel Event', style: TextStyle(color: AppColors.warning)),
              onTap: () {
                Navigator.pop(context);
                _showCancelConfirmation(context, event);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.error),
              title: Text('Delete Event', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, event);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event?'),
        content: const Text('This will notify all attendees.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await EventService.instance.cancelEvent(event.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close options
                  Navigator.pop(context); // Go back to prev screen if needed, or just show cancelled status
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event cancelled')),
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
            child: Text('Cancel Event', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await EventService.instance.deleteEvent(event.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close options
                  Navigator.pop(context); // Close dashboard (event acts deleted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event deleted')),
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
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showNotifySheet(BuildContext context, Event event) {
      final messageController = TextEditingController();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Notify Attendees'),
          content: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              hintText: 'Enter message...', 
              border: OutlineInputBorder()
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.isNotEmpty) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notification sent to ${event.rsvpIds.length} attendees'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      );
  }

  void _exportAttendees(BuildContext context, Event event) async {
      try {
        final attendees = await EventService.instance.getEventAttendeesStream(event.id).first;
        if (attendees.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No attendees to export')));
           return;
        }
        final csv = "Name,Roll Number,Status,Registered At\n${attendees.map((a) => '${a.userName},${a.rollNumber},${a.isCheckedIn ? "Checked In" : "Pending"},${a.registeredAt}').join('\n')}";
        await Share.share(csv, subject: 'Event Attendees - ${event.title}');
      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
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
                fontSize: 12,
                color: context.appColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: context.appColors.textPrimary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.appColors.textTertiary),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: context.appColors.textTertiary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: context.appColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
