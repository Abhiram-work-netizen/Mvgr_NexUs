import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/study_buddy/models/study_buddy_model.dart';

class StudyBuddyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final StudyBuddyService instance = StudyBuddyService._init();
  StudyBuddyService._init();

  CollectionReference get _requestsRef => _firestore.collection('study_requests');

  /// Get stream of active study requests
  Stream<List<StudyRequest>> getRequestsStream({bool includeExpired = false}) {
    Query query = _requestsRef.orderBy('createdAt', descending: true);

    // Filter by status if needed, but client-side might be easier for complex expiration logic
    // We can filter status==active in query
    // query = query.where('status', isEqualTo: RequestStatus.active.name);

    return query.snapshots().map((snapshot) {
      final requests = snapshot.docs
          .map((doc) => StudyRequest.fromFirestore(doc))
          .toList();
      
      if (!includeExpired) {
        return requests.where((r) => r.isActive).toList();
      }
      return requests;
    });
  }

  /// Create a new study request
  Future<void> createRequest(StudyRequest request) async {
    final docRef = _requestsRef.doc();
    final newRequest = request.copyWith(id: docRef.id);
    await docRef.set(newRequest.toFirestore());
  }

  /// Update request status
  Future<void> updateRequestStatus(String requestId, RequestStatus status) async {
    await _requestsRef.doc(requestId).update({'status': status.name});
  }

  /// Delete request
  Future<void> deleteRequest(String requestId) async {
     await _requestsRef.doc(requestId).delete();
  }
}
