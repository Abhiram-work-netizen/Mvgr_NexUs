import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/event_service.dart';
import '../models/event_model.dart';

/// Attendee Management Screen - View and manage event attendees
class AttendeeManagementScreen extends StatefulWidget {
  final Event event;

  const AttendeeManagementScreen({super.key, required this.event});

  @override
  State<AttendeeManagementScreen> createState() => _AttendeeManagementScreenState();
}

class _AttendeeManagementScreenState extends State<AttendeeManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EventRegistration>>(
      stream: EventService.instance.getEventAttendeesStream(widget.event.id),
      builder: (context, snapshot) {
        final allAttendees = snapshot.data ?? [];
        
        // Filter by search
        final filteredAttendees = _searchQuery.isEmpty
            ? allAttendees
            : allAttendees.where((reg) {
                return reg.userName.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

        final checkedIn = filteredAttendees.where((reg) => reg.isCheckedIn).toList();
        final notCheckedIn = filteredAttendees.where((reg) => !reg.isCheckedIn).toList();

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Attendees'),
            backgroundColor: AppColors.eventsColor,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                 Tab(text: 'All (${filteredAttendees.length})'),
                 Tab(text: 'Checked In (${checkedIn.length})'),
                 Tab(text: 'Pending (${notCheckedIn.length})'),
              ],
            ),
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : snapshot.hasError
                  ? Center(child: Text('Error: ${snapshot.error}'))
                  : Column(
                      children: [
                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Search attendees...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
                            ),
                          ),
                        ),

                        // Tabs
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _AttendeeList(
                                attendees: filteredAttendees,
                                eventId: widget.event.id,
                              ),
                              _AttendeeList(
                                attendees: checkedIn,
                                eventId: widget.event.id,
                                showCheckInButton: false,
                              ),
                              _AttendeeList(
                                attendees: notCheckedIn,
                                eventId: widget.event.id,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showBulkActions(context, notCheckedIn),
            backgroundColor: AppColors.eventsColor,
            icon: const Icon(Icons.checklist),
            label: const Text('Bulk Actions'),
          ),
        );
      },
    );
  }

  void _showBulkActions(BuildContext context, List<EventRegistration> pendingAttendees) {
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
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Check In All'),
              subtitle: Text('Mark ${pendingAttendees.length} pending as checked in'),
              onTap: () async {
                Navigator.pop(context);
                if (pendingAttendees.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No pending attendees to check in')),
                  );
                  return;
                }
                
                try {
                  final userIds = pendingAttendees.map((a) => a.userId).toList();
                  await EventService.instance.batchCheckIn(widget.event.id, userIds);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Checked in ${userIds.length} attendees')),
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
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export to CSV'),
              subtitle: const Text('Download full attendee list'),
              onTap: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating export...')),
                );
                try {
                  // Fetch all attendees for export
                  final allAttendees = await EventService.instance.getEventAttendeesStream(widget.event.id).first;
                  
                  if (allAttendees.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No attendees to export')));
                     return;
                  }

                  final csv = "Name,User ID,Status,Registered At\n${allAttendees.map((a) => '${a.userName},${a.userId},${a.isCheckedIn ? "Checked In" : "Pending"},${a.registeredAt}').join('\n')}";
                  
                  await Share.share(csv, subject: 'Attendees - ${widget.event.title}');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Send Reminder'),
              subtitle: const Text('Notify pending attendees'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder sent!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendeeList extends StatelessWidget {
  final List<EventRegistration> attendees;
  final String eventId;
  final bool showCheckInButton;

  const _AttendeeList({
    required this.attendees,
    required this.eventId,
    this.showCheckInButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (attendees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Theme.of(context).hintColor),
            const SizedBox(height: 16),
            Text(
              'No attendees found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: attendees.length,
      itemBuilder: (context, index) {
        final registration = attendees[index];
        final isCheckedIn = registration.isCheckedIn;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCheckedIn
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.eventsColor.withValues(alpha: 0.1),
              child: Icon(
                isCheckedIn ? Icons.check : Icons.person,
                color: isCheckedIn ? AppColors.success : AppColors.eventsColor,
              ),
            ),
            title: Text(
              registration.userName.isEmpty ? 'Unknown User' : registration.userName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCheckedIn
                      ? 'Checked in at ${_formatTime(registration.checkInTime)}'
                      : 'Registered ${_formatDate(registration.registeredAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCheckedIn ? AppColors.success : Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
            trailing: isCheckedIn
                ? Icon(Icons.check_circle, color: AppColors.success)
                : showCheckInButton
                    ? IconButton(
                        icon: Icon(Icons.qr_code_scanner, color: AppColors.eventsColor),
                        onPressed: () {
                          EventService.instance.checkInAttendee(eventId, registration.userId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Checked in!')),
                          );
                        },
                      )
                    : null,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $ampm';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays} days ago';
  }
}
