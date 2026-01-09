import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/radio/models/radio_model.dart';
import '../core/constants/app_constants.dart';
import 'moderation_service.dart';

class RadioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModerationService _moderationService = ModerationService.instance;

  static final RadioService instance = RadioService._init();
  RadioService._init();

  CollectionReference get _songVotesRef => _firestore.collection('song_votes');
  CollectionReference get _shoutoutsRef => _firestore.collection('shoutouts');

  // --- Song Requests ---

  Stream<List<SongVote>> getSongRequestsStream() {
    return _songVotesRef
        .where('isPlayed', isEqualTo: false) // Only active requests
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => SongVote.fromFirestore(doc)).toList());
  }

  Future<void> requestSong(SongVote song) async {
    // Check if song already requested?
    // For MVP, just add new request. Or check by name.
    // Let's assume duplicates allow multiple entries but maybe UI handles it.
    // Ideally we merge votes for same song.
    // For now simplistic approach:
    
    // Check duplication by name (case insensitive?)
    final query = await _songVotesRef
        .where('songName', isEqualTo: song.songName) // Exact match for now
        .where('isPlayed', isEqualTo: false)
        .get();

    if (query.docs.isNotEmpty) {
      // Already exists, just vote for it?
      final existingDoc = query.docs.first;
      await voteSong(existingDoc.id, song.requesterId);
      return;
    }

    final docRef = _songVotesRef.doc();
    final newSong = SongVote(
      id: docRef.id,
      sessionId: song.sessionId,
      songName: song.songName,
      artistName: song.artistName,
      requesterId: song.requesterId,
      requesterName: song.requesterName,
      voteCount: 1,
      voterIds: [song.requesterId],
      isPlayed: false,
      isApproved: true,
      requestedAt: DateTime.now(),
    );
    await docRef.set(newSong.toFirestore());
  }

  Future<void> voteSong(String songId, String userId) async {
    final docRef = _songVotesRef.doc(songId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final song = SongVote.fromFirestore(doc);
    if (!song.voterIds.contains(userId)) {
      await docRef.update({
        'voteCount': FieldValue.increment(1),
        'voterIds': FieldValue.arrayUnion([userId]),
      });
    }
  }

  // --- Shoutouts ---

  Stream<List<Shoutout>> getShoutoutsStream() {
    return _shoutoutsRef
        .where('status', isEqualTo: ModerationStatus.approved.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Shoutout.fromFirestore(doc)).toList());
  }
  
  // For admin/council/faculty to moderate
  Stream<List<Shoutout>> getAllShoutoutsStream() {
    return _shoutoutsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Shoutout.fromFirestore(doc)).toList());
  }

  Future<void> submitShoutout(Shoutout shoutout) async {
    await _moderationService.validateContent(shoutout.message);
    
    final docRef = _shoutoutsRef.doc();
    final newShoutout = Shoutout(
      id: docRef.id,
      sessionId: shoutout.sessionId,
      authorId: shoutout.authorId,
      authorName: shoutout.authorName,
      message: shoutout.message,
      dedicatedTo: shoutout.dedicatedTo,
      isAnonymous: shoutout.isAnonymous,
      status: ModerationStatus.pending, // Always pending initially
      createdAt: DateTime.now(),
      isRead: false,
    );
    await docRef.set(newShoutout.toFirestore());
  }

  Future<void> moderateShoutout(String id, bool approved) async {
    await _shoutoutsRef.doc(id).update({
      'status': approved ? ModerationStatus.approved.name : ModerationStatus.rejected.name,
    });
  }
  
  Future<void> markAsRead(String id) async {
    await _shoutoutsRef.doc(id).update({
      'isRead': true,
    });
  }
}
