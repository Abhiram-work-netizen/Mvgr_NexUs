// Ranking Service - Unified Scoring & Sorting Algorithms
// Provides weighted scoring and ranking for various features

import 'dart:math' as math;

/// Generic ranking service for sorting items by relevance
class RankingService {
  /// Calculate weighted score from multiple factors
  /// Factors: map of factor names to their values (0-100 scale)
  /// Weights: map of factor names to their importance (0-1 scale)
  static double calculateWeightedScore(
    Map<String, double> factors,
    Map<String, double> weights,
  ) {
    if (factors.isEmpty || weights.isEmpty) return 0;

    double totalScore = 0;
    double totalWeight = 0;

    for (final entry in factors.entries) {
      final weight = weights[entry.key] ?? 0;
      totalScore += entry.value * weight;
      totalWeight += weight;
    }

    if (totalWeight == 0) return 0;
    return totalScore / totalWeight;
  }

  /// Rank items by multiple factors with configurable weights
  static List<RankedItem<T>> rankByRelevance<T>({
    required List<T> items,
    required Map<String, double> Function(T) getFactors,
    required Map<String, double> weights,
    bool descending = true,
  }) {
    final ranked = items.map((item) {
      final factors = getFactors(item);
      final score = calculateWeightedScore(factors, weights);
      return RankedItem(item: item, score: score, factors: factors);
    }).toList();

    ranked.sort(
      (a, b) =>
          descending ? b.score.compareTo(a.score) : a.score.compareTo(b.score),
    );

    return ranked;
  }

  /// Time decay function for recency scoring
  /// Returns value between 0-1, where 1 is most recent
  static double recencyScore(
    DateTime timestamp, {
    Duration halfLife = const Duration(days: 7),
  }) {
    final age = DateTime.now().difference(timestamp);
    final lambda = math.log(2) / halfLife.inMilliseconds;
    return math.exp(-lambda * age.inMilliseconds);
  }

  /// Upvote decay score (diminishing returns after threshold)
  static double upvoteScore(int upvotes, {int threshold = 10}) {
    if (upvotes <= 0) return 0;
    if (upvotes <= threshold) return upvotes / threshold;
    // Logarithmic scaling after threshold
    return 1 + (math.log(upvotes / threshold) / math.log(10)) * 0.2;
  }

  /// Normalize value to 0-100 scale
  static double normalize(double value, double min, double max) {
    if (max == min) return 50;
    return ((value - min) / (max - min)) * 100;
  }

  /// Schedule overlap calculation (returns percentage 0-100)
  static double scheduleOverlapScore(
    List<TimeSlot> schedule1,
    List<TimeSlot> schedule2,
  ) {
    if (schedule1.isEmpty || schedule2.isEmpty) return 0;

    int overlapMinutes = 0;
    int totalMinutes = 0;

    for (final slot1 in schedule1) {
      for (final slot2 in schedule2) {
        if (slot1.day == slot2.day) {
          final overlap = _calculateOverlap(
            slot1.startHour,
            slot1.endHour,
            slot2.startHour,
            slot2.endHour,
          );
          overlapMinutes += overlap;
        }
      }
      totalMinutes += (slot1.endHour - slot1.startHour) * 60;
    }

    if (totalMinutes == 0) return 0;
    return (overlapMinutes / totalMinutes) * 100;
  }

  static int _calculateOverlap(int start1, int end1, int start2, int end2) {
    final overlapStart = start1 > start2 ? start1 : start2;
    final overlapEnd = end1 < end2 ? end1 : end2;
    if (overlapStart >= overlapEnd) return 0;
    return (overlapEnd - overlapStart) * 60;
  }

  /// Levenshtein distance for fuzzy matching
  static int levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    s1 = s1.toLowerCase();
    s2 = s2.toLowerCase();

    final List<List<int>> dp = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= s2.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1, // deletion
          dp[i][j - 1] + 1, // insertion
          dp[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[s1.length][s2.length];
  }

  /// Fuzzy match score (0-100, higher = better match)
  static double fuzzyMatchScore(String query, String target) {
    if (query.isEmpty || target.isEmpty) return 0;

    final distance = levenshteinDistance(query, target);
    final maxLen = query.length > target.length ? query.length : target.length;

    return ((1 - distance / maxLen) * 100).clamp(0, 100);
  }

  /// Find fuzzy matches above threshold
  static List<FuzzyMatch<T>> fuzzySearch<T>({
    required String query,
    required List<T> items,
    required String Function(T) getText,
    double threshold = 60,
    int limit = 10,
  }) {
    final results = <FuzzyMatch<T>>[];

    for (final item in items) {
      final text = getText(item);
      final score = fuzzyMatchScore(query, text);

      // Also check if query is contained (higher score for contains)
      final containsBonus = text.toLowerCase().contains(query.toLowerCase())
          ? 30
          : 0;
      final finalScore = (score + containsBonus).clamp(0, 100);

      if (finalScore >= threshold) {
        results.add(
          FuzzyMatch(
            item: item,
            score: finalScore.toDouble(),
            matchedText: text,
          ),
        );
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(limit).toList();
  }
}

/// Ranked item with score breakdown
class RankedItem<T> {
  final T item;
  final double score;
  final Map<String, double> factors;

  RankedItem({required this.item, required this.score, required this.factors});

  int get scorePercent => score.round();
}

/// Result of fuzzy search
class FuzzyMatch<T> {
  final T item;
  final double score;
  final String matchedText;

  FuzzyMatch({
    required this.item,
    required this.score,
    required this.matchedText,
  });
}

/// Time slot for schedule matching
class TimeSlot {
  final int day; // 0 = Monday, 6 = Sunday
  final int startHour; // 0-23
  final int endHour; // 0-23

  const TimeSlot({
    required this.day,
    required this.startHour,
    required this.endHour,
  });

  String get dayName {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day];
  }

  String get timeRange => '$startHour:00 - $endHour:00';
}
