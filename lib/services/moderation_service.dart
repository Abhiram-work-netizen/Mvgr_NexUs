import 'package:flutter/foundation.dart';

class ModerationService {
  // Singleton instance
  static final ModerationService instance = ModerationService._init();
  
  ModerationService._init();

  /// Validates content efficiently (No API)
  /// Returns [true] if content is safe, [false] if unsafe.
  Future<bool> checkText(String text) async {
    // Basic local keyword check for obvious bad words
    // This is a placeholder since API is removed.
    final lower = text.toLowerCase();
    final badWords = ['abuse', 'hate', 'kill', 'suicide', 'attack']; 
    
    for (final word in badWords) {
      if (lower.contains(word)) {
        debugPrint('Moderation blocked: $word');
        return false; 
      }
    }
    return true; // Assume safe by default
  }

  /// Validates content before posting
  /// Throws exception if unsafe
  Future<void> validateContent(String text) async {
    final isSafe = await checkText(text);
    if (!isSafe) {
      throw Exception('Content flagged by AI moderation as inappropriate.');
    }
  }
}
