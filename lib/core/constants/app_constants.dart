// App-wide constants for MVGR NexUs

class AppConstants {
  // App Info
  static const String appName = 'MVGR NexUs';
  static const String appVersion = '1.0.0';
  static const String collegeName = 'MVGR College of Engineering';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String clubsCollection = 'clubs';
  static const String clubPostsCollection = 'club_posts';
  static const String eventsCollection = 'events';
  static const String announcementsCollection = 'announcements';
  static const String academicQuestionsCollection = 'academic_questions';
  static const String answersCollection = 'answers';
  static const String vaultItemsCollection = 'vault_items';
  static const String lostFoundCollection = 'lost_found';
  static const String studyRequestsCollection = 'study_requests';
  static const String studyMatchesCollection = 'study_matches';
  static const String teamRequestsCollection = 'team_requests';
  static const String mentorsCollection = 'mentors';
  static const String mentorshipRequestsCollection = 'mentorship_requests';
  static const String radioSessionsCollection = 'radio_sessions';
  static const String songVotesCollection = 'song_votes';
  static const String shoutoutsCollection = 'shoutouts';
  static const String meetupsCollection = 'meetups';
  
  // Firebase Storage Paths
  static const String profilePhotosPath = 'profile_photos';
  static const String clubLogosPath = 'club_logos';
  static const String vaultFilesPath = 'vault_files';
  static const String lostFoundImagesPath = 'lost_found_images';
  static const String eventImagesPath = 'event_images';
  
  // Expiry durations
  static const int lostFoundExpiryDays = 30;
  static const int studyRequestExpiryDays = 14;
  static const int teamRequestExpiryDays = 30;
  
  // Limits
  static const int maxVaultFileSize = 25 * 1024 * 1024; // 25 MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxInterests = 10;
  static const int maxSkills = 15;
  static const int maxShoutoutLength = 280;
}

// User roles - 3-tier RBAC
enum UserRole {
  student,         // Regular users
  communityAdmin,  // Club/community managers
  overallAdmin;    // Full system access
  
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.communityAdmin:
        return 'Community Admin';
      case UserRole.overallAdmin:
        return 'Overall Admin';
    }
  }
  
  bool get canModerate => this == UserRole.communityAdmin || this == UserRole.overallAdmin;
  bool get canCreateClub => this == UserRole.overallAdmin;
  bool get canCreateEvent => this != UserRole.student;
  bool get canApproveContent => this == UserRole.overallAdmin;
  bool get canPostAnnouncement => this != UserRole.student;
  bool get isOverallAdmin => this == UserRole.overallAdmin;
  bool get isCommunityAdmin => this == UserRole.communityAdmin;
}

// Moderation status
enum ModerationStatus {
  pending,
  approved,
  rejected,
  flagged;
  
  String get displayName {
    switch (this) {
      case ModerationStatus.pending:
        return 'Pending Review';
      case ModerationStatus.approved:
        return 'Approved';
      case ModerationStatus.rejected:
        return 'Rejected';
      case ModerationStatus.flagged:
        return 'Flagged for Review';
    }
  }
}

/// Animation duration constants to avoid magic numbers
class AnimationDurations {
  static const Duration instant = Duration();
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration shimmer = Duration(milliseconds: 1500);
  static const Duration typewriter = Duration(milliseconds: 50);
  static const Duration fadeIn = Duration(milliseconds: 400);
  static const Duration stagger = Duration(milliseconds: 100);
}

/// UI sizing constants
class UIConstants {
  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusFull = 999.0;
  
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;
  
  // Avatar sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
  static const double avatarXLarge = 100.0;
  
  // Button heights
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;
  
  // Card elevation
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
}
