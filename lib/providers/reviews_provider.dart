import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

enum ReviewsState { idle, loading, submitting, loaded, error }

class ReviewsProvider with ChangeNotifier {
  final ReviewService _service = ReviewService();

  List<ReviewModel> _reviews = [];
  ReviewsState _state = ReviewsState.idle;
  String? _errorMessage;
  StreamSubscription<List<ReviewModel>>? _subscription;
  // Separate flag so stream updates don't override submitting state
  bool _isSubmitting = false;

  List<ReviewModel> get reviews => _reviews;
  ReviewsState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ReviewsState.loading;
  bool get isSubmitting => _isSubmitting;

  double get averageRating {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.map((r) => r.rating).reduce((a, b) => a + b);
    return sum / _reviews.length;
  }

  /// Start listening to reviews for [listingId].
  void listenToReviews(String listingId) {
    _state = ReviewsState.loading;
    _reviews = [];
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.getReviewsStream(listingId).listen(
      (reviews) {
        _reviews = reviews;
        _state = ReviewsState.loaded;
        notifyListeners();
      },
      onError: (e) {
        _state = ReviewsState.error;
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  /// Stop listening (call when navigating away from reviews).
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _reviews = [];
    _state = ReviewsState.idle;
    _isSubmitting = false;
  }

  /// Submit a new review. Pass [existingReview] if the user already has one
  /// (pre-fetched by the screen) to avoid an extra Firestore read here.
  Future<bool> submitReview({
    required ListingModel listing,
    required int rating,
    required String comment,
    required String userId,
    required String displayName,
    ReviewModel? existingReview,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (existingReview != null) {
        await _service.updateReview(existingReview.copyWith(
          rating: rating,
          comment: comment,
        ));
      } else {
        final review = ReviewModel(
          listingId: listing.id!,
          userId: userId,
          displayName: displayName,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        );
        await _service.addReview(review);
      }

      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch the current user's existing review for a listing (for pre-filling form).
  Future<ReviewModel?> getUserReview(String listingId, String userId) {
    return _service.getUserReview(listingId, userId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
