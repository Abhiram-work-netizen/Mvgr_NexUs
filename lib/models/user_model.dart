import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

/// User model representing a student, club admin, council member, or faculty
class AppUser {
  final String uid;
  final String email;
  final String name;
  final String rollNumber;
  final String department;
  final int year;
  final UserRole role;
  final List<String> clubIds;
  final List<String> interests;
  final List<String> skills;
  final String? profilePhotoUrl;
  final String? profileColor;
  final String? bio;
  final String? phoneNumber;
  final List<String> managedClubIds;  // For community admins
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.rollNumber,
    required this.department,
    required this.year,
    this.role = UserRole.student,
    this.clubIds = const [],
    this.interests = const [],
    this.skills = const [],
    this.profilePhotoUrl,
    this.profileColor,
    this.bio,
    this.phoneNumber,
    this.managedClubIds = const [],
    this.isVerified = false,
    required this.createdAt,
    this.lastActiveAt,
  });

  /// Create from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      rollNumber: data['rollNumber'] ?? '',
      department: data['department'] ?? '',
      year: data['year'] ?? 1,
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.student,
      ),
      clubIds: List<String>.from(data['clubIds'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      profilePhotoUrl: data['profilePhotoUrl'],
      profileColor: data['profileColor'],
      bio: data['bio'],
      phoneNumber: data['phoneNumber'],
      managedClubIds: List<String>.from(data['managedClubIds'] ?? []),
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveAt: (data['lastActiveAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'rollNumber': rollNumber,
      'department': department,
      'year': year,
      'role': role.name,
      'clubIds': clubIds,
      'interests': interests,
      'skills': skills,
      'profilePhotoUrl': profilePhotoUrl,
      'profileColor': profileColor,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'managedClubIds': managedClubIds,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': lastActiveAt != null ? Timestamp.fromDate(lastActiveAt!) : null,
    };
  }

  /// Create a copy with modified fields
  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? rollNumber,
    String? department,
    int? year,
    UserRole? role,
    List<String>? clubIds,
    List<String>? interests,
    List<String>? skills,
    String? profilePhotoUrl,
    String? profileColor,
    String? bio,
    String? phoneNumber,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      rollNumber: rollNumber ?? this.rollNumber,
      department: department ?? this.department,
      year: year ?? this.year,
      role: role ?? this.role,
      clubIds: clubIds ?? this.clubIds,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profileColor: profileColor ?? this.profileColor,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// Get display name with role indicator
  String get displayNameWithRole => '$name (${role.displayName})';

  /// Check if user can manage a specific club
  bool canManageClub(String clubId) {
    if (role.isOverallAdmin) return true;
    if (role.isCommunityAdmin && managedClubIds.contains(clubId)) return true;
    return false;
  }

  /// Check if user is member of a club
  bool isMemberOf(String clubId) => clubIds.contains(clubId);

  /// Empty/anonymous user for testing
  static AppUser get empty => AppUser(
    uid: '',
    email: '',
    name: 'Anonymous',
    rollNumber: '',
    department: '',
    year: 0,
    createdAt: DateTime.now(),
  );

  /// Test user for development (before auth is implemented)
  static AppUser testStudent({String? name, UserRole? role}) => AppUser(
    uid: 'test_student_001',
    email: 'student@mvgr.edu.in',
    name: name ?? 'Test Student',
    rollNumber: '21BCE7100',
    department: 'Computer Science',
    year: 3,
    role: role ?? UserRole.student,
    isVerified: true,
    createdAt: DateTime.now(),
  );
}
