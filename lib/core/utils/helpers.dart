import 'package:flutter/material.dart';

/// Validation helpers for forms
class Validators {
  /// Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  /// College email validator
  static String? collegeEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'College email is required';
    }
    final email = value.toLowerCase();
    if (!email.endsWith('@mvgr.edu.in') && !email.endsWith('@student.mvgr.edu.in')) {
      return 'Please use your college email';
    }
    return null;
  }
  
  /// Required field validator
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }
  
  /// Confirm password validator
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  /// Phone number validator
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }
  
  /// Roll number validator (customize pattern for your college)
  static String? rollNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Roll number is required';
    }
    // Customize this regex for MVGR roll number format
    // Example: 21BCE7100 (YY + Branch + Number)
    if (!RegExp(r'^\d{2}[A-Z]{3}\d{4}$').hasMatch(value.toUpperCase())) {
      return 'Please enter a valid roll number';
    }
    return null;
  }
  
  /// Min length validator
  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }
    return null;
  }
  
  /// Max length validator
  static String? maxLength(String? value, int max, [String fieldName = 'This field']) {
    if (value != null && value.length > max) {
      return '$fieldName must not exceed $max characters';
    }
    return null;
  }
}

/// Helper class for showing snackbars and dialogs
class UIHelpers {
  /// Show a success snackbar
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show an error snackbar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show an info snackbar
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Show a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  /// Show a loading dialog
  static void showLoading(BuildContext context, [String message = 'Loading...']) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  /// Hide loading dialog
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Helper class for safe name handling
class NameHelpers {
  /// Safely get the first name from a full name string
  /// Returns 'User' if name is empty or null
  static String getFirstName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'User';
    }
    final parts = name.trim().split(' ');
    return parts.first.isNotEmpty ? parts.first : 'User';
  }

  /// Safely get initials from a name (max 2 characters)
  /// Returns '?' if name is empty or null
  static String getInitials(String? name, {int maxLength = 2}) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    
    final initials = parts
        .take(maxLength)
        .map((p) => p[0].toUpperCase())
        .join();
    return initials.isNotEmpty ? initials : '?';
  }

  /// Safely get a single character for avatar display
  /// Returns '?' if name is empty or null
  static String getAvatarChar(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }
    return name.trim()[0].toUpperCase();
  }

  /// Safely get display name with fallback
  static String getDisplayName(String? name, {String fallback = 'Unknown User'}) {
    if (name == null || name.trim().isEmpty) {
      return fallback;
    }
    return name.trim();
  }
}

/// Result class for type-safe error handling
/// Use this pattern for operations that can fail
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result._({this.data, this.error, required this.isSuccess});

  /// Create a successful result with data
  factory Result.success(T data) => Result._(data: data, isSuccess: true);

  /// Create a failed result with error message
  factory Result.failure(String error) => Result._(error: error, isSuccess: false);

  /// Execute callback based on result
  R when<R>({
    required R Function(T data) success,
    required R Function(String error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    }
    return failure(error ?? 'Unknown error');
  }
}

/// Error handler utility for centralized error management
class ErrorHandler {
  /// Handle an error with optional context and show user-friendly message
  static String getUserMessage(Object error) {
    if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    }
    if (error is ArgumentError) {
      return 'Invalid input provided.';
    }
    if (error.toString().contains('network') || 
        error.toString().contains('socket') ||
        error.toString().contains('connection')) {
      return 'Network error. Please check your connection.';
    }
    // Default message
    return 'Something went wrong. Please try again.';
  }

  /// Log error for debugging (can be extended to send to crash reporting)
  static void logError(Object error, [StackTrace? stackTrace, String? context]) {
    debugPrint('[$context] Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Safely execute an operation with error handling
  static Future<Result<T>> safeExecute<T>(
    Future<T> Function() operation, {
    String? context,
  }) async {
    try {
      final result = await operation();
      return Result.success(result);
    } catch (e, stackTrace) {
      logError(e, stackTrace, context);
      return Result.failure(getUserMessage(e));
    }
  }

  /// Synchronous version of safeExecute
  static Result<T> safeExecuteSync<T>(
    T Function() operation, {
    String? context,
  }) {
    try {
      final result = operation();
      return Result.success(result);
    } catch (e, stackTrace) {
      logError(e, stackTrace, context);
      return Result.failure(getUserMessage(e));
    }
  }
}
