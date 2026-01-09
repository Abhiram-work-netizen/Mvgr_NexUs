import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of a club join request
enum ClubJoinStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get displayName {
    switch (this) {
      case ClubJoinStatus.pending:
        return 'Pending';
      case ClubJoinStatus.approved:
        return 'Approved';
      case ClubJoinStatus.rejected:
        return 'Rejected';
      case ClubJoinStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Represents a request to join a club
class ClubJoinRequest {
  final String id;
  final String userId;
  final String userName;
  final String clubId;
  final String clubName;
  final ClubJoinStatus status;
  final DateTime requestedAt;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? note;
  final String? rejectionReason;

  const ClubJoinRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.clubId,
    required this.clubName,
    this.status = ClubJoinStatus.pending,
    required this.requestedAt,
    this.resolvedAt,
    this.resolvedBy,
    this.note,
    this.rejectionReason,
  });

  bool get isPending => status == ClubJoinStatus.pending;
  bool get isApproved => status == ClubJoinStatus.approved;
  bool get isRejected => status == ClubJoinStatus.rejected;

  ClubJoinRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? clubId,
    String? clubName,
    ClubJoinStatus? status,
    DateTime? requestedAt,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? note,
    String? rejectionReason,
  }) {
    return ClubJoinRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      note: note ?? this.note,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'clubId': clubId,
      'clubName': clubName,
      'status': status.name,
      'requestedAt': Timestamp.fromDate(requestedAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolvedBy': resolvedBy,
      'note': note,
      'rejectionReason': rejectionReason,
    };
  }

  factory ClubJoinRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubJoinRequest(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      clubId: data['clubId'] ?? '',
      clubName: data['clubName'] ?? '',
      status: ClubJoinStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ClubJoinStatus.pending,
      ),
      requestedAt: (data['requestedAt'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      resolvedBy: data['resolvedBy'],
      note: data['note'],
      rejectionReason: data['rejectionReason'],
    );
  }
}
