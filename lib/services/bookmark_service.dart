import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

/// Service class for managing user bookmarks in Firestore.
///
/// Uses compound document IDs (userId_listingId) for efficient
/// toggle operations without requiring queries.
class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a unique document ID for a bookmark
  String _docId(String userId, String listingId) => '${userId}_$listingId';

  /// Toggles bookmark status for a listing.
  /// If bookmarked, removes it. If not bookmarked, adds it.
  Future<void> toggleBookmark(String userId, String listingId) async {
    final ref = _firestore
        .collection(AppConstants.bookmarksCollection)
        .doc(_docId(userId, listingId));

    final doc = await ref.get();
    if (doc.exists) {
      // Remove bookmark
      await ref.delete();
    } else {
      // Add bookmark
      await ref.set({
        'userId': userId,
        'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Adds a bookmark for a listing
  Future<void> addBookmark(String userId, String listingId) async {
    final ref = _firestore
        .collection(AppConstants.bookmarksCollection)
        .doc(_docId(userId, listingId));

    await ref.set({
      'userId': userId,
      'listingId': listingId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes a bookmark for a listing
  Future<void> removeBookmark(String userId, String listingId) async {
    await _firestore
        .collection(AppConstants.bookmarksCollection)
        .doc(_docId(userId, listingId))
        .delete();
  }

  /// Checks if a listing is bookmarked by the user
  Future<bool> isBookmarked(String userId, String listingId) async {
    final doc = await _firestore
        .collection(AppConstants.bookmarksCollection)
        .doc(_docId(userId, listingId))
        .get();
    return doc.exists;
  }

  /// Returns a real-time stream of all bookmarked listing IDs for a user
  Stream<Set<String>> getBookmarkedIdsStream(String userId) {
    return _firestore
        .collection(AppConstants.bookmarksCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['listingId'] as String).toSet(),
        );
  }

  /// Gets all bookmark documents for a user (one-time fetch)
  Future<List<String>> getBookmarkedIds(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.bookmarksCollection)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => doc['listingId'] as String).toList();
  }
}
