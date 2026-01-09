import 'package:intl/intl.dart';

/// Date and time utility extensions
extension DateTimeExtensions on DateTime {
  /// Format as "Dec 24, 2025"
  String get formattedDate => DateFormat('MMM d, y').format(this);
  
  /// Format as "10:30 AM"
  String get formattedTime => DateFormat('h:mm a').format(this);
  
  /// Format as "Dec 24, 2025 at 10:30 AM"
  String get formattedDateTime => DateFormat('MMM d, y \'at\' h:mm a').format(this);
  
  /// Format as "Tuesday, December 24"
  String get formattedFullDate => DateFormat('EEEE, MMMM d').format(this);
  
  /// Format as relative time (e.g., "2 hours ago", "Yesterday")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
  
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());
  
  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());
  
  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);
  
  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}

/// String utility extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
  
  /// Get initials (first 2 characters of first 2 words)
  String get initials {
    if (isEmpty) return '';
    final words = trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
  }
  
  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  /// Check if string is college email (customize domain)
  bool get isCollegeEmail {
    // Add your college domain here, e.g., mvgr.edu.in
    return toLowerCase().endsWith('@mvgr.edu.in') || 
           toLowerCase().endsWith('@student.mvgr.edu.in');
  }
  
  /// Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - 3)}...';
  }
  
  /// Remove HTML tags
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

/// List utility extensions
extension ListExtensions<T> on List<T> {
  /// Get element at index or null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  /// Split list into chunks
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Number formatting extensions
extension NumberExtensions on num {
  /// Format as compact number (e.g., 1.2K, 3.4M)
  String get compact {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
  
  /// Format file size
  String get fileSize {
    if (this >= 1073741824) {
      return '${(this / 1073741824).toStringAsFixed(2)} GB';
    } else if (this >= 1048576) {
      return '${(this / 1048576).toStringAsFixed(2)} MB';
    } else if (this >= 1024) {
      return '${(this / 1024).toStringAsFixed(2)} KB';
    }
    return '$this B';
  }
}
