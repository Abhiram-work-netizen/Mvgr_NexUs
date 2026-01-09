import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Meetup category for offline community events
enum MeetupCategory {
  studyCircle,
  gaming,
  anime,
  music,
  art,
  sports,
  movies,
  books,
  tech,
  other;
  
  String get displayName {
    switch (this) {
      case MeetupCategory.studyCircle:
        return 'Study Circle';
      case MeetupCategory.gaming:
        return 'Gaming';
      case MeetupCategory.anime:
        return 'Anime/Manga';
      case MeetupCategory.music:
        return 'Music';
      case MeetupCategory.art:
        return 'Art';
      case MeetupCategory.sports:
        return 'Sports';
      case MeetupCategory.movies:
        return 'Movies';
      case MeetupCategory.books:
        return 'Books';
      case MeetupCategory.tech:
        return 'Tech Talks';
      case MeetupCategory.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case MeetupCategory.studyCircle:
        return '📖';
      case MeetupCategory.gaming:
        return '🎮';
      case MeetupCategory.anime:
        return '🎌';
      case MeetupCategory.music:
        return '🎵';
      case MeetupCategory.art:
        return '🎨';
      case MeetupCategory.sports:
        return '⚽';
      case MeetupCategory.movies:
        return '🎬';
      case MeetupCategory.books:
        return '📚';
      case MeetupCategory.tech:
        return '💻';
      case MeetupCategory.other:
        return '👥';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case MeetupCategory.studyCircle:
        return Icons.auto_stories_rounded;
      case MeetupCategory.gaming:
        return Icons.sports_esports_rounded;
      case MeetupCategory.anime:
        return Icons.movie_filter_rounded;
      case MeetupCategory.music:
        return Icons.music_note_rounded;
      case MeetupCategory.art:
        return Icons.palette_rounded;
      case MeetupCategory.sports:
        return Icons.sports_soccer_rounded;
      case MeetupCategory.movies:
        return Icons.local_movies_rounded;
      case MeetupCategory.books:
        return Icons.library_books_rounded;
      case MeetupCategory.tech:
        return Icons.computer_rounded;
      case MeetupCategory.other:
        return Icons.groups_rounded;
    }
  }
}

/// Recurrence type for regular meetups
enum RecurrenceType {
  once,
  daily,
  weekly,
  biweekly,
  monthly;
  
  String get displayName {
    switch (this) {
      case RecurrenceType.once:
        return 'One-time';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.biweekly:
        return 'Bi-weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }
}

/// Offline community meetup
class Meetup {
  final String id;
  final String organizerId;
  final String organizerName;
  final String title;
  final String description;
  final MeetupCategory category;
  final String venue;
  final String? venueDetails;
  final DateTime scheduledAt;
  final Duration duration;
  final int? maxParticipants;
  final List<String> participantIds;
  final RecurrenceType recurrence;
  final bool isActive;
  final DateTime createdAt;
  final List<String> tags;

  Meetup({
    required this.id,
    required this.organizerId,
    required this.organizerName,
    required this.title,
    required this.description,
    required this.category,
    required this.venue,
    this.venueDetails,
    required this.scheduledAt,
    this.duration = const Duration(hours: 2),
    this.maxParticipants,
    this.participantIds = const [],
    this.recurrence = RecurrenceType.once,
    this.isActive = true,
    required this.createdAt,
    this.tags = const [],
  });

  factory Meetup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meetup(
      id: doc.id,
      organizerId: data['organizerId'] ?? '',
      organizerName: data['organizerName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: MeetupCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => MeetupCategory.other,
      ),
      venue: data['venue'] ?? '',
      venueDetails: data['venueDetails'],
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: Duration(minutes: data['durationMinutes'] ?? 120),
      maxParticipants: data['maxParticipants'],
      participantIds: List<String>.from(data['participantIds'] ?? []),
      recurrence: RecurrenceType.values.firstWhere(
        (r) => r.name == data['recurrence'],
        orElse: () => RecurrenceType.once,
      ),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'organizerId': organizerId,
      'organizerName': organizerName,
      'title': title,
      'description': description,
      'category': category.name,
      'venue': venue,
      'venueDetails': venueDetails,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'durationMinutes': duration.inMinutes,
      'maxParticipants': maxParticipants,
      'participantIds': participantIds,
      'recurrence': recurrence.name,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  Meetup copyWith({
    String? id,
    String? organizerId,
    String? organizerName,
    String? title,
    String? description,
    MeetupCategory? category,
    String? venue,
    String? venueDetails,
    DateTime? scheduledAt,
    Duration? duration,
    int? maxParticipants,
    List<String>? participantIds,
    RecurrenceType? recurrence,
    bool? isActive,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return Meetup(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      venue: venue ?? this.venue,
      venueDetails: venueDetails ?? this.venueDetails,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      duration: duration ?? this.duration,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantIds: participantIds ?? this.participantIds,
      recurrence: recurrence ?? this.recurrence,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  bool get isPast => scheduledAt.isBefore(DateTime.now());
  bool get isFull => maxParticipants != null && participantIds.length >= maxParticipants!;
  int get participantCount => participantIds.length + 1;  // +1 for organizer
  int? get spotsLeft => maxParticipants != null ? maxParticipants! - participantCount : null;
  bool isParticipant(String userId) => participantIds.contains(userId) || organizerId == userId;
  bool isOrganizer(String userId) => organizerId == userId;
  DateTime get endTime => scheduledAt.add(duration);

  /// Test meetups
  static List<Meetup> get testMeetups => [
    Meetup(
      id: 'meetup_001',
      organizerId: 'test_student_001',
      organizerName: 'Test Student',
      title: 'DSA Study Circle',
      description: 'Weekly study group for DSA practice. We solve LeetCode problems together and discuss approaches.',
      category: MeetupCategory.studyCircle,
      venue: 'Library Discussion Room 2',
      scheduledAt: DateTime.now().add(const Duration(days: 2, hours: 4)),
      duration: const Duration(hours: 2),
      maxParticipants: 8,
      participantIds: ['user_002', 'user_003'],
      recurrence: RecurrenceType.weekly,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['dsa', 'leetcode', 'coding'],
    ),
    Meetup(
      id: 'meetup_002',
      organizerId: 'user_004',
      organizerName: 'Anime Club',
      title: 'Anime Watch Party - Attack on Titan',
      description: 'Watching the final season together! Snacks will be arranged.',
      category: MeetupCategory.anime,
      venue: 'Seminar Hall 3',
      scheduledAt: DateTime.now().add(const Duration(days: 5, hours: 6)),
      duration: const Duration(hours: 3),
      maxParticipants: 30,
      participantIds: ['user_005', 'user_006', 'user_007', 'user_008'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['anime', 'aot', 'watchparty'],
    ),
    Meetup(
      id: 'meetup_003',
      organizerId: 'user_009',
      organizerName: 'Music Enthusiast',
      title: 'Open Jam Session',
      description: 'Bring your instruments or just vibes. All skill levels welcome!',
      category: MeetupCategory.music,
      venue: 'Music Room',
      scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 5)),
      duration: const Duration(hours: 2, minutes: 30),
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      tags: ['music', 'jam', 'guitar', 'singing'],
    ),
  ];
}
