import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _currentUser;
  bool _isLoading = true;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  // Singleton instance
  static final AuthService instance = AuthService._init();
  AuthService._init() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  bool _isDemoSession = false;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (_isDemoSession) return; // Ignore Firebase updates during demo

    _isLoading = true;
    notifyListeners();

    _userSubscription?.cancel();

    if (firebaseUser == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } else {
      _userSubscription = _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          _currentUser = AppUser.fromFirestore(doc);
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        debugPrint('Error listening to user data: $e');
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  /// Login as a specific role for Demo/Testing
  Future<void> loginAsDemo(UserRole role) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    _isDemoSession = true;
    _currentUser = AppUser(
      uid: 'demo_${role.name}',
      email: '${role.name}@mvgr.edu.in',
      name: 'Demo ${role.displayName}',
      rollNumber: 'DEMO123',
      department: 'Computer Science',
      year: 3,
      role: role,
      createdAt: DateTime.now(),
      isVerified: true,
      clubIds: role == UserRole.communityAdmin ? ['club_001'] : [],
      managedClubIds: role == UserRole.communityAdmin ? ['club_001'] : [],
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Sign Up with Email & Password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String rollNumber, // e.g., 21BCE7100
    required String department,
    required int year,
    UserRole role = UserRole.student,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (cred.user != null) {
        // Create user document in Firestore
        final newUser = AppUser(
          uid: cred.user!.uid,
          email: email,
          name: name,
          rollNumber: rollNumber,
          department: department,
          year: year,
          role: role,
          createdAt: DateTime.now(),
          isVerified: false, // Require manual verification or email link
        );
        
        await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toFirestore());
        _currentUser = newUser;
        notifyListeners();
      }
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign In with Email & Password
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // User data fetch handled by listener
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    _isDemoSession = false;
    _currentUser = null;
    notifyListeners();
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'No user found with this email.';
        case 'wrong-password': return 'Incorrect password.';
        case 'email-already-in-use': return 'Email is already registered.';
        case 'weak-password': return 'Password is too weak.';
        default: return e.message ?? 'Authentication failed.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
