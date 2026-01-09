import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Preferred study mode
enum StudyMode {
  online,
  inPerson,
  hybrid;
  
  String get displayName {
    switch (this) {
      case StudyMode.online:
        return 'Online';
      case StudyMode.inPerson:
        return 'In-Person';
      case StudyMode.hybrid:
        return 'Hybrid';
    }
  }
  
  String get icon {
    switch (this) {
      case StudyMode.online:
        return '💻';
      case StudyMode.inPerson:
        return '🏫';
      case StudyMode.hybrid:
        return '🔄';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case StudyMode.online:
        return Icons.laptop_mac_rounded;
      case StudyMode.inPerson:
        return Icons.school_rounded;
      case StudyMode.hybrid:
        return Icons.sync_alt_rounded;
    }
  }
}

/// Status of a request
enum RequestStatus {
  active,
  matched,
  expired,
  cancelled;
  
  String get displayName {
    switch (this) {
      case RequestStatus.active:
        return 'Active';
      case RequestStatus.matched:
        return 'Matched';
      case RequestStatus.expired:
        return 'Expired';
      case RequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Study buddy request - topic-first, no profile browsing
class StudyRequest {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final String topic;
  final String description;
  final StudyMode preferredMode;
  final String? preferredLocation;
  final List<String> availableDays;  // "Monday", "Tuesday", etc.
  final String? preferredTime;  // "Morning", "Afternoon", "Evening"
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;

  StudyRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.topic,
    required this.description,
    required this.preferredMode,
    this.preferredLocation,
    this.availableDays = const [],
    this.preferredTime,
    this.status = RequestStatus.active,
    required this.createdAt,
    required this.expiresAt,
  });

  factory StudyRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      subject: data['subject'] ?? '',
      topic: data['topic'] ?? '',
      description: data['description'] ?? '',
      preferredMode: StudyMode.values.firstWhere(
        (m) => m.name == data['preferredMode'],
        orElse: () => StudyMode.hybrid,
      ),
      preferredLocation: data['preferredLocation'],
      availableDays: List<String>.from(data['availableDays'] ?? []),
      preferredTime: data['preferredTime'],
      status: RequestStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => RequestStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? 
          DateTime.now().add(const Duration(days: 14)),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'subject': subject,
      'topic': topic,
      'description': description,
      'preferredMode': preferredMode.name,
      'preferredLocation': preferredLocation,
      'availableDays': availableDays,
      'preferredTime': preferredTime,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  StudyRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? subject,
    String? topic,
    String? description,
    StudyMode? preferredMode,
    String? preferredLocation,
    List<String>? availableDays,
    String? preferredTime,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StudyRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      preferredMode: preferredMode ?? this.preferredMode,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      availableDays: availableDays ?? this.availableDays,
      preferredTime: preferredTime ?? this.preferredTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isActive => status == RequestStatus.active && !isExpired;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool isOwnedBy(String uid) => userId == uid;

  /// Test requests
  static List<StudyRequest> get testRequests => [
    StudyRequest(
      id: 'sr_001',
      userId: 'test_student_001',
      userName: 'Test Student',
      subject: 'Data Structures',
      topic: 'Binary Trees and BST',
      description: 'Looking for a study partner to practice tree problems together. Planning for coding interviews.',
      preferredMode: StudyMode.inPerson,
      preferredLocation: 'Library Study Room',
      availableDays: ['Monday', 'Wednesday', 'Friday'],
      preferredTime: 'Evening',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      expiresAt: DateTime.now().add(const Duration(days: 13)),
    ),
    StudyRequest(
      id: 'sr_002',
      userId: 'user_002',
      userName: 'Jane Doe',
      subject: 'Machine Learning',
      topic: 'Neural Networks',
      description: 'Need help understanding backpropagation and gradient descent. Happy to help with math in return!',
      preferredMode: StudyMode.online,
      availableDays: ['Saturday', 'Sunday'],
      preferredTime: 'Morning',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      expiresAt: DateTime.now().add(const Duration(days: 14)),
    ),
  ];
}

/// Match status for study buddy
enum MatchStatus {
  pending,
  accepted,
  declined;
  
  String get displayName {
    switch (this) {
      case MatchStatus.pending:
        return 'Pending';
      case MatchStatus.accepted:
        return 'Accepted';
      case MatchStatus.declined:
        return 'Declined';
    }
  }
}

/// Study match - mutual consent required before contact reveal
class StudyMatch {
  final String id;
  final String requestId;
  final String requesterId;  // Original request creator
  final String requesterName;
  final String matchedUserId;  // User who wants to match
  final String matchedUserName;
  final MatchStatus requesterStatus;  // Auto-accepted since they created request
  final MatchStatus matchedUserStatus;
  final String message;  // Why they want to study together
  final bool contactRevealed;  // Only after mutual accept
  final String? requesterContact;
  final String? matchedUserContact;
  final DateTime createdAt;

  StudyMatch({
    required this.id,
    required this.requestId,
    required this.requesterId,
    required this.requesterName,
    required this.matchedUserId,
    required this.matchedUserName,
    this.requesterStatus = MatchStatus.pending,
    this.matchedUserStatus = MatchStatus.pending,
    this.message = '',
    this.contactRevealed = false,
    this.requesterContact,
    this.matchedUserContact,
    required this.createdAt,
  });

  factory StudyMatch.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyMatch(
      id: doc.id,
      requestId: data['requestId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      matchedUserId: data['matchedUserId'] ?? '',
      matchedUserName: data['matchedUserName'] ?? '',
      requesterStatus: MatchStatus.values.firstWhere(
        (s) => s.name == data['requesterStatus'],
        orElse: () => MatchStatus.pending,
      ),
      matchedUserStatus: MatchStatus.values.firstWhere(
        (s) => s.name == data['matchedUserStatus'],
        orElse: () => MatchStatus.pending,
      ),
      message: data['message'] ?? '',
      contactRevealed: data['contactRevealed'] ?? false,
      requesterContact: data['requesterContact'],
      matchedUserContact: data['matchedUserContact'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requestId': requestId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'matchedUserId': matchedUserId,
      'matchedUserName': matchedUserName,
      'requesterStatus': requesterStatus.name,
      'matchedUserStatus': matchedUserStatus.name,
      'message': message,
      'contactRevealed': contactRevealed,
      'requesterContact': requesterContact,
      'matchedUserContact': matchedUserContact,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Check if both parties have accepted
  bool get isMutuallyAccepted => 
      requesterStatus == MatchStatus.accepted && 
      matchedUserStatus == MatchStatus.accepted;

  /// Check if user is part of this match
  bool isParticipant(String userId) => 
      requesterId == userId || matchedUserId == userId;
}
