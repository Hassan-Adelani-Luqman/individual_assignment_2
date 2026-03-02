import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of all listings (real-time updates)
  Stream<List<ListingModel>> getAllListingsStream() {
    return _firestore.collection('listings').snapshots().map((snapshot) {
      var listings = snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
      // Sort in memory to avoid needing index
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    });
  }

  // Stream of user's listings (real-time updates)
  Stream<List<ListingModel>> getUserListingsStream(String userId) {
    return _firestore
        .collection('listings')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          var listings = snapshot.docs
              .map((doc) => ListingModel.fromFirestore(doc))
              .toList();
          // Sort in memory to avoid needing composite index
          listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return listings;
        });
  }

  // Create new listing
  Future<Map<String, dynamic>> createListing(ListingModel listing) async {
    try {
      await _firestore.collection('listings').add(listing.toFirestore());
      return {'success': true, 'message': 'Listing created successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create listing: ${e.toString()}',
      };
    }
  }

  // Update listing
  Future<Map<String, dynamic>> updateListing(ListingModel listing) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .update(listing.toFirestore());
      return {'success': true, 'message': 'Listing updated successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update listing: ${e.toString()}',
      };
    }
  }

  // Delete listing
  Future<Map<String, dynamic>> deleteListing(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).delete();
      return {'success': true, 'message': 'Listing deleted successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete listing: ${e.toString()}',
      };
    }
  }

  // Get single listing
  Future<ListingModel?> getListing(String listingId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('listings')
          .doc(listingId)
          .get();
      if (doc.exists) {
        return ListingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search listings by name
  Future<List<ListingModel>> searchListings(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('listings')
          .orderBy('name')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .get();

      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Filter by category
  Stream<List<ListingModel>> getListingsByCategory(String category) {
    return _firestore
        .collection('listings')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ListingModel.fromFirestore(doc))
              .toList(),
        );
  }
}
