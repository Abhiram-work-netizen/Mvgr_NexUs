import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Category for team/play buddy requests
enum TeamCategory {
  hackathon,
  sports,
  esports,
  cultural,
  academic,
  project,
  other;
  
  String get displayName {
    switch (this) {
      case TeamCategory.hackathon:
        return 'Hackathon';
      case TeamCategory.sports:
        return 'Sports';
      case TeamCategory.esports:
        return 'E-Sports/Gaming';
      case TeamCategory.cultural:
        return 'Cultural';
      case TeamCategory.academic:
        return 'Academic Competition';
      case TeamCategory.project:
        return 'Project Team';
      case TeamCategory.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case TeamCategory.hackathon:
        return '💻';
      case TeamCategory.sports:
        return '⚽';
      case TeamCategory.esports:
        return '🎮';
      case TeamCategory.cultural:
        return '🎭';
      case TeamCategory.academic:
        return '🏆';
      case TeamCategory.project:
        return '📊';
      case TeamCategory.other:
        return '👥';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case TeamCategory.hackathon:
        return Icons.code_rounded;
      case TeamCategory.sports:
        return Icons.sports_soccer_rounded;
      case TeamCategory.esports:
        return Icons.sports_esports_rounded;
      case TeamCategory.cultural:
        return Icons.theater_comedy_rounded;
      case TeamCategory.academic:
        return Icons.emoji_events_rounded;
      case TeamCategory.project:
        return Icons.group_work_rounded;
      case TeamCategory.other:
        return Icons.groups_rounded;
    }
  }
}

/// Team/Play buddy request
class TeamRequest {
  final String id;
  final String creatorId;
  final String creatorName;
  final String title;
  final String description;
  final TeamCategory category;
  final String? eventName;  // Hackathon name, tournament, etc.
  final String? eventUrl;  // Link to event page
  final DateTime? eventDate;
  final int teamSize;
  final int currentMembers;
  final List<String> memberIds;
  final List<String> memberNames;
  final List<String> requiredSkills;
  final DateTime deadline;
  final String status;  // open, full, closed
  final DateTime createdAt;

  TeamRequest({
    required this.id,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    required this.description,
    required this.category,
    this.eventName,
    this.eventUrl,
    this.eventDate,
    required this.teamSize,
    this.currentMembers = 1,
    this.memberIds = const [],
    this.memberNames = const [],
    this.requiredSkills = const [],
    required this.deadline,
    this.status = 'open',
    required this.createdAt,
  });

  factory TeamRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final memberIds = List<String>.from(data['memberIds'] ?? []);
    return TeamRequest(
      id: doc.id,
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: TeamCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => TeamCategory.other,
      ),
      eventName: data['eventName'],
      eventUrl: data['eventUrl'],
      eventDate: (data['eventDate'] as Timestamp?)?.toDate(),
      teamSize: data['teamSize'] ?? 4,
      currentMembers: memberIds.length + 1,  // +1 for creator
      memberIds: memberIds,
      memberNames: List<String>.from(data['memberNames'] ?? []),
      requiredSkills: List<String>.from(data['requiredSkills'] ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'title': title,
      'description': description,
      'category': category.name,
      'eventName': eventName,
      'eventUrl': eventUrl,
      'eventDate': eventDate != null ? Timestamp.fromDate(eventDate!) : null,
      'teamSize': teamSize,
      'memberIds': memberIds,
      'memberNames': memberNames,
      'requiredSkills': requiredSkills,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TeamRequest copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? title,
    String? description,
    TeamCategory? category,
    String? eventName,
    String? eventUrl,
    DateTime? eventDate,
    int? teamSize,
    int? currentMembers,
    List<String>? memberIds,
    List<String>? memberNames,
    List<String>? requiredSkills,
    DateTime? deadline,
    String? status,
    DateTime? createdAt,
  }) {
    return TeamRequest(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      eventName: eventName ?? this.eventName,
      eventUrl: eventUrl ?? this.eventUrl,
      eventDate: eventDate ?? this.eventDate,
      teamSize: teamSize ?? this.teamSize,
      currentMembers: currentMembers ?? this.currentMembers,
      memberIds: memberIds ?? this.memberIds,
      memberNames: memberNames ?? this.memberNames,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isOpen => status == 'open' && !isFull && !isPastDeadline;
  bool get isFull => currentMembers >= teamSize;
  bool get isPastDeadline => DateTime.now().isAfter(deadline);
  int get spotsLeft => teamSize - currentMembers;
  bool isMember(String userId) => memberIds.contains(userId) || creatorId == userId;
  bool isCreator(String userId) => creatorId == userId;

  /// Test team requests
  static List<TeamRequest> get testRequests => [
    TeamRequest(
      id: 'tr_001',
      creatorId: 'test_student_001',
      creatorName: 'Test Student',
      title: 'Looking for hackers - Smart India Hackathon',
      description: 'Building a smart agriculture solution. Need 2 ML engineers and 1 frontend dev.',
      category: TeamCategory.hackathon,
      eventName: 'Smart India Hackathon 2025',
      eventUrl: 'https://sih.gov.in',
      eventDate: DateTime.now().add(const Duration(days: 30)),
      teamSize: 6,
      currentMembers: 3,
      memberIds: ['user_002', 'user_003'],
      memberNames: ['Alice', 'Bob'],
      requiredSkills: ['Python', 'TensorFlow', 'React'],
      deadline: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TeamRequest(
      id: 'tr_002',
      creatorId: 'user_004',
      creatorName: 'John Doe',
      title: 'Football team for inter-college tournament',
      description: 'Forming a team for the upcoming inter-college football championship. Need 4 more players.',
      category: TeamCategory.sports,
      eventName: 'Inter-College Football 2025',
      eventDate: DateTime.now().add(const Duration(days: 45)),
      teamSize: 11,
      currentMembers: 7,
      memberIds: ['user_005', 'user_006', 'user_007', 'user_008', 'user_009', 'user_010'],
      memberNames: ['Player 1', 'Player 2', 'Player 3', 'Player 4', 'Player 5', 'Player 6'],
      deadline: DateTime.now().add(const Duration(days: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TeamRequest(
      id: 'tr_003',
      creatorId: 'user_011',
      creatorName: 'Gaming Pro',
      title: 'Valorant Squad for Campus Tournament',
      description: 'Need 2 skilled players for the campus esports tournament. Prefer Diamond+ rank.',
      category: TeamCategory.esports,
      eventName: 'Campus Esports League',
      teamSize: 5,
      currentMembers: 3,
      requiredSkills: ['Diamond+', 'Team Player', 'Mic Required'],
      deadline: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
  ];
}

/// Join request for a team
class JoinRequest {
  final String id;
  final String teamRequestId;
  final String userId;
  final String userName;
  final String message;  // Why they want to join
  final List<String> relevantSkills;
  final String status;  // pending, accepted, rejected
  final DateTime createdAt;

  JoinRequest({
    required this.id,
    required this.teamRequestId,
    required this.userId,
    required this.userName,
    required this.message,
    this.relevantSkills = const [],
    this.status = 'pending',
    required this.createdAt,
  });

  factory JoinRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JoinRequest(
      id: doc.id,
      teamRequestId: data['teamRequestId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      message: data['message'] ?? '',
      relevantSkills: List<String>.from(data['relevantSkills'] ?? []),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamRequestId': teamRequestId,
      'userId': userId,
      'userName': userName,
      'message': message,
      'relevantSkills': relevantSkills,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
