import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Event categories
enum EventCategory {
  academic,
  cultural,
  sports,
  hackathon,
  workshop,
  seminar,
  competition,
  other;
  
  String get displayName {
    switch (this) {
      case EventCategory.academic:
        return 'Academic';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.hackathon:
        return 'Hackathon';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.seminar:
        return 'Seminar';
      case EventCategory.competition:
        return 'Competition';
      case EventCategory.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case EventCategory.academic:
        return '📖';
      case EventCategory.cultural:
        return '🎨';
      case EventCategory.sports:
        return '🏆';
      case EventCategory.hackathon:
        return '💻';
      case EventCategory.workshop:
        return '🛠️';
      case EventCategory.seminar:
        return '🎤';
      case EventCategory.competition:
        return '🏅';
      case EventCategory.other:
        return '📅';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case EventCategory.academic:
        return Icons.menu_book_rounded;
      case EventCategory.cultural:
        return Icons.palette_rounded;
      case EventCategory.sports:
        return Icons.emoji_events_rounded;
      case EventCategory.hackathon:
        return Icons.code_rounded;
      case EventCategory.workshop:
        return Icons.handyman_rounded;
      case EventCategory.seminar:
        return Icons.mic_rounded;
      case EventCategory.competition:
        return Icons.military_tech_rounded;
      case EventCategory.other:
        return Icons.event_rounded;
    }
  }
}

