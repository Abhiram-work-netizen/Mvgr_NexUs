import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Mentor type
enum MentorType {
  faculty,
  senior,
  alumni;
  
  String get displayName {
    switch (this) {
      case MentorType.faculty:
        return 'Faculty';
      case MentorType.senior:
        return 'Senior Student';
      case MentorType.alumni:
        return 'Alumni';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case MentorType.faculty:
        return Icons.school_rounded;
      case MentorType.senior:
        return Icons.person_rounded;
      case MentorType.alumni:
        return Icons.workspace_premium_rounded;
    }
  }
}

/// Mentorship area
enum MentorshipArea {
  academic,
  career,
  research,
  skills,
  placement,
  other;
  
  String get displayName {
    switch (this) {
      case MentorshipArea.academic:
        return 'Academic Guidance';
      case MentorshipArea.career:
        return 'Career Advice';
      case MentorshipArea.research:
        return 'Research';
      case MentorshipArea.skills:
        return 'Skill Development';
      case MentorshipArea.placement:
        return 'Placement Prep';
      case MentorshipArea.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case MentorshipArea.academic:
        return '📚';
      case MentorshipArea.career:
        return '💼';
      case MentorshipArea.research:
        return '🔬';
      case MentorshipArea.skills:
        return '🛠️';
      case MentorshipArea.placement:
        return '🎯';
      case MentorshipArea.other:
        return '💡';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case MentorshipArea.academic:
        return Icons.menu_book_rounded;
      case MentorshipArea.career:
        return Icons.work_rounded;
      case MentorshipArea.research:
        return Icons.science_rounded;
      case MentorshipArea.skills:
        return Icons.build_rounded;
      case MentorshipArea.placement:
        return Icons.trending_up_rounded;
      case MentorshipArea.other:
        return Icons.lightbulb_rounded;
    }
  }
}

/// Mentor profile for mentorship system
class Mentor {
  final String id;
  final String userId;
  final String name;
  final MentorType type;
  final String? department;
  final String? designation;  // For faculty
  final int? graduationYear;  // For alumni
  final List<MentorshipArea> areas;
  final String bio;
  final List<String> expertise;
  final String? linkedinUrl;
  final int maxMentees;
  final int currentMentees;
  final bool isAvailable;
  final DateTime createdAt;

  Mentor({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.department,
    this.designation,
    this.graduationYear,
    required this.areas,
    required this.bio,
    this.expertise = const [],
    this.linkedinUrl,
    this.maxMentees = 5,
    this.currentMentees = 0,
    this.isAvailable = true,
    required this.createdAt,
  });

  factory Mentor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mentor(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      type: MentorType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => MentorType.senior,
      ),
      department: data['department'],
      designation: data['designation'],
      graduationYear: data['graduationYear'],
      areas: (data['areas'] as List? ?? [])
          .map((a) => MentorshipArea.values.firstWhere(
                (area) => area.name == a,
                orElse: () => MentorshipArea.other,
              ))
          .toList(),
      bio: data['bio'] ?? '',
      expertise: List<String>.from(data['expertise'] ?? []),
      linkedinUrl: data['linkedinUrl'],
      maxMentees: data['maxMentees'] ?? 5,
      currentMentees: data['currentMentees'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'type': type.name,
      'department': department,
      'designation': designation,
      'graduationYear': graduationYear,
      'areas': areas.map((a) => a.name).toList(),
      'bio': bio,
      'expertise': expertise,
      'linkedinUrl': linkedinUrl,
      'maxMentees': maxMentees,
      'currentMentees': currentMentees,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get hasCapacity => currentMentees < maxMentees;
  int get availableSlots => maxMentees - currentMentees;

  /// Test mentors
  static List<Mentor> get testMentors => [
    Mentor(
      id: 'mentor_001',
      userId: 'faculty_001',
      name: 'Dr. Ramesh Kumar',
      type: MentorType.faculty,
      department: 'Computer Science',
      designation: 'Associate Professor',
      areas: [MentorshipArea.research, MentorshipArea.academic],
      bio: 'Passionate about AI/ML research. Published 20+ papers. Happy to guide students in research methodology.',
      expertise: ['Machine Learning', 'Deep Learning', 'Computer Vision'],
      maxMentees: 5,
      currentMentees: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    Mentor(
      id: 'mentor_002',
      userId: 'senior_001',
      name: 'Priya Sharma',
      type: MentorType.senior,
      department: 'Computer Science',
      areas: [MentorshipArea.placement, MentorshipArea.skills],
      bio: '4th year CSE, placed at Google. Can help with DSA prep and interview preparation.',
      expertise: ['DSA', 'System Design', 'Interview Prep'],
      maxMentees: 3,
      currentMentees: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
}

/// Mentorship request
class MentorshipRequest {
  final String id;
  final String mentorId;
  final String menteeId;
  final String menteeName;
  final MentorshipArea area;
  final String message;  // Why they want mentorship
  final String goal;  // What they want to achieve
  final String status;  // pending, accepted, rejected, completed
  final DateTime createdAt;
  final DateTime? acceptedAt;

  MentorshipRequest({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    required this.menteeName,
    required this.area,
    required this.message,
    required this.goal,
    this.status = 'pending',
    required this.createdAt,
    this.acceptedAt,
  });

  factory MentorshipRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MentorshipRequest(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      menteeId: data['menteeId'] ?? '',
      menteeName: data['menteeName'] ?? '',
      area: MentorshipArea.values.firstWhere(
        (a) => a.name == data['area'],
        orElse: () => MentorshipArea.other,
      ),
      message: data['message'] ?? '',
      goal: data['goal'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mentorId': mentorId,
      'menteeId': menteeId,
      'menteeName': menteeName,
      'area': area.name,
      'message': message,
      'goal': goal,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
}

/// Mentorship session tracking
class MentorshipSession {
  final String id;
  final String mentorId;
  final String menteeId;
  final DateTime scheduledAt;
  final String? topic;
  final String? notes;
  final bool completed;
  final DateTime createdAt;

  MentorshipSession({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    required this.scheduledAt,
    this.topic,
    this.notes,
    this.completed = false,
    required this.createdAt,
  });

  factory MentorshipSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MentorshipSession(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      menteeId: data['menteeId'] ?? '',
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      topic: data['topic'],
      notes: data['notes'],
      completed: data['completed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mentorId': mentorId,
      'menteeId': menteeId,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'topic': topic,
      'notes': notes,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
