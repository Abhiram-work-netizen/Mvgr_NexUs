// Similarity Service - Text Matching Algorithms
// Uses TF-IDF and Cosine Similarity for finding similar content

class SimilarityService {
  /// Tokenize text into lowercase words, removing punctuation
  static List<String> tokenize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 2) // Remove short words
        .where((word) => !_stopWords.contains(word))
        .toList();
  }

  /// Common stop words to ignore
  static const Set<String> _stopWords = {
    'the',
    'is',
    'at',
    'which',
    'on',
    'a',
    'an',
    'and',
    'or',
    'but',
    'in',
    'with',
    'to',
    'for',
    'of',
    'not',
    'no',
    'be',
    'are',
    'was',
    'were',
    'been',
    'being',
    'have',
    'has',
    'had',
    'do',
    'does',
    'did',
    'will',
    'would',
    'could',
    'should',
    'may',
    'might',
    'can',
    'this',
    'that',
    'these',
    'those',
    'i',
    'you',
    'he',
    'she',
    'it',
    'we',
    'they',
    'what',
    'how',
    'why',
    'when',
    'where',
    'who',
    'my',
    'your',
    'his',
    'her',
    'its',
    'our',
    'their',
    'am',
    'me',
    'him',
    'them',
    'any',
  };

  /// Calculate term frequency for a document
  static Map<String, double> termFrequency(List<String> tokens) {
    final Map<String, int> counts = {};
    for (final token in tokens) {
      counts[token] = (counts[token] ?? 0) + 1;
    }

    final total = tokens.length;
    if (total == 0) return {};

    return counts.map((word, count) => MapEntry(word, count / total));
  }

  /// Calculate inverse document frequency
  static Map<String, double> inverseDocumentFrequency(
    List<List<String>> documents,
  ) {
    final Map<String, int> docCounts = {};
    final numDocs = documents.length;

    for (final doc in documents) {
      final uniqueWords = doc.toSet();
      for (final word in uniqueWords) {
        docCounts[word] = (docCounts[word] ?? 0) + 1;
      }
    }

    return docCounts.map(
      (word, count) => MapEntry(word, _log(numDocs / (1 + count))),
    );
  }

  /// Simple log function
  static double _log(num x) {
    if (x <= 0) return 0;
    return _ln(x.toDouble());
  }

  /// Natural log approximation
  static double _ln(double x) {
    if (x <= 0) return 0;
    double result = 0;
    double term = (x - 1) / (x + 1);
    double power = term;
    for (int i = 1; i <= 20; i += 2) {
      result += power / i;
      power *= term * term;
    }
    return 2 * result;
  }

  /// Calculate TF-IDF vector for a document
  static Map<String, double> tfidfVector(
    List<String> tokens,
    Map<String, double> idf,
  ) {
    final tf = termFrequency(tokens);
    final Map<String, double> tfidf = {};

    for (final entry in tf.entries) {
      final idfValue = idf[entry.key] ?? 0;
      tfidf[entry.key] = entry.value * idfValue;
    }

    return tfidf;
  }

  /// Calculate cosine similarity between two vectors
  static double cosineSimilarity(
    Map<String, double> vec1,
    Map<String, double> vec2,
  ) {
    if (vec1.isEmpty || vec2.isEmpty) return 0;

    double dotProduct = 0;
    double norm1 = 0;
    double norm2 = 0;

    final allKeys = {...vec1.keys, ...vec2.keys};

    for (final key in allKeys) {
      final v1 = vec1[key] ?? 0;
      final v2 = vec2[key] ?? 0;
      dotProduct += v1 * v2;
      norm1 += v1 * v1;
      norm2 += v2 * v2;
    }

    if (norm1 == 0 || norm2 == 0) return 0;

    return dotProduct / (_sqrt(norm1) * _sqrt(norm2));
  }

  /// Simple square root using Newton's method
  static double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  /// Find similar items from a list
  /// Returns items sorted by similarity score (highest first)
  static List<SimilarityResult<T>> findSimilar<T>({
    required String query,
    required List<T> items,
    required String Function(T) getText,
    double threshold = 0.1,
    int limit = 5,
  }) {
    if (items.isEmpty || query.trim().isEmpty) return [];

    // Tokenize all documents
    final queryTokens = tokenize(query);
    final itemTokens = items.map((item) => tokenize(getText(item))).toList();

    // Calculate IDF across all documents + query
    final allDocs = [queryTokens, ...itemTokens];
    final idf = inverseDocumentFrequency(allDocs);

    // Get query vector
    final queryVector = tfidfVector(queryTokens, idf);

    // Calculate similarity for each item
    final results = <SimilarityResult<T>>[];

    for (int i = 0; i < items.length; i++) {
      final itemVector = tfidfVector(itemTokens[i], idf);
      final score = cosineSimilarity(queryVector, itemVector);

      if (score >= threshold) {
        results.add(SimilarityResult(item: items[i], score: score));
      }
    }

    // Sort by score descending
    results.sort((a, b) => b.score.compareTo(a.score));

    return results.take(limit).toList();
  }

  /// Simple keyword overlap score (fallback for short texts)
  static double keywordOverlap(String text1, String text2) {
    final tokens1 = tokenize(text1).toSet();
    final tokens2 = tokenize(text2).toSet();

    if (tokens1.isEmpty || tokens2.isEmpty) return 0;

    final intersection = tokens1.intersection(tokens2);
    final union = tokens1.union(tokens2);

    return intersection.length / union.length; // Jaccard similarity
  }
}

/// Result container for similarity search
class SimilarityResult<T> {
  final T item;
  final double score;

  SimilarityResult({required this.item, required this.score});

  /// Score as percentage (0-100)
  int get percentage => (score * 100).round();
}
