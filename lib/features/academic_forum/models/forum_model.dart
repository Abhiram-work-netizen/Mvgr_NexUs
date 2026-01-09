import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

/// Discussion Forum Categories (not just academic!)
enum ForumCategory {
  academic,
  career,
  campusLife,
  tech,
  fun,
  other;

  String get displayName {
    switch (this) {
      case ForumCategory.academic:
        return 'Academic';
      case ForumCategory.career:
        return 'Career & Placements';
      case ForumCategory.campusLife:
        return 'Campus Life';
      case ForumCategory.tech:
        return 'Tech & Projects';
      case ForumCategory.fun:
        return 'Fun & Interests';
      case ForumCategory.other:
        return 'Other';
    }
  }

  IconData get iconData {
    switch (this) {
      case ForumCategory.academic:
        return Icons.school_rounded;
      case ForumCategory.career:
        return Icons.work_rounded;
      case ForumCategory.campusLife:
        return Icons.apartment_rounded;
      case ForumCategory.tech:
        return Icons.code_rounded;
      case ForumCategory.fun:
        return Icons.celebration_rounded;
      case ForumCategory.other:
        return Icons.chat_bubble_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ForumCategory.academic:
        return const Color(0xFF4F46E5);
      case ForumCategory.career:
        return const Color(0xFF059669);
      case ForumCategory.campusLife:
        return const Color(0xFFD97706);
      case ForumCategory.tech:
        return const Color(0xFF7C3AED);
      case ForumCategory.fun:
        return const Color(0xFFEC4899);
      case ForumCategory.other:
        return const Color(0xFF6B7280);
    }
  }
}

/// Discussion question for the forum (renamed from AcademicQuestion)
class AcademicQuestion {
  final String id;
  final String? authorId;  // null if anonymous
  final String? authorName;
  final bool isAnonymous;
  final ForumCategory category;  // NEW: Discussion category
  final String title;
  final String content;
  final String subject;  // Keep for academic questions
  final String topic;
  final List<String> tags;
  final bool isResolved;
  final String? acceptedAnswerId;
  final int viewCount;
  final int answerCount;
  final int upvoteCount;
  final List<String> upvotedBy;
  final DateTime createdAt;
  final ModerationStatus status;

  AcademicQuestion({
    required this.id,
    this.authorId,
    this.authorName,
    required this.isAnonymous,
    this.category = ForumCategory.academic,  // Default to academic
    required this.title,
    required this.content,
    this.subject = '',
    this.topic = '',
    this.tags = const [],
    this.isResolved = false,
    this.acceptedAnswerId,
    this.viewCount = 0,
    this.answerCount = 0,
    this.upvoteCount = 0,
    this.upvotedBy = const [],
    required this.createdAt,
    this.status = ModerationStatus.approved,
  });

  factory AcademicQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AcademicQuestion(
      id: doc.id,
      authorId: data['authorId'],
      authorName: data['isAnonymous'] == true ? 'Anonymous' : data['authorName'],
      isAnonymous: data['isAnonymous'] ?? false,
      category: ForumCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => ForumCategory.academic,
      ),
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      subject: data['subject'] ?? '',
      topic: data['topic'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isResolved: data['isResolved'] ?? false,
      acceptedAnswerId: data['acceptedAnswerId'],
      viewCount: data['viewCount'] ?? 0,
      answerCount: data['answerCount'] ?? 0,
      upvoteCount: data['upvoteCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: ModerationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ModerationStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'isAnonymous': isAnonymous,
      'category': category.name,
      'title': title,
      'content': content,
      'subject': subject,
      'topic': topic,
      'tags': tags,
      'isResolved': isResolved,
      'acceptedAnswerId': acceptedAnswerId,
      'viewCount': viewCount,
      'answerCount': answerCount,
      'upvoteCount': upvoteCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
    };
  }

