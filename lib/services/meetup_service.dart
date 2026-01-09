import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/offline_community/models/meetup_model.dart';
import 'moderation_service.dart';

class MeetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModerationService _moderationService = ModerationService.instance;

  static final MeetupService instance = MeetupService._init();
  MeetupService._init();

  CollectionReference get _meetupsRef => _firestore.collection('meetups');

  /// Get stream of upcoming meetups
  Stream<List<Meetup>> getMeetupsStream({MeetupCategory? category}) {
    Query query = _meetupsRef
        .orderBy('scheduledAt', descending: false)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.now());

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }
    
    // Note: Firestore requires composite index for 'category' + 'scheduledAt'
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Meetup.fromFirestore(doc)).toList();
    });
  }

  /// Get single meetup stream
  Stream<Meetup> getMeetupStream(String meetupId) {
    return _meetupsRef.doc(meetupId).snapshots().map((doc) => Meetup.fromFirestore(doc));
  }

  /// Create a new meetup
  Future<void> createMeetup(Meetup meetup) async {
    await _moderationService.validateContent('${meetup.title} ${meetup.description}');
    
    final docRef = _meetupsRef.doc();
    final newMeetup = meetup.copyWith(id: docRef.id);
    await docRef.set(newMeetup.toFirestore());
  }

  /// Join a meetup
  Future<void> joinMeetup(String meetupId, String userId) async {
    await _meetupsRef.doc(meetupId).update({
      'participantIds': FieldValue.arrayUnion([userId]),
      'participantCount': FieldValue.increment(1),
    });
  }

  /// Leave a meetup
  Future<void> leaveMeetup(String meetupId, String userId) async {
    await _meetupsRef.doc(meetupId).update({
      'participantIds': FieldValue.arrayRemove([userId]),
      'participantCount': FieldValue.increment(-1),
    });
  }
}
