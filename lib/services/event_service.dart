import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/events/models/event_model.dart';
import 'moderation_service.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModerationService _moderationService = ModerationService.instance;

  static final EventService instance = EventService._init();
  EventService._init();

  CollectionReference get _eventsRef => _firestore.collection('events');
  CollectionReference get _announcementsRef => _firestore.collection('announcements');

  // --- Events ---

  Stream<List<Event>> getEventsStream() {
    return _eventsRef
        .orderBy('eventDate', descending: false)
        .where('eventDate', isGreaterThanOrEqualTo: Timestamp.now()) // Upcoming events
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }

  Stream<List<Event>> getUserEventsStream(String userId) {
    return _eventsRef
        .where('rsvpIds', arrayContains: userId)
        .orderBy('eventDate', descending: true) // Most recent first (mix of past and upcoming)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList());
  }
  
  Stream<Event> getEventStream(String eventId) {
    return _eventsRef.doc(eventId).snapshots().map((doc) => Event.fromFirestore(doc));
  }

  Future<void> createEvent(Event event) async {
    await _moderationService.validateContent('${event.title} ${event.description}');
    if (event.title.isEmpty) throw Exception('Event title cannot be empty');

    final docRef = _eventsRef.doc();
    final newEvent = event.copyWith(id: docRef.id);
    await docRef.set(newEvent.toFirestore());
  }

  Future<void> updateEvent(Event event) async {
    await _moderationService.validateContent('${event.title} ${event.description}');
    if (event.title.isEmpty) throw Exception('Event title cannot be empty');
    await _eventsRef.doc(event.id).update(event.toFirestore());
  }

  Future<void> toggleRSVP(String eventId, String userId, String userName) async {
    final docSnapshot = await _eventsRef.doc(eventId).get();
    if (!docSnapshot.exists) return;
    
    final event = Event.fromFirestore(docSnapshot);
    final hasRSVP = event.rsvpIds.contains(userId);
    
    if (hasRSVP) {
      // Remove from array
      await _eventsRef.doc(eventId).update({
        'rsvpIds': FieldValue.arrayRemove([userId])
      });
      // Delete registration doc
      await _eventsRef.doc(eventId).collection('registrations').doc(userId).delete();
    } else {
       if (event.isFull) throw Exception('Event is full');
       // Add to array
      await _eventsRef.doc(eventId).update({
        'rsvpIds': FieldValue.arrayUnion([userId])
      });
      // Create registration doc
      final registration = EventRegistration(
        userId: userId,
        userName: userName,
        registeredAt: DateTime.now(),
      );
      await _eventsRef.doc(eventId).collection('registrations').doc(userId).set(registration.toFirestore());
    }
  }

  /// Get event attendees stream
  Stream<List<EventRegistration>> getEventAttendeesStream(String eventId) {
    return _eventsRef
        .doc(eventId)
        .collection('registrations')
        .orderBy('registeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => EventRegistration.fromFirestore(doc)).toList());
  }

  /// Check in attendee
  Future<void> checkInAttendee(String eventId, String userId) async {
    await _eventsRef.doc(eventId).collection('registrations').doc(userId).update({
      'isCheckedIn': true,
      'checkInTime': Timestamp.now(),
    });
  }

  Future<void> toggleInterest(String eventId, String userId) async {
    final docSnapshot = await _eventsRef.doc(eventId).get();
    if (!docSnapshot.exists) return;
    
    final event = Event.fromFirestore(docSnapshot);
    final isInterested = event.interestedIds.contains(userId);
    
    if (isInterested) {
      await _eventsRef.doc(eventId).update({
        'interestedIds': FieldValue.arrayRemove([userId])
      });
    } else {
      await _eventsRef.doc(eventId).update({
        'interestedIds': FieldValue.arrayUnion([userId])
      });
    }
  }

  // --- Announcements ---

  Stream<List<Announcement>> getAnnouncementsStream() {
    return _announcementsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Announcement.fromFirestore(doc)).toList());
  }

  Future<void> createAnnouncement(Announcement announcement) async {
    await _moderationService.validateContent('${announcement.title} ${announcement.content}');
    
    final docRef = _announcementsRef.doc();
    
    // Create new object with new ID
    final finalAnn = Announcement(
      id: docRef.id,
      title: announcement.title,
      content: announcement.content,
      authorId: announcement.authorId,
      authorName: announcement.authorName,
      authorRole: announcement.authorRole,
      isPinned: announcement.isPinned,
      isUrgent: announcement.isUrgent,
      createdAt: announcement.createdAt,
      expiresAt: announcement.expiresAt,
    );

    await docRef.set(finalAnn.toFirestore());
  }

  Future<void> cancelEvent(String eventId) async {
    await _eventsRef.doc(eventId).update({'isCancelled': true});
  }

  Future<void> deleteEvent(String eventId) async {
    // 1. Delete all registrations
    final registrations = await _eventsRef.doc(eventId).collection('registrations').get();
    final batch = _firestore.batch();
    for (var doc in registrations.docs) {
      batch.delete(doc.reference);
    }
    
    // 2. Delete event document
    batch.delete(_eventsRef.doc(eventId));
    
    await batch.commit();
  }

  /// Batch check-in
  Future<void> batchCheckIn(String eventId, List<String> userIds) async {
    final batch = _firestore.batch();
    for (var userId in userIds) {
      final docRef = _eventsRef.doc(eventId).collection('registrations').doc(userId);
      batch.update(docRef, {
        'isCheckedIn': true,
        'checkInTime': Timestamp.now(),
      });
    }
    await batch.commit();
  }
}
