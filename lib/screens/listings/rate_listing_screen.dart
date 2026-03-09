import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reviews_provider.dart';
import '../../utils/theme.dart';

/// Screen where the user selects a star rating and writes a review comment.
class RateListingScreen extends StatefulWidget {
  final ListingModel listing;

  const RateListingScreen({super.key, required this.listing});

  @override
  State<RateListingScreen> createState() => _RateListingScreenState();
}

class _RateListingScreenState extends State<RateListingScreen> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = true;
  ReviewModel? _existingReview;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reviewsProvider =
        Provider.of<ReviewsProvider>(context, listen: false);

    if (authProvider.user != null && widget.listing.id != null) {
      try {
        final existing = await reviewsProvider.getUserReview(
          widget.listing.id!,
          authProvider.user!.uid,
        );
        if (mounted) {
          setState(() {
            _existingReview = existing;
            if (existing != null) {
              _selectedRating = existing.rating;
              _commentController.text = existing.comment;
            }
            _isLoading = false;
          });
        }
      } catch (_) {
        // If the pre-fetch fails (e.g. index not ready), continue with a blank form
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reviewsProvider =
        Provider.of<ReviewsProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final displayName =
        authProvider.user!.displayName ?? authProvider.user!.email ?? 'User';

    final success = await reviewsProvider.submitReview(
      listing: widget.listing,
      rating: _selectedRating,
      comment: _commentController.text.trim(),
      userId: authProvider.user!.uid,
      displayName: displayName,
      existingReview: _existingReview, // pass pre-fetched review — avoids extra Firestore read
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted!'),
          backgroundColor: AppTheme.accentGold,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reviewsProvider.errorMessage ?? 'Failed to submit review',
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Rate ${widget.listing.name}',
          style: const TextStyle(color: AppTheme.textWhite),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentGold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Edit mode notice
                  if (_existingReview != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentGold.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.edit,
                              color: AppTheme.accentGold, size: 16),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Editing your existing review',
                              style: TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Listing name header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: AppTheme.accentGold),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.listing.name,
                                style: const TextStyle(
                                  color: AppTheme.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.listing.category,
                                style: const TextStyle(
                                  color: AppTheme.textGray,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Star rating label
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _ratingLabel(_selectedRating),
                    style: const TextStyle(
                        color: AppTheme.textGray, fontSize: 14),
                  ),
                  const SizedBox(height: 16),

                  // Star row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final filled = i < _selectedRating;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRating = i + 1),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: AppTheme.accentGold,
                            size: 44,
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // Comment field
                  const Text(
                    'Share Your Experience',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Optional — up to 300 characters',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    maxLength: 300,
                    style: const TextStyle(color: AppTheme.textWhite),
                    decoration: InputDecoration(
                      hintText:
                          'What did you like or dislike about this place?',
                      hintStyle:
                          TextStyle(color: AppTheme.textGray.withOpacity(0.6)),
                      filled: true,
                      fillColor: AppTheme.secondaryDark,
                      counterStyle:
                          const TextStyle(color: AppTheme.textGray),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  Consumer<ReviewsProvider>(
                    builder: (context, reviewsProvider, _) {
                      return SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: reviewsProvider.isSubmitting
                              ? null
                              : _submitReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentGold,
                            foregroundColor: AppTheme.primaryDark,
                            disabledBackgroundColor:
                                AppTheme.accentGold.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: reviewsProvider.isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppTheme.primaryDark,
                                  ),
                                )
                              : Text(
                                  _existingReview != null
                                      ? 'Update Review'
                                      : 'Submit Review',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap a star to rate';
    }
  }
}
