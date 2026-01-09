import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/mentorship/models/mentorship_model.dart';

class MentorshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final MentorshipService instance = MentorshipService._init();
  MentorshipService._init();

  CollectionReference get _mentorsRef => _firestore.collection('mentors');
  CollectionReference get _requestsRef => _firestore.collection('mentorship_requests');

  /// Get stream of mentors, optionally filtered by area
  Stream<List<Mentor>> getMentorsStream({MentorshipArea? area}) {
    Query query = _mentorsRef.orderBy('name');

    if (area != null) {
      query = query.where('areas', arrayContains: area.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Mentor.fromFirestore(doc))
          .toList();
    });
  }

  /// Submit a mentorship request
  Future<void> submitRequest(MentorshipRequest request) async {
    final docRef = _requestsRef.doc();
    final newRequest = MentorshipRequest(
      id: docRef.id,
      mentorId: request.mentorId,
      menteeId: request.menteeId,
      menteeName: request.menteeName,
      area: request.area,
      message: request.message,
      goal: request.goal,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    await docRef.set(newRequest.toFirestore());
  }

  /// Check if a request already exists
  Future<bool> hasRequested(String mentorId, String menteeId) async {
    // Only check for pending or accepted requests? 
    // Usually if rejected/completed, one might apply again.
    // For now, let's just check for pending/accepted.
    final query = await _requestsRef
        .where('mentorId', isEqualTo: mentorId)
        .where('menteeId', isEqualTo: menteeId)
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(1)
        .get();
    
    return query.docs.isNotEmpty;
  }
}
