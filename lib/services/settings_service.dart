import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options
enum AppThemeMode {
  system,
  light,
  dark;

  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

/// Settings Service - Manages user preferences
/// Persists to SharedPreferences automatically
class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  static SettingsService get instance => _instance;

  SettingsService._internal();

  // Track if we're currently loading to prevent save during load
  bool _isLoading = false;

  @override
  void notifyListeners() {
    super.notifyListeners();
    // Auto-save when settings change (but not during initial load)
    if (!_isLoading) {
      saveToStorage();
    }
  }

  // ============ NOTIFICATIONS ============
  bool _pushNotifications = true;
  bool _eventReminders = true;
  bool _clubUpdates = true;
  bool _announcements = true;
  bool _mentorshipUpdates = true;
  bool _forumReplies = true;

  bool get pushNotifications => _pushNotifications;
  set pushNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
  }

  bool get eventReminders => _eventReminders;
  set eventReminders(bool value) {
    _eventReminders = value;
    notifyListeners();
  }

  bool get clubUpdates => _clubUpdates;
  set clubUpdates(bool value) {
    _clubUpdates = value;
    notifyListeners();
  }

  bool get announcements => _announcements;
  set announcements(bool value) {
    _announcements = value;
    notifyListeners();
  }

  bool get mentorshipUpdates => _mentorshipUpdates;
  set mentorshipUpdates(bool value) {
    _mentorshipUpdates = value;
    notifyListeners();
  }

  bool get forumReplies => _forumReplies;
  set forumReplies(bool value) {
    _forumReplies = value;
    notifyListeners();
  }

  // ============ APPEARANCE ============
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _enableAnimations = true;
  bool _hapticFeedback = true;
  bool _compactMode = false;

  AppThemeMode get themeMode => _themeMode;
  set themeMode(AppThemeMode value) {
    _themeMode = value;
    notifyListeners();
  }

  bool get enableAnimations => _enableAnimations;
  set enableAnimations(bool value) {
    _enableAnimations = value;
    notifyListeners();
  }

  bool get hapticFeedback => _hapticFeedback;
  set hapticFeedback(bool value) {
    _hapticFeedback = value;
    notifyListeners();
  }

  bool get compactMode => _compactMode;
  set compactMode(bool value) {
    _compactMode = value;
    notifyListeners();
  }

  // ============ PRIVACY ============
  bool _profileVisible = true;
  bool _showActivityStatus = true;
  bool _analyticsEnabled = true;
  bool _showEmailToClubs = false;
  bool _showPhoneToMentors = false;

  bool get profileVisible => _profileVisible;
  set profileVisible(bool value) {
    _profileVisible = value;
    notifyListeners();
  }

  bool get showActivityStatus => _showActivityStatus;
  set showActivityStatus(bool value) {
    _showActivityStatus = value;
    notifyListeners();
  }

  bool get analyticsEnabled => _analyticsEnabled;
  set analyticsEnabled(bool value) {
    _analyticsEnabled = value;
    notifyListeners();
  }

  bool get showEmailToClubs => _showEmailToClubs;
  set showEmailToClubs(bool value) {
    _showEmailToClubs = value;
    notifyListeners();
  }

  bool get showPhoneToMentors => _showPhoneToMentors;
  set showPhoneToMentors(bool value) {
    _showPhoneToMentors = value;
    notifyListeners();
  }

  // ============ DATA & STORAGE ============
  double _cacheSize = 24.5; // MB

  double get cacheSize => _cacheSize;

  void clearCache() {
    _cacheSize = 0;
    notifyListeners();
  }

  // ============ CONTENT PREFERENCES ============
  bool _autoPlayVideos = true;
  bool _loadImagesOnData = true;
  String _defaultFeedView = 'all'; // 'all', 'clubs', 'events'

  bool get autoPlayVideos => _autoPlayVideos;
  set autoPlayVideos(bool value) {
    _autoPlayVideos = value;
    notifyListeners();
  }

  bool get loadImagesOnData => _loadImagesOnData;
  set loadImagesOnData(bool value) {
    _loadImagesOnData = value;
    notifyListeners();
  }

  String get defaultFeedView => _defaultFeedView;
  set defaultFeedView(String value) {
    _defaultFeedView = value;
    notifyListeners();
  }

  // ============ RESET ============
  void resetToDefaults() {
    // Notifications
    _pushNotifications = true;
    _eventReminders = true;
    _clubUpdates = true;
    _announcements = true;
    _mentorshipUpdates = true;
    _forumReplies = true;

    // Appearance
    _themeMode = AppThemeMode.system;
    _enableAnimations = true;
    _hapticFeedback = true;
    _compactMode = false;

    // Privacy
    _profileVisible = true;
    _showActivityStatus = true;
    _analyticsEnabled = true;
    _showEmailToClubs = false;
    _showPhoneToMentors = false;

    // Content
    _autoPlayVideos = true;
    _loadImagesOnData = true;
    _defaultFeedView = 'all';

    notifyListeners();
  }

  // ============ PERSISTENCE ============
  Future<void> loadFromStorage() async {
    _isLoading = true;
    final prefs = await SharedPreferences.getInstance();
    
    // Notifications
    _pushNotifications = prefs.getBool('pushNotifications') ?? true;
    _eventReminders = prefs.getBool('eventReminders') ?? true;
    _clubUpdates = prefs.getBool('clubUpdates') ?? true;
    _announcements = prefs.getBool('announcements') ?? true;
    _mentorshipUpdates = prefs.getBool('mentorshipUpdates') ?? true;
    _forumReplies = prefs.getBool('forumReplies') ?? true;
    
    // Appearance
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = AppThemeMode.values[themeModeIndex.clamp(0, AppThemeMode.values.length - 1)];
    _enableAnimations = prefs.getBool('enableAnimations') ?? true;
    _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    _compactMode = prefs.getBool('compactMode') ?? false;
    
    // Privacy
    _profileVisible = prefs.getBool('profileVisible') ?? true;
    _showActivityStatus = prefs.getBool('showActivityStatus') ?? true;
    _analyticsEnabled = prefs.getBool('analyticsEnabled') ?? true;
    _showEmailToClubs = prefs.getBool('showEmailToClubs') ?? false;
    _showPhoneToMentors = prefs.getBool('showPhoneToMentors') ?? false;
    
    // Content
    _autoPlayVideos = prefs.getBool('autoPlayVideos') ?? true;
    _loadImagesOnData = prefs.getBool('loadImagesOnData') ?? true;
    _defaultFeedView = prefs.getString('defaultFeedView') ?? 'all';
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Notifications
    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setBool('eventReminders', _eventReminders);
    await prefs.setBool('clubUpdates', _clubUpdates);
    await prefs.setBool('announcements', _announcements);
    await prefs.setBool('mentorshipUpdates', _mentorshipUpdates);
    await prefs.setBool('forumReplies', _forumReplies);
    
    // Appearance
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setBool('enableAnimations', _enableAnimations);
    await prefs.setBool('hapticFeedback', _hapticFeedback);
    await prefs.setBool('compactMode', _compactMode);
    
    // Privacy
    await prefs.setBool('profileVisible', _profileVisible);
    await prefs.setBool('showActivityStatus', _showActivityStatus);
    await prefs.setBool('analyticsEnabled', _analyticsEnabled);
    await prefs.setBool('showEmailToClubs', _showEmailToClubs);
    await prefs.setBool('showPhoneToMentors', _showPhoneToMentors);
    
    // Content
    await prefs.setBool('autoPlayVideos', _autoPlayVideos);
    await prefs.setBool('loadImagesOnData', _loadImagesOnData);
    await prefs.setString('defaultFeedView', _defaultFeedView);
  }
}

