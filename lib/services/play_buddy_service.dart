import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/play_buddy/models/play_buddy_model.dart';

class PlayBuddyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final PlayBuddyService instance = PlayBuddyService._init();
  PlayBuddyService._init();

  CollectionReference get _teamsRef => _firestore.collection('team_requests');
  CollectionReference get _joinRequestsRef => _firestore.collection('team_join_requests');

  /// Get stream of active team requests
  Stream<List<TeamRequest>> getTeamsStream({bool includeClosed = false}) {
    Query query = _teamsRef.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      final teams = snapshot.docs
          .map((doc) => TeamRequest.fromFirestore(doc))
          .toList();
      
      if (!includeClosed) {
        return teams.where((t) => t.isOpen).toList();
      }
      return teams;
    });
  }

  /// Create a new team request
  Future<void> createTeam(TeamRequest team) async {
    final docRef = _teamsRef.doc();
    final newTeam = team.copyWith(id: docRef.id);
    await docRef.set(newTeam.toFirestore());
  }

  /// Request to join a team
  Future<void> requestToJoin(JoinRequest request) async {
    final docRef = _joinRequestsRef.doc();
    // Check if already requested? Client side check or security rule better.
    // For now simple add.
    // We might want to store id in JoinRequest
    // The current JoinRequest model assumes ID is passed in constructor or generated.
    // Let's generate it.
    // But JoinRequest constructor takes ID.
    // We can assume the builder handles it or we copy it here.
    // To be safe we should probably copy with new ID if empty, but model is immutable.
    // We will assume the caller might not provide ID, so we generate.
    
    // Actually JoinRequest constructor requires id.
    // Let's just write whatever is passed, assuming ID is handled by caller or we update it.
    // Let's treat ID generation here.
    final requestWithId = JoinRequest(
      id: docRef.id,
      teamRequestId: request.teamRequestId,
      userId: request.userId,
      userName: request.userName,
      message: request.message,
      relevantSkills: request.relevantSkills,
      status: request.status,
      createdAt: request.createdAt,
    );

    await docRef.set(requestWithId.toFirestore());
  }
  
  /// Check if user has already requested to join
  Future<bool> hasRequested(String teamId, String userId) async {
    final query = await _joinRequestsRef
        .where('teamRequestId', isEqualTo: teamId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Delete a team request (creator only)
  Future<void> deleteTeam(String teamId) async {
    // Delete all join requests for this team first
    final joinRequests = await _joinRequestsRef
        .where('teamRequestId', isEqualTo: teamId)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in joinRequests.docs) {
      batch.delete(doc.reference);
    }
    
    // Delete the team request
    batch.delete(_teamsRef.doc(teamId));
    
    await batch.commit();
  }
}
