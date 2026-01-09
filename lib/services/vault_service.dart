import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/vault/models/vault_model.dart';
import 'moderation_service.dart';

class VaultService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ModerationService _moderationService = ModerationService.instance;

  static final VaultService instance = VaultService._init();
  VaultService._init();

  CollectionReference get _vaultRef => _firestore.collection('vault_resources');

  /// Create a new vault item (resource)
  Future<void> createVaultItem(VaultItem item) async {
    await _moderationService.validateContent('${item.title} ${item.description}');
    
    final docRef = _vaultRef.doc();
    final newItem = item.copyWith(id: docRef.id, isApproved: true);
    await docRef.set(newItem.toFirestore());
  }

  /// Get all vault items with optional filters
  Stream<List<VaultItem>> getVaultItemsStream({
    String? branch,
    int? year,
    String? subject,
    VaultItemType? type,
  }) {
    Query query = _vaultRef.orderBy('createdAt', descending: true);

    if (branch != null) query = query.where('branch', isEqualTo: branch);
    if (year != null) query = query.where('year', isEqualTo: year);
    if (type != null) query = query.where('type', isEqualTo: type.name);

    return query.snapshots().map((snapshot) {
      final items = snapshot.docs.map((doc) => VaultItem.fromFirestore(doc)).toList();
      // Client-side filtering for partial matches like Subject
      if (subject != null && subject.isNotEmpty) {
        return items.where((i) => i.subject.toLowerCase().contains(subject.toLowerCase())).toList();
      }
      return items;
    });
  }

  /// Get resources uploaded by a specific user
  Stream<List<VaultItem>> getUserUploadsStream(String userId) {
    return _vaultRef
        .where('uploaderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => VaultItem.fromFirestore(doc)).toList());
  }

  /// Get a single vault item by ID
  Future<VaultItem?> getVaultItem(String itemId) async {
    final doc = await _vaultRef.doc(itemId).get();
    if (!doc.exists) return null;
    return VaultItem.fromFirestore(doc);
  }

  /// Increment download count when someone downloads/opens a resource
  Future<void> incrementDownloadCount(String itemId) async {
    await _vaultRef.doc(itemId).update({
      'downloadCount': FieldValue.increment(1),
    });
  }

  /// Rate a resource (simple implementation - updates average)
  Future<void> rateResource(String itemId, double newRating) async {
    final doc = await _vaultRef.doc(itemId).get();
    if (!doc.exists) return;
    
    final data = doc.data() as Map<String, dynamic>;
    final currentRating = (data['rating'] ?? 0.0).toDouble();
    final ratingCount = (data['ratingCount'] ?? 0) + 1;
    
    // Calculate new average rating
    final avgRating = ((currentRating * (ratingCount - 1)) + newRating) / ratingCount;
    
    await _vaultRef.doc(itemId).update({
      'rating': avgRating,
      'ratingCount': ratingCount,
    });
  }

  /// Delete a vault item (only by uploader)
  Future<void> deleteVaultItem(String itemId, String userId) async {
    final doc = await _vaultRef.doc(itemId).get();
    if (!doc.exists) {
      throw Exception('Resource not found');
    }
    
    final item = VaultItem.fromFirestore(doc);
    if (item.uploaderId != userId) {
      throw Exception('You can only delete your own resources');
    }
    
    await _vaultRef.doc(itemId).delete();
  }

  /// Update a vault item
  Future<void> updateVaultItem(VaultItem item) async {
    await _moderationService.validateContent('${item.title} ${item.description}');
    await _vaultRef.doc(item.id).update(item.toFirestore());
  }

  /// Search resources by title or subject
  Stream<List<VaultItem>> searchResources(String query) {
    // Firestore doesn't support full-text search natively
    // This fetches all and filters client-side (okay for smaller datasets)
    // For production, consider Algolia or Typesense
    return _vaultRef
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs.map((doc) => VaultItem.fromFirestore(doc)).toList();
          final lowerQuery = query.toLowerCase();
          return items.where((item) =>
              item.title.toLowerCase().contains(lowerQuery) ||
              item.subject.toLowerCase().contains(lowerQuery) ||
              item.description.toLowerCase().contains(lowerQuery) ||
              item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))
          ).toList();
        });
  }
}
