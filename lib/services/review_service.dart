import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';
import '../utils/constants.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Adds a new review and recalculates the listing's rating in the background.
  Future<void> addReview(ReviewModel review) async {
    // Write the review document
    await _db
        .collection(AppConstants.reviewsCollection)
        .add(review.toFirestore());

    // Recalculate in background — don't block the caller
    _recalculateRating(review.listingId).catchError((_) {});
  }

  /// Updates an existing review and recalculates the listing's rating in the background.
  Future<void> updateReview(ReviewModel review) async {
    if (review.id == null) throw Exception('review.id must not be null for update');
    await _db
        .collection(AppConstants.reviewsCollection)
        .doc(review.id)
        .update({
      'rating': review.rating,
      'comment': review.comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Recalculate in background — don't block the caller
    _recalculateRating(review.listingId).catchError((_) {});
  }

  Future<void> _recalculateRating(String listingId) async {
    final snap = await _db
        .collection(AppConstants.reviewsCollection)
        .where('listingId', isEqualTo: listingId)
        .get();

    if (snap.docs.isEmpty) {
      await _db
          .collection(AppConstants.listingsCollection)
          .doc(listingId)
          .update({'rating': 0.0, 'reviewCount': 0});
      return;
    }

    final ratings =
        snap.docs.map((d) => (d['rating'] as num).toDouble()).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    await _db
        .collection(AppConstants.listingsCollection)
        .doc(listingId)
        .update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': ratings.length,
    });
  }

  /// Real-time stream of reviews for a listing, sorted newest-first client-side.
  /// Avoids a composite index requirement by not using orderBy in the query.
  Stream<List<ReviewModel>> getReviewsStream(String listingId) {
    return _db
        .collection(AppConstants.reviewsCollection)
        .where('listingId', isEqualTo: listingId)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map(ReviewModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Returns the current user's review for a listing, or null if none.
  /// Fetches by listingId only (single-field index) and filters client-side
  /// to avoid needing a composite index on listingId + userId.
  Future<ReviewModel?> getUserReview(String listingId, String userId) async {
    final snap = await _db
        .collection(AppConstants.reviewsCollection)
        .where('listingId', isEqualTo: listingId)
        .get();

    final matches = snap.docs
        .where((d) => d['userId'] == userId)
        .toList();

    if (matches.isEmpty) return null;
    return ReviewModel.fromFirestore(matches.first);
  }
}