/// Event model for campus events
class Event {
  final String id;
  final String title;
  final String description;
  final String? clubId;  // null for college-wide events
  final String? clubName;
  final String authorId;
  final String authorName;
  final DateTime eventDate;
  final DateTime? endDate;  // for multi-day events
  final String venue;
  final String? venueDetails;  // Room number, building, etc.
  final int? maxParticipants;
  final List<String> rsvpIds;
  final List<String> interestedIds;
  final EventCategory category;
  final String? imageUrl;
  final String? registrationLink;
  final bool requiresRegistration;
  final bool isOnline;
  final String? meetingLink;
  final bool isCancelled;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.clubId,
    this.clubName,
    required this.authorId,
    required this.authorName,
    required this.eventDate,
    this.endDate,
    required this.venue,
    this.venueDetails,
    this.maxParticipants,
    this.rsvpIds = const [],
    this.interestedIds = const [],
    required this.category,
    this.imageUrl,
    this.registrationLink,
    this.requiresRegistration = false,
    this.isOnline = false,
    this.meetingLink,
    this.isCancelled = false,
    required this.createdAt,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      clubId: data['clubId'],
      clubName: data['clubName'],
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      venue: data['venue'] ?? '',
      venueDetails: data['venueDetails'],
      maxParticipants: data['maxParticipants'],
      rsvpIds: List<String>.from(data['rsvpIds'] ?? []),
      interestedIds: List<String>.from(data['interestedIds'] ?? []),
      category: EventCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => EventCategory.other,
      ),
      imageUrl: data['imageUrl'],
      registrationLink: data['registrationLink'],
      requiresRegistration: data['requiresRegistration'] ?? false,
      isOnline: data['isOnline'] ?? false,
      meetingLink: data['meetingLink'],
      isCancelled: data['isCancelled'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'clubId': clubId,
      'clubName': clubName,
      'authorId': authorId,
      'authorName': authorName,
      'eventDate': Timestamp.fromDate(eventDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'venue': venue,
      'venueDetails': venueDetails,
      'maxParticipants': maxParticipants,
      'rsvpIds': rsvpIds,
      'interestedIds': interestedIds,
      'category': category.name,
      'imageUrl': imageUrl,
      'registrationLink': registrationLink,
      'requiresRegistration': requiresRegistration,
      'isOnline': isOnline,
      'meetingLink': meetingLink,
      'isCancelled': isCancelled,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? clubId,
    String? clubName,
    String? authorId,
    String? authorName,
    DateTime? eventDate,
    DateTime? endDate,
    String? venue,
    String? venueDetails,
    int? maxParticipants,
    List<String>? rsvpIds,
    List<String>? interestedIds,
    EventCategory? category,
    String? imageUrl,
    String? registrationLink,
    bool? requiresRegistration,
    bool? isOnline,
    String? meetingLink,
    bool? isCancelled,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      eventDate: eventDate ?? this.eventDate,
      endDate: endDate ?? this.endDate,
      venue: venue ?? this.venue,
      venueDetails: venueDetails ?? this.venueDetails,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      rsvpIds: rsvpIds ?? this.rsvpIds,
      interestedIds: interestedIds ?? this.interestedIds,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      registrationLink: registrationLink ?? this.registrationLink,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      isOnline: isOnline ?? this.isOnline,
      meetingLink: meetingLink ?? this.meetingLink,
      isCancelled: isCancelled ?? this.isCancelled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPast => eventDate.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year && 
           eventDate.month == now.month && 
           eventDate.day == now.day;
  }
  bool get isFull => maxParticipants != null && rsvpIds.length >= maxParticipants!;
  int get rsvpCount => rsvpIds.length;
  int get interestedCount => interestedIds.length;
  bool hasRSVP(String userId) => rsvpIds.contains(userId);
  bool isInterested(String userId) => interestedIds.contains(userId);

  /// Test events for development
  static List<Event> get testEvents => [
    Event(
      id: 'event_001',
      title: 'Annual Hackathon 2025',
      description: 'Join us for a 24-hour coding marathon! Build innovative solutions, win exciting prizes, and network with industry experts.',
      clubId: 'club_001',
      clubName: 'Coding Club',
      authorId: 'test_student_001',
      authorName: 'Test Student',
      eventDate: DateTime.now().add(const Duration(days: 7)),
      venue: 'Main Auditorium',
      venueDetails: 'Block A, Ground Floor',
      maxParticipants: 200,
      rsvpIds: ['user_002', 'user_003'],
      interestedIds: ['user_004', 'user_005', 'user_006'],
      category: EventCategory.hackathon,
      requiresRegistration: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Event(
      id: 'event_002',
      title: 'Cultural Night',
      description: 'An evening of music, dance, and drama. Celebrate the diversity of our college!',
      authorId: 'user_007',
      authorName: 'Cultural Committee',
      eventDate: DateTime.now().add(const Duration(days: 14)),
      venue: 'Open Air Theatre',
      category: EventCategory.cultural,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Event(
      id: 'event_003',
      title: 'Machine Learning Workshop',
      description: 'Hands-on workshop on ML basics. Bring your laptops!',
      clubId: 'club_001',
      clubName: 'Coding Club',
      authorId: 'test_student_001',
      authorName: 'Test Student',
      eventDate: DateTime.now().add(const Duration(days: 2)),
      venue: 'Computer Lab 3',
      maxParticipants: 50,
      category: EventCategory.workshop,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}

/// Announcement model for college-wide announcements
class Announcement {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final String authorRole;  // "Student Council", "Faculty", etc.
  final bool isPinned;
  final bool isUrgent;
  final DateTime createdAt;
  final DateTime? expiresAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    this.isPinned = false,
    this.isUrgent = false,
    required this.createdAt,
    this.expiresAt,
  });

  factory Announcement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Announcement(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      authorRole: data['authorRole'] ?? '',
      isPinned: data['isPinned'] ?? false,
      isUrgent: data['isUrgent'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorName': authorName,
      'authorRole': authorRole,
      'isPinned': isPinned,
      'isUrgent': isUrgent,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());

  /// Test announcements
  static List<Announcement> get testAnnouncements => [
    Announcement(
      id: 'ann_001',
      title: 'Mid-Semester Exam Schedule Released',
      content: 'The mid-semester examination schedule has been released. Please check the academic portal for detailed timetable.',
      authorId: 'faculty_001',
      authorName: 'Academic Office',
      authorRole: 'Faculty',
      isPinned: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Announcement(
      id: 'ann_002',
      title: 'Library Timings Extended',
      content: 'The central library will remain open until 10 PM during exam week for student convenience.',
      authorId: 'council_001',
      authorName: 'Student Council',
      authorRole: 'Student Council',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}

/// Event registration for attendees
class EventRegistration {
  final String userId;
  final String userName;
  final DateTime registeredAt;
  final bool isCheckedIn;
  final DateTime? checkInTime;

  EventRegistration({
    required this.userId,
    required this.userName,
    required this.registeredAt,
    this.isCheckedIn = false,
    this.checkInTime,
  });

  factory EventRegistration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventRegistration(
      userId: doc.id,
      userName: data['userName'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCheckedIn: data['isCheckedIn'] ?? false,
      checkInTime: (data['checkInTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userName': userName,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'isCheckedIn': isCheckedIn,
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
    };
  }
}
