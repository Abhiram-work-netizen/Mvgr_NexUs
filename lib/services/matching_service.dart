import '../features/study_buddy/models/study_buddy_model.dart';
import '../features/play_buddy/models/play_buddy_model.dart';
import '../features/lost_found/models/lost_found_model.dart';
import '../models/user_model.dart';

/// Matching Service for Study Buddy and Team Finder
/// Uses scoring algorithms to find compatible matches
class MatchingService {
  // Stateless service
  const MatchingService();

  // ============ STUDY BUDDY MATCHING ============

  /// Calculate compatibility score for study buddy matching
  /// Score: 0-100 (higher = better match)
  double calculateStudyBuddyScore(StudyRequest request, AppUser user) {
    double score = 0;

    // Subject match (40 points) - Most important
    if (_hasSubjectMatch(request.subject, user.interests)) {
      score += 40;
    }

    // Study mode compatibility (30 points)
    if (request.preferredMode == StudyMode.hybrid) {
      score += 30; // Hybrid is compatible with everyone
    } else {
      score += 20; // Fixed mode gets partial points
    }

    // Shared interests bonus (20 points)
    // Compare topic with user interests
    if (request.topic.isNotEmpty &&
        _hasTopicMatch(request.topic, user.interests)) {
      score += 20;
    }

    // Same department bonus (10 points)
    if (user.department.isNotEmpty) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  /// Get matched study buddies for a user
  List<StudyBuddyMatch> getStudyBuddyMatches(AppUser user, List<StudyRequest> allRequests, {int limit = 10}) {
    final matches = <StudyBuddyMatch>[];

    for (final request in allRequests) {
      // Don't match with own requests
      if (request.userId == user.uid) continue;

      final score = calculateStudyBuddyScore(request, user);

      if (score > 30) {
        // Minimum threshold
        matches.add(
          StudyBuddyMatch(
            request: request,
            compatibilityScore: score,
            matchReason: _getMatchReason(score),
          ),
        );
      }
    }

    // Sort by score descending
    matches.sort(
      (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore),
    );

    return matches.take(limit).toList();
  }

  // ============ TEAM MATCHING ============

  /// Calculate compatibility score for team matching
  double calculateTeamMatchScore(TeamRequest team, AppUser user) {
    double score = 0;

    // Category interest match (30 points)
    if (_hasCategoryInterestMatch(team.category, user.interests)) {
      score += 30;
    }

    // Skills match (40 points)
    final skillMatchCount = _countSkillMatches(
      team.requiredSkills,
      user.skills,
    );
    score += (skillMatchCount * 10).clamp(0, 40).toDouble();

    // Complementary skills (20 points) - User has skills team needs
    if (team.requiredSkills.isNotEmpty && skillMatchCount > 0) {
      score += 20;
    }

    // Available spots (10 points) - More spots = more welcoming
    if (team.spotsLeft > 2) {
      score += 10;
    } else if (team.spotsLeft > 0) {
      score += 5;
    }

    return score.clamp(0, 100);
  }

  /// Get matched teams for a user
  List<TeamMatch> getTeamMatches(AppUser user, List<TeamRequest> allTeams, {int limit = 10}) {
    final matches = <TeamMatch>[];

    for (final team in allTeams) {
      // Don't match with own teams
      if (team.creatorId == user.uid) continue;

      // Only show teams with available spots
      if (team.spotsLeft <= 0) continue;

      final score = calculateTeamMatchScore(team, user);

      if (score > 20) {
        // Minimum threshold
        matches.add(
          TeamMatch(
            team: team,
            compatibilityScore: score,
            matchReason: _getTeamMatchReason(score),
            isPerfectMatch: score >= 85,
          ),
        );
      }
    }

    // Sort by score descending
    matches.sort(
      (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore),
    );

    return matches.take(limit).toList();
  }

  // ============ HELPER METHODS ============

  bool _hasSubjectMatch(String subject, List<String> interests) {
    final subjectLower = subject.toLowerCase();
    return interests.any(
      (i) =>
          i.toLowerCase().contains(subjectLower) ||
          subjectLower.contains(i.toLowerCase()),
    );
  }

  bool _hasTopicMatch(String topic, List<String> interests) {
    final topicLower = topic.toLowerCase();
    return interests.any(
      (i) =>
          i.toLowerCase().contains(topicLower) ||
          topicLower.contains(i.toLowerCase()),
    );
  }

  int _countSkillMatches(List<String> needed, List<String> userSkills) {
    return needed
        .where((n) => userSkills.any((s) => s.toLowerCase() == n.toLowerCase()))
        .length;
  }

  /// TeamCategory: hackathon, sports, esports, cultural, academic, project, other
  bool _hasCategoryInterestMatch(
    TeamCategory category,
    List<String> interests,
  ) {
    const categoryToInterests = {
      TeamCategory.hackathon: [
        'Programming',
        'Web Development',
        'Mobile Development',
        'Machine Learning',
      ],
      TeamCategory.sports: [
        'Cricket',
        'Football',
        'Basketball',
        'Badminton',
        'Athletics',
      ],
      TeamCategory.cultural: ['Music', 'Dance', 'Art & Design'],
      TeamCategory.esports: ['E-Sports', 'PC Gaming', 'Mobile Gaming'],
      TeamCategory.academic: ['Programming', 'Debate', 'Public Speaking'],
      TeamCategory.project: [
        'Programming',
        'Web Development',
        'Robotics',
        'IoT',
      ],
      TeamCategory.other: [],
    };

    final categoryInterests = categoryToInterests[category] ?? [];
    return categoryInterests.any((ci) => interests.contains(ci));
  }

  String _getMatchReason(double score) {
    if (score >= 80) return 'Excellent Match';
    if (score >= 60) return 'Great Match';
    if (score >= 40) return 'Good Match';
    return 'Compatible';
  }

  String _getTeamMatchReason(double score) {
    if (score >= 85) return '⭐ Perfect Match';
    if (score >= 70) return 'Great Fit';
    if (score >= 50) return 'Good Fit';
    return 'Potential Match';
  }

  // ============ LOST & FOUND AUTO-MATCHING ============

  /// Find potential matches between lost and found items
  /// Uses description similarity and category matching
  List<LostFoundMatch> findLostFoundMatches(String itemId, List<LostFoundItem> allItems) {
    final targetItem = allItems.firstWhere(
      (i) => i.id == itemId,
      orElse: () => allItems.first,
    );

    final matches = <LostFoundMatch>[];

    // Find opposite status items (lost <-> found)
    final oppositeItems = allItems.where((i) {
      if (i.id == itemId) return false;
      if (targetItem.status == LostFoundStatus.lost) {
        return i.status == LostFoundStatus.found;
      } else if (targetItem.status == LostFoundStatus.found) {
        return i.status == LostFoundStatus.lost;
      }
      return false;
    });

    for (final item in oppositeItems) {
      double score = 0;

      // Category match (40 points)
      if (item.category == targetItem.category) {
        score += 40;
      }

      // Location similarity (30 points)
      if (_locationMatch(item.location, targetItem.location)) {
        score += 30;
      }

      // Description keyword overlap (30 points)
      final descScore = _descriptionSimilarity(
        item.description,
        targetItem.description,
      );
      score += descScore * 30;

      if (score >= 30) {
        matches.add(
          LostFoundMatch(
            item: item,
            matchScore: score,
            reason: _getLostFoundMatchReason(score),
          ),
        );
      }
    }

    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return matches.take(5).toList();
  }

  bool _locationMatch(String loc1, String loc2) {
    final l1 = loc1.toLowerCase();
    final l2 = loc2.toLowerCase();

    // Check for common building names
    final buildings = [
      'library',
      'canteen',
      'block',
      'lab',
      'hostel',
      'ground',
    ];
    for (final building in buildings) {
      if (l1.contains(building) && l2.contains(building)) {
        return true;
      }
    }
    return l1 == l2;
  }

  double _descriptionSimilarity(String desc1, String desc2) {
    final words1 = desc1
        .toLowerCase()
        .split(' ')
        .where((w) => w.length > 3)
        .toSet();
    final words2 = desc2
        .toLowerCase()
        .split(' ')
        .where((w) => w.length > 3)
        .toSet();

    if (words1.isEmpty || words2.isEmpty) return 0;

    final intersection = words1.intersection(words2);
    return intersection.length /
        (words1.length + words2.length - intersection.length);
  }

  String _getLostFoundMatchReason(double score) {
    if (score >= 80) return '🎯 Likely Match';
    if (score >= 60) return 'Possible Match';
    if (score >= 40) return 'Similar Item';
    return 'Check This';
  }
}

/// Study Buddy Match result
class StudyBuddyMatch {
  final StudyRequest request;
  final double compatibilityScore;
  final String matchReason;

  StudyBuddyMatch({
    required this.request,
    required this.compatibilityScore,
    required this.matchReason,
  });

  int get scorePercentage => compatibilityScore.round();
}

/// Team Match result
class TeamMatch {
  final TeamRequest team;
  final double compatibilityScore;
  final String matchReason;
  final bool isPerfectMatch;

  TeamMatch({
    required this.team,
    required this.compatibilityScore,
    required this.matchReason,
    this.isPerfectMatch = false,
  });

  int get scorePercentage => compatibilityScore.round();
}

/// Lost & Found Match result
class LostFoundMatch {
  final LostFoundItem item;
  final double matchScore;
  final String reason;

  LostFoundMatch({
    required this.item,
    required this.matchScore,
    required this.reason,
  });

  int get scorePercentage => matchScore.round();
}
