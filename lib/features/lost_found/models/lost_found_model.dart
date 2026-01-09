import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Status of lost/found item
enum LostFoundStatus {
  lost,
  found,
  claimed,
  expired;
  
  String get displayName {
    switch (this) {
      case LostFoundStatus.lost:
        return 'Lost';
      case LostFoundStatus.found:
        return 'Found';
      case LostFoundStatus.claimed:
        return 'Claimed';
      case LostFoundStatus.expired:
        return 'Expired';
    }
  }
  
  String get icon {
    switch (this) {
      case LostFoundStatus.lost:
        return '🔍';
      case LostFoundStatus.found:
        return '📦';
      case LostFoundStatus.claimed:
        return '✅';
      case LostFoundStatus.expired:
        return '⏰';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case LostFoundStatus.lost:
        return Icons.search_rounded;
      case LostFoundStatus.found:
        return Icons.inventory_2_rounded;
      case LostFoundStatus.claimed:
        return Icons.check_circle_rounded;
      case LostFoundStatus.expired:
        return Icons.timer_off_rounded;
    }
  }
}

/// Category of lost/found item
enum LostFoundCategory {
  electronics,
  documents,
  accessories,
  clothing,
  stationery,
  keys,
  wallet,
  bag,
  other;
  
  String get displayName {
    switch (this) {
      case LostFoundCategory.electronics:
        return 'Electronics';
      case LostFoundCategory.documents:
        return 'Documents';
      case LostFoundCategory.accessories:
        return 'Accessories';
      case LostFoundCategory.clothing:
        return 'Clothing';
      case LostFoundCategory.stationery:
        return 'Stationery';
      case LostFoundCategory.keys:
        return 'Keys';
      case LostFoundCategory.wallet:
        return 'Wallet/Purse';
      case LostFoundCategory.bag:
        return 'Bag/Backpack';
      case LostFoundCategory.other:
        return 'Other';
    }
  }
  
  String get icon {
    switch (this) {
      case LostFoundCategory.electronics:
        return '📱';
      case LostFoundCategory.documents:
        return '📄';
      case LostFoundCategory.accessories:
        return '👓';
      case LostFoundCategory.clothing:
        return '👕';
      case LostFoundCategory.stationery:
        return '✏️';
      case LostFoundCategory.keys:
        return '🔑';
      case LostFoundCategory.wallet:
        return '👛';
      case LostFoundCategory.bag:
        return '🎒';
      case LostFoundCategory.other:
        return '📦';
    }
  }
  
  /// Material icon for premium UI
  IconData get iconData {
    switch (this) {
      case LostFoundCategory.electronics:
        return Icons.smartphone_rounded;
      case LostFoundCategory.documents:
        return Icons.description_rounded;
      case LostFoundCategory.accessories:
        return Icons.watch_rounded;
      case LostFoundCategory.clothing:
        return Icons.checkroom_rounded;
      case LostFoundCategory.stationery:
        return Icons.edit_rounded;
      case LostFoundCategory.keys:
        return Icons.key_rounded;
      case LostFoundCategory.wallet:
        return Icons.wallet_rounded;
      case LostFoundCategory.bag:
        return Icons.backpack_rounded;
      case LostFoundCategory.other:
        return Icons.inventory_rounded;
    }
  }
}

/// Lost & Found item
class LostFoundItem {
  final String id;
  final String userId;
  final String userName;  // Display name only
  final LostFoundStatus status;
  final LostFoundCategory category;
  final String title;
  final String description;
  final String? imageUrl;
  final String location;  // Where lost/found
  final DateTime itemDate;  // When lost/found
  final DateTime createdAt;
  final DateTime expiresAt;  // Auto-expiry (30 days)
  final String? claimerId;  // If claimed
  final String? claimerName;
  final bool isContactRevealed;  // Only after match
  final String? contactInfo;  // Revealed after verification

  LostFoundItem({
    required this.id,
    required this.userId,
    required this.userName,
    required this.status,
    required this.category,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.itemDate,
    required this.createdAt,
    required this.expiresAt,
    this.claimerId,
    this.claimerName,
    this.isContactRevealed = false,
    this.contactInfo,
  });

  factory LostFoundItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LostFoundItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      status: LostFoundStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => LostFoundStatus.lost,
      ),
      category: LostFoundCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => LostFoundCategory.other,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      location: data['location'] ?? '',
      itemDate: (data['itemDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? 
          DateTime.now().add(const Duration(days: 30)),
      claimerId: data['claimerId'],
      claimerName: data['claimerName'],
      isContactRevealed: data['isContactRevealed'] ?? false,
      contactInfo: data['contactInfo'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'status': status.name,
      'category': category.name,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'itemDate': Timestamp.fromDate(itemDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'claimerId': claimerId,
      'claimerName': claimerName,
      'isContactRevealed': isContactRevealed,
      'contactInfo': contactInfo,
    };
  }

  LostFoundItem copyWith({
    String? id,
    String? userId,
    String? userName,
    LostFoundStatus? status,
    LostFoundCategory? category,
    String? title,
    String? description,
    String? imageUrl,
    String? location,
    DateTime? itemDate,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? claimerId,
    String? claimerName,
    bool? isContactRevealed,
    String? contactInfo,
  }) {
    return LostFoundItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      location: location ?? this.location,
      itemDate: itemDate ?? this.itemDate,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      claimerId: claimerId ?? this.claimerId,
      claimerName: claimerName ?? this.claimerName,
      isContactRevealed: isContactRevealed ?? this.isContactRevealed,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired && status != LostFoundStatus.claimed;
  int get daysUntilExpiry => expiresAt.difference(DateTime.now()).inDays;
  bool isOwnedBy(String uid) => userId == uid;

  /// Test items
  static List<LostFoundItem> get testItems => [
    LostFoundItem(
      id: 'lf_001',
      userId: 'test_student_001',
      userName: 'Test Student',
      status: LostFoundStatus.lost,
      category: LostFoundCategory.electronics,
      title: 'Black earbuds in case',
      description: 'Lost my Sony WF-1000XM4 earbuds near the library. Black case with silver logo.',
      location: 'Central Library, 2nd Floor',
      itemDate: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      expiresAt: DateTime.now().add(const Duration(days: 28)),
    ),
    LostFoundItem(
      id: 'lf_002',
      userId: 'user_002',
      userName: 'Jane Doe',
      status: LostFoundStatus.found,
      category: LostFoundCategory.documents,
      title: 'ID Card found at Canteen',
      description: 'Found a student ID card. Contact to claim with your roll number.',
      location: 'Main Canteen',
      itemDate: DateTime.now().subtract(const Duration(hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    ),
  ];
}

/// Claim request for a lost/found item
class ClaimRequest {
  final String id;
  final String itemId;
  final String claimerId;
  final String claimerName;
  final String message;  // Description to verify ownership
  final ClaimStatus status;
  final DateTime createdAt;

  ClaimRequest({
    required this.id,
    required this.itemId,
    required this.claimerId,
    required this.claimerName,
    required this.message,
    this.status = ClaimStatus.pending,
    required this.createdAt,
  });

  factory ClaimRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClaimRequest(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      claimerId: data['claimerId'] ?? '',
      claimerName: data['claimerName'] ?? '',
      message: data['message'] ?? '',
      status: ClaimStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ClaimStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'claimerId': claimerId,
      'claimerName': claimerName,
      'message': message,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum ClaimStatus {
  pending,
  approved,
  rejected;
}
