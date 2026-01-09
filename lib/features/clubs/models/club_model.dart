import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Category for clubs
enum ClubCategory {
  technical,
  cultural,
  sports,
  social,
  academic,
  other;
  
  String get displayName {
    switch (this) {
      case ClubCategory.technical:
        return 'Technical';
      case ClubCategory.cultural:
        return 'Cultural';
      case ClubCategory.sports:
        return 'Sports';
      case ClubCategory.social:
        return 'Social';
      case ClubCategory.academic:
        return 'Academic';
      case ClubCategory.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case ClubCategory.technical:
        return '💻';
      case ClubCategory.cultural:
        return '🎭';
      case ClubCategory.sports:
        return '🏃';
      case ClubCategory.social:
        return '🤝';
      case ClubCategory.academic:
        return '📚';
      case ClubCategory.other:
        return '⭐';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case ClubCategory.technical:
        return Icons.code_rounded;
      case ClubCategory.cultural:
        return Icons.palette_rounded;
      case ClubCategory.sports:
        return Icons.sports_soccer_rounded;
      case ClubCategory.social:
        return Icons.people_rounded;
      case ClubCategory.academic:
        return Icons.school_rounded;
      case ClubCategory.other:
        return Icons.stars_rounded;
    }
  }
}

/// Club/Committee/Council model
class Club {
  final String id;
  final String name;
  final String description;
  final ClubCategory category;
  final List<String> adminIds;
  final List<String> memberIds;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? contactEmail;
  final String? instagramHandle;
  final bool isApproved;
  final bool isOfficial;  // For councils and committees
  final DateTime createdAt;
  final String createdBy;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.adminIds,
    this.memberIds = const [],
    this.logoUrl,
    this.coverImageUrl,
    this.contactEmail,
    this.instagramHandle,
    this.isApproved = false,
    this.isOfficial = false,
    required this.createdAt,
    required this.createdBy,
  });

  factory Club.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Club(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: ClubCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => ClubCategory.other,
      ),
      adminIds: List<String>.from(data['adminIds'] ?? []),
      memberIds: List<String>.from(data['memberIds'] ?? []),
      logoUrl: data['logoUrl'],
      coverImageUrl: data['coverImageUrl'],
      contactEmail: data['contactEmail'],
      instagramHandle: data['instagramHandle'],
      isApproved: data['isApproved'] ?? false,
      isOfficial: data['isOfficial'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category.name,
      'adminIds': adminIds,
      'memberIds': memberIds,
      'logoUrl': logoUrl,
      'coverImageUrl': coverImageUrl,
      'contactEmail': contactEmail,
      'instagramHandle': instagramHandle,
      'isApproved': isApproved,
      'isOfficial': isOfficial,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  Club copyWith({
    String? id,
    String? name,
    String? description,
    ClubCategory? category,
    List<String>? adminIds,
    List<String>? memberIds,
    String? logoUrl,
    String? coverImageUrl,
    String? contactEmail,
    String? instagramHandle,
    bool? isApproved,
    bool? isOfficial,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      adminIds: adminIds ?? this.adminIds,
      memberIds: memberIds ?? this.memberIds,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      isApproved: isApproved ?? this.isApproved,
      isOfficial: isOfficial ?? this.isOfficial,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  int get totalMembers => memberIds.length + adminIds.length;
  
  bool isAdmin(String userId) => adminIds.contains(userId);
  bool isMember(String userId) => memberIds.contains(userId) || adminIds.contains(userId);

  /// Test clubs for development
  static List<Club> get testClubs => [
    Club(
      id: 'club_001',
      name: 'Coding Club',
      description: 'A community of passionate programmers exploring cutting-edge technologies and building amazing projects together.',
      category: ClubCategory.technical,
      adminIds: ['test_student_001'],
      memberIds: ['user_002', 'user_003', 'user_004'],
      isApproved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      createdBy: 'test_student_001',
    ),
    Club(
      id: 'club_002',
      name: 'Music Society',
      description: 'Where melodies come alive! Join us for jamming sessions, performances, and music workshops.',
      category: ClubCategory.cultural,
      adminIds: ['user_005'],
      memberIds: ['user_006', 'user_007'],
      isApproved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
      createdBy: 'user_005',
    ),
    Club(
      id: 'club_003',
      name: 'Robotics Team',
      description: 'Building the future, one robot at a time. Competitions, workshops, and hands-on projects.',
      category: ClubCategory.technical,
      adminIds: ['user_008'],
      memberIds: ['user_009', 'user_010'],
      isApproved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      createdBy: 'user_008',
    ),
  ];
}

/// Club post types
enum ClubPostType {
  announcement,
  event,
  recruitment,
  general;
  
  String get displayName {
    switch (this) {
      case ClubPostType.announcement:
        return 'Announcement';
      case ClubPostType.event:
        return 'Event';
      case ClubPostType.recruitment:
        return 'Recruitment';
      case ClubPostType.general:
        return 'General';
    }
  }
}

/// Post within a club
class ClubPost {
  final String id;
  final String clubId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final ClubPostType type;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isPinned;

  ClubPost({
    required this.id,
    required this.clubId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    this.isPinned = false,
  });

  factory ClubPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubPost(
      id: doc.id,
      clubId: data['clubId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      type: ClubPostType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ClubPostType.general,
      ),
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPinned: data['isPinned'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clubId': clubId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'type': type.name,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPinned': isPinned,
    };
  }

  ClubPost copyWith({
    String? id,
    String? clubId,
    String? authorId,
    String? authorName,
    String? title,
    String? content,
    ClubPostType? type,
    String? imageUrl,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return ClubPost(
      id: id ?? this.id,
      clubId: clubId ?? this.clubId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

/// Request to join a club
class ClubJoinRequest {
  final String id;
  final String clubId;
  final String userId;
  final String userName;
  final DateTime requestedAt;
  final String status; // 'pending', 'approved', 'rejected'

  ClubJoinRequest({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.userName,
    required this.requestedAt,
    this.status = 'pending',
  });

  factory ClubJoinRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubJoinRequest(
      id: doc.id,
      clubId: data['clubId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clubId': clubId,
      'userId': userId,
      'userName': userName,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'status': status,
    };
  }
}