/// Notification Service - Handles notification logic
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  final List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) _unreadCount++;
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
  }

  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
  }
}

/// App Notification Model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? targetId;
  final DateTime createdAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.targetId,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? targetId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// Notification Types
enum NotificationType {
  event,
  club,
  announcement,
  mentorship,
  forum,
  general,
}

/// Feedback Service - For user feedback and reports
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  static FeedbackService get instance => _instance;

  FeedbackService._internal();

  final List<UserFeedback> _feedbackList = [];

  List<UserFeedback> get allFeedback => List.unmodifiable(_feedbackList);

  void submitFeedback(UserFeedback feedback) {
    _feedbackList.add(feedback);
  }

  void submitBugReport({
    required String userId,
    required String title,
    required String description,
    String? screenName,
  }) {
    _feedbackList.add(UserFeedback(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: FeedbackType.bug,
      title: title,
      description: description,
      screenName: screenName,
      createdAt: DateTime.now(),
    ));
  }

  void submitFeatureRequest({
    required String userId,
    required String title,
    required String description,
  }) {
    _feedbackList.add(UserFeedback(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: FeedbackType.feature,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    ));
  }

  void submitGeneralFeedback({
    required String userId,
    required String description,
    int? rating,
  }) {
    _feedbackList.add(UserFeedback(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: FeedbackType.general,
      title: 'General Feedback',
      description: description,
      rating: rating,
      createdAt: DateTime.now(),
    ));
  }
}

/// User Feedback Model
class UserFeedback {
  final String id;
  final String userId;
  final FeedbackType type;
  final String title;
  final String description;
  final String? screenName;
  final int? rating;
  final DateTime createdAt;
  final String status; // pending, reviewed, resolved

  UserFeedback({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.screenName,
    this.rating,
    required this.createdAt,
    this.status = 'pending',
  });
}

/// Feedback Types
enum FeedbackType {
  bug,
  feature,
  general,
}

/// Analytics Service - For tracking usage (with privacy)
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;

  AnalyticsService._internal();

  bool _enabled = true;

  bool get isEnabled => _enabled && SettingsService.instance.analyticsEnabled;

  void setEnabled(bool value) {
    _enabled = value;
  }

  void logScreenView(String screenName) {
    if (!isEnabled) return;
    // TODO: Log to analytics
    debugPrint('[Analytics] Screen: $screenName');
  }

  void logEvent(String eventName, [Map<String, dynamic>? parameters]) {
    if (!isEnabled) return;
    // TODO: Log to analytics
    debugPrint('[Analytics] Event: $eventName ${parameters ?? ''}');
  }

  void logUserAction(String action, {String? target, String? context}) {
    if (!isEnabled) return;
    debugPrint('[Analytics] Action: $action, target: $target, context: $context');
  }

  void logSearch(String query, int resultsCount) {
    if (!isEnabled) return;
    debugPrint('[Analytics] Search: "$query" -> $resultsCount results');
  }

  void logError(String error, {String? stackTrace}) {
    // Always log errors
    debugPrint('[Analytics] Error: $error');
    if (stackTrace != null) debugPrint(stackTrace);
  }
}
