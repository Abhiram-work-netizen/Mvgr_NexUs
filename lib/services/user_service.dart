import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import 'auth_service.dart';

/// Service for managing user data directly in Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Singleton
  static final UserService instance = UserService._init();
  UserService._init();

  /// Update user interests
  Future<void> updateInterests(String uid, List<String> interests) async {
    await _firestore.collection('users').doc(uid).update({
      'interests': interests,
    });
  }

  /// Update user role (Administrator/Demo purposes)
  Future<void> updateRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role.name,
    });
  }

  /// Upload profile image to Firebase Storage
  Future<String> uploadProfileImage(String uid, String filePath) async {
    final ref = FirebaseStorage.instance.ref().child('user_profiles').child('$uid.jpg');
    // Set metadata if needed, but simple putFile is usually enough
    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  /// Update profile photo URL
  /// Update user profile data (bio, skills, color, etc.)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}

/// Main user provider - bridges AuthService and UserService to UI
class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  UserProvider() {
    _authService.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  AppUser? get currentUser => _authService.currentUser;
  
  /// Helper to get a non-null user for easy UI binding (falling back to test user if not logged in)
  /// In a real production app, you might handle 'Guest' differently.
  AppUser get user => currentUser ?? AppUser.testStudent();

  bool get isLoading => _authService.isLoading;
  bool get isLoggedIn => _authService.isLoggedIn;
  
  String get userId => currentUser?.uid ?? '';
  String get userName => currentUser?.name ?? 'Guest';
  UserRole get userRole => currentUser?.role ?? UserRole.student;
  
  // Permissions
  bool get canModerate => currentUser?.role.canModerate ?? false;
  bool get canCreateClub => currentUser?.role.canCreateClub ?? false;
  bool get canCreateEvent => currentUser?.role.canCreateEvent ?? false;
  bool get canApproveContent => currentUser?.role.canApproveContent ?? false;

  // Actions
  Future<void> updateInterests(List<String> interests) async {
    if (userId.isEmpty && currentUser == null) return;
    await UserService.instance.updateInterests(user.uid, interests);
    // Force refresh or optimistic update ideally, but auth service stream usually updates
  }

  Future<void> updateRole(UserRole role) async {
    await UserService.instance.updateRole(user.uid, role);
  }

  Future<void> updateProfilePhoto(String filePath) async {
    if (userId.isEmpty) return;
    String url = await UserService.instance.uploadProfileImage(userId, filePath);
    await UserService.instance.updateUser(userId, {'profilePhotoUrl': url});
    notifyListeners();
  }

  Future<void> updateUser(Map<String, dynamic> data) async {
    if (userId.isEmpty) return;
    await UserService.instance.updateUser(userId, data);
    notifyListeners(); 
  }
}
