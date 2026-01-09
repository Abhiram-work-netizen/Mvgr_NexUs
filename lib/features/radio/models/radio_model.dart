import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';

/// Radio session for live radio integration
class RadioSession {
  final String id;
  final String djId;
  final String djName;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isLive;
  final String? currentSong;
  final String? sessionTheme;  // "Evening Chill", "Retro Hour", etc.

  RadioSession({
    required this.id,
    required this.djId,
    required this.djName,
    required this.startTime,
    this.endTime,
    this.isLive = false,
    this.currentSong,
    this.sessionTheme,
  });

  factory RadioSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RadioSession(
      id: doc.id,
      djId: data['djId'] ?? '',
      djName: data['djName'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      isLive: data['isLive'] ?? false,
      currentSong: data['currentSong'],
      sessionTheme: data['sessionTheme'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'djId': djId,
      'djName': djName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'isLive': isLive,
      'currentSong': currentSong,
      'sessionTheme': sessionTheme,
    };
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}

/// Song request/vote for radio
class SongVote {
  final String id;
  final String sessionId;
  final String songName;
  final String? artistName;
  final String requesterId;
  final String requesterName;
  final int voteCount;
  final List<String> voterIds;
  final bool isPlayed;
  final bool isApproved;
  final DateTime requestedAt;
  final DateTime? playedAt;

  SongVote({
    required this.id,
    required this.sessionId,
    required this.songName,
    this.artistName,
    required this.requesterId,
    required this.requesterName,
    this.voteCount = 0,
    this.voterIds = const [],
    this.isPlayed = false,
    this.isApproved = true,
    required this.requestedAt,
    this.playedAt,
  });

  factory SongVote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SongVote(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      songName: data['songName'] ?? '',
      artistName: data['artistName'],
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      voteCount: data['voteCount'] ?? 0,
      voterIds: List<String>.from(data['voterIds'] ?? []),
      isPlayed: data['isPlayed'] ?? false,
      isApproved: data['isApproved'] ?? true,
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      playedAt: (data['playedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'songName': songName,
      'artistName': artistName,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'voteCount': voteCount,
      'voterIds': voterIds,
      'isPlayed': isPlayed,
      'isApproved': isApproved,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'playedAt': playedAt != null ? Timestamp.fromDate(playedAt!) : null,
    };
  }

  bool hasVoted(String userId) => voterIds.contains(userId);
  String get displayName => artistName != null ? '$songName - $artistName' : songName;
}

/// Shoutout for radio
class Shoutout {
  final String id;
  final String? sessionId;
  final String authorId;
  final String authorName;
  final String message;
  final String? dedicatedTo;  // Optional dedication
  final bool isAnonymous;
  final ModerationStatus status;
  final DateTime createdAt;
  final bool isRead;  // Read on air

  Shoutout({
    required this.id,
    this.sessionId,
    required this.authorId,
    required this.authorName,
    required this.message,
    this.dedicatedTo,
    this.isAnonymous = false,
    this.status = ModerationStatus.pending,
    required this.createdAt,
    this.isRead = false,
  });

  factory Shoutout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shoutout(
      id: doc.id,
      sessionId: data['sessionId'],
      authorId: data['authorId'] ?? '',
      authorName: data['isAnonymous'] == true ? 'Anonymous' : (data['authorName'] ?? ''),
      message: data['message'] ?? '',
      dedicatedTo: data['dedicatedTo'],
      isAnonymous: data['isAnonymous'] ?? false,
      status: ModerationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ModerationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'authorId': authorId,
      'authorName': authorName,
      'message': message,
      'dedicatedTo': dedicatedTo,
      'isAnonymous': isAnonymous,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  String get displayAuthor => isAnonymous ? 'Anonymous' : authorName;
}

/// Interview question for radio segment
class InterviewQuestion {
  final String id;
  final String authorId;
  final String authorName;
  final String question;
  final String? targetPerson;  // "Principal", "HOD", guest name, etc.
  final bool isAnonymous;
  final ModerationStatus status;
  final DateTime createdAt;
  final bool isAnswered;
  final String? answer;

  InterviewQuestion({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.question,
    this.targetPerson,
    this.isAnonymous = false,
    this.status = ModerationStatus.pending,
    required this.createdAt,
    this.isAnswered = false,
    this.answer,
  });

  factory InterviewQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InterviewQuestion(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['isAnonymous'] == true ? 'Anonymous' : (data['authorName'] ?? ''),
      question: data['question'] ?? '',
      targetPerson: data['targetPerson'],
      isAnonymous: data['isAnonymous'] ?? false,
      status: ModerationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ModerationStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAnswered: data['isAnswered'] ?? false,
      answer: data['answer'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'question': question,
      'targetPerson': targetPerson,
      'isAnonymous': isAnonymous,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAnswered': isAnswered,
      'answer': answer,
    };
  }
}
