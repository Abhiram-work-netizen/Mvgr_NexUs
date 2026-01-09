import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../features/lost_found/models/lost_found_model.dart';

class LostFoundService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static final LostFoundService instance = LostFoundService._init();
  LostFoundService._init();

  CollectionReference get _itemsRef => _firestore.collection('lost_found');
  CollectionReference get _claimsRef => _firestore.collection('lost_found_claims');

  /// Get stream of items filtered by status
  Stream<List<LostFoundItem>> getItemsStream({required LostFoundStatus status}) {
    return _itemsRef
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostFoundItem.fromFirestore(doc))
            .toList());
  }

  /// Get stream of all items (for search)
  Stream<List<LostFoundItem>> getAllItemsStream() {
    return _itemsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LostFoundItem.fromFirestore(doc))
            .toList());
  }

  /// Report a lost or found item
  Future<void> reportItem(LostFoundItem item, {File? imageFile, Uint8List? imageBytes, String? fileName}) async {
    String? imageUrl;
    
    // Upload image if provided
    if (imageFile != null || imageBytes != null) {
      final ref = _storage.ref().child('lost_found/${DateTime.now().millisecondsSinceEpoch}_${fileName ?? 'image.jpg'}');
      
      if (imageFile != null) {
        await ref.putFile(imageFile);
      } else if (imageBytes != null) {
        await ref.putData(imageBytes);
      }
      
      imageUrl = await ref.getDownloadURL();
    }

    // Create item with image URL
    final docRef = _itemsRef.doc();
    final newItem = item.copyWith(
      id: docRef.id,
      imageUrl: imageUrl,
    );

    await docRef.set(newItem.toFirestore());
  }

  /// Delete an item
  Future<void> deleteItem(String itemId) async {
    await _itemsRef.doc(itemId).delete();
  }

  /// Submit a claim request
  Future<void> submitClaim(ClaimRequest request) async {
    final docRef = _claimsRef.doc();
    // Assuming ID is generated here if empty in request
    // But ClaimRequest constructor takes ID
    final newRequest = ClaimRequest(
      id: docRef.id,
      itemId: request.itemId,
      claimerId: request.claimerId,
      claimerName: request.claimerName,
      message: request.message,
      status: request.status,
      createdAt: request.createdAt
    );
    await docRef.set(newRequest.toFirestore());
  }
}