  AcademicQuestion copyWith({
    String? id,
    String? authorId,
    String? authorName,
    bool? isAnonymous,
    ForumCategory? category,
    String? title,
    String? content,
    String? subject,
    String? topic,
    List<String>? tags,
    bool? isResolved,
    String? acceptedAnswerId,
    int? viewCount,
    int? answerCount,
    int? upvoteCount,
    List<String>? upvotedBy,
    DateTime? createdAt,
    ModerationStatus? status,
  }) {
    return AcademicQuestion(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      topic: topic ?? this.topic,
      tags: tags ?? this.tags,
      isResolved: isResolved ?? this.isResolved,
      acceptedAnswerId: acceptedAnswerId ?? this.acceptedAnswerId,
      viewCount: viewCount ?? this.viewCount,
      answerCount: answerCount ?? this.answerCount,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  String get displayAuthor => isAnonymous ? 'Anonymous' : (authorName ?? 'Unknown');

  /// Test questions with different categories
  static List<AcademicQuestion> get testQuestions => [
    AcademicQuestion(
      id: 'q_001',
      authorId: 'test_student_001',
      authorName: 'Test Student',
      isAnonymous: false,
      category: ForumCategory.academic,
      title: 'How to solve differential equations using Laplace transform?',
      content: 'I\'m stuck on this problem where we need to apply Laplace transform to solve a second-order differential equation. Can someone explain the steps?',
      subject: 'Mathematics',
      topic: 'Differential Equations',
      tags: ['laplace', 'calculus', 'ode'],
      viewCount: 45,
      answerCount: 3,
      upvoteCount: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    AcademicQuestion(
      id: 'q_002',
      isAnonymous: true,
      category: ForumCategory.tech,
      title: 'Struggling with Data Structures - Need help with Trees',
      content: 'Can someone explain the difference between AVL trees and Red-Black trees? When should I use which?',
      subject: 'Computer Science',
      topic: 'Data Structures',
      tags: ['trees', 'algorithms', 'dsa'],
      viewCount: 78,
      answerCount: 5,
      upvoteCount: 25,
      isResolved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AcademicQuestion(
      id: 'q_003',
      authorId: 'test_student_002',
      authorName: 'Campus Explorer',
      isAnonymous: false,
      category: ForumCategory.campusLife,
      title: 'Best places to study on campus?',
      content: 'Looking for quiet spots to study. Library gets crowded sometimes. Any recommendations?',
      tags: ['campus', 'study', 'library'],
      viewCount: 156,
      answerCount: 12,
      upvoteCount: 45,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AcademicQuestion(
      id: 'q_004',
      isAnonymous: true,
      category: ForumCategory.career,
      title: 'Tips for placement preparation?',
      content: 'Placements are coming up next semester. What resources should I focus on? How to prepare for coding rounds?',
      tags: ['placements', 'career', 'coding'],
      viewCount: 234,
      answerCount: 18,
      upvoteCount: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AcademicQuestion(
      id: 'q_005',
      authorId: 'test_student_003',
      authorName: 'Gaming Enthusiast',
      isAnonymous: false,
      category: ForumCategory.fun,
      title: 'Anyone interested in forming a gaming squad?',
      content: 'Looking for teammates for Valorant. Need players who can play evening 8-10 PM. Rank: Gold+',
      tags: ['gaming', 'valorant', 'esports'],
      viewCount: 89,
      answerCount: 8,
      upvoteCount: 23,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];
}

/// Answer to an academic question
class Answer {
  final String id;
  final String questionId;
  final String authorId;
  final String authorName;
  final String content;
  final bool isAccepted;
  final int helpfulCount;
  final List<String> helpfulByIds;
  final DateTime createdAt;
  final DateTime? editedAt;

  Answer({
    required this.id,
    required this.questionId,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.isAccepted = false,
    this.helpfulCount = 0,
    this.helpfulByIds = const [],
    required this.createdAt,
    this.editedAt,
  });

  factory Answer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Answer(
      id: doc.id,
      questionId: data['questionId'] ?? '',
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? '',
      content: data['content'] ?? '',
      isAccepted: data['isAccepted'] ?? false,
      helpfulCount: data['helpfulCount'] ?? 0,
      helpfulByIds: List<String>.from(data['helpfulByIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionId': questionId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'isAccepted': isAccepted,
      'helpfulCount': helpfulCount,
      'helpfulByIds': helpfulByIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    };
  }

  bool isHelpfulBy(String userId) => helpfulByIds.contains(userId);
}

/// Subject categories for questions
class QuestionSubjects {
  static const List<String> all = [
    'General',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Computer Science',
    'Data Structures',
    'DBMS',
    'Networks',
    'Operating Systems',
    'Web Development',
    'Machine Learning',
    'Electronics',
    'Mechanical',
    'Civil',
    'Other',
  ];
}
