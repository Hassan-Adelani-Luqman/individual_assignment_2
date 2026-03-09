import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/listing_model.dart';
import '../services/bookmark_service.dart';

/// Provider for managing bookmark state across the app.
///
/// Listens to real-time changes in the user's bookmarks and
/// provides methods for toggling bookmarks and checking status.
class BookmarksProvider with ChangeNotifier {
  final BookmarkService _service = BookmarkService();

  Set<String> _bookmarkedIds = {};
  StreamSubscription? _subscription;
  bool _isLoading = false;
  String? _currentUserId;

  /// Set of all bookmarked listing IDs for the current user
  Set<String> get bookmarkedIds => _bookmarkedIds;

  /// Whether the provider is currently loading
  bool get isLoading => _isLoading;

  /// Number of bookmarked listings
  int get bookmarkCount => _bookmarkedIds.length;

  /// Checks if a specific listing is bookmarked
  bool isBookmarked(String listingId) => _bookmarkedIds.contains(listingId);

  /// Initializes the provider for a specific user.
  /// Sets up a real-time listener for bookmark changes.
  void initialize(String userId) {
    if (_currentUserId == userId) return; // Already initialized for this user

    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    // Cancel existing subscription if any
    _subscription?.cancel();

    // Set up real-time listener
    _subscription = _service
        .getBookmarkedIdsStream(userId)
        .listen(
          (ids) {
            _bookmarkedIds = ids;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('BookmarksProvider error: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Toggles the bookmark status for a listing.
  /// Returns the new bookmark status (true if bookmarked, false if removed).
  Future<bool> toggle(String userId, String listingId) async {
    final wasBookmarked = _bookmarkedIds.contains(listingId);

    // Optimistic update
    if (wasBookmarked) {
      _bookmarkedIds.remove(listingId);
    } else {
      _bookmarkedIds.add(listingId);
    }
    notifyListeners();

    try {
      // Pass current state so the service never needs to read Firestore first
      await _service.toggleBookmark(
        userId,
        listingId,
        isCurrentlyBookmarked: wasBookmarked,
      );
      return !wasBookmarked; // Return new status
    } catch (e) {
      // Revert on error
      debugPrint('[BookmarksProvider] toggle error: $e');
      if (wasBookmarked) {
        _bookmarkedIds.add(listingId);
      } else {
        _bookmarkedIds.remove(listingId);
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Adds a bookmark for a listing.
  Future<void> addBookmark(String userId, String listingId) async {
    if (_bookmarkedIds.contains(listingId)) return;

    // Optimistic update
    _bookmarkedIds.add(listingId);
    notifyListeners();

    try {
      await _service.addBookmark(userId, listingId);
    } catch (e) {
      // Revert on error
      _bookmarkedIds.remove(listingId);
      notifyListeners();
      rethrow;
    }
  }

  /// Removes a bookmark for a listing.
  Future<void> removeBookmark(String userId, String listingId) async {
    if (!_bookmarkedIds.contains(listingId)) return;

    // Optimistic update
    _bookmarkedIds.remove(listingId);
    notifyListeners();

    try {
      await _service.removeBookmark(userId, listingId);
    } catch (e) {
      // Revert on error
      _bookmarkedIds.add(listingId);
      notifyListeners();
      rethrow;
    }
  }

  /// Returns a filtered list of only bookmarked listings from a full list.
  List<ListingModel> getBookmarkedListings(List<ListingModel> allListings) {
    return allListings
        .where((listing) => _bookmarkedIds.contains(listing.id))
        .toList();
  }

  /// Clears bookmarks state (call on logout)
  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _bookmarkedIds = {};
    _currentUserId = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
