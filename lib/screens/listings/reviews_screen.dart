import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reviews_provider.dart';
import '../../utils/theme.dart';
import 'rate_listing_screen.dart';

/// Full-page reviews list for a single listing.
class ReviewsScreen extends StatefulWidget {
  final ListingModel listing;

  const ReviewsScreen({super.key, required this.listing});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late final ReviewsProvider _reviewsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reviewsProvider = Provider.of<ReviewsProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reviewsProvider.listenToReviews(widget.listing.id!);
    });
  }

  @override
  void dispose() {
    _reviewsProvider.stopListening();
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
        title: const Text(
          'Reviews',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryDark,
        icon: const Icon(Icons.rate_review),
        label: const Text(
          'Write a Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RateListingScreen(listing: widget.listing),
            ),
          );
        },
      ),
      body: Consumer<ReviewsProvider>(
        builder: (context, reviewsProvider, _) {
          if (reviewsProvider.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(color: AppTheme.accentGold),
            );
          }

          final reviews = reviewsProvider.reviews;

          return Column(
            children: [
              // Rating summary header
              _buildRatingSummary(
                  reviewsProvider.averageRating, reviews.length),

              const Divider(color: AppTheme.secondaryDark, height: 1),

              // Reviews list or empty state
              Expanded(
                child: reviews.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                            bottom: 100, top: 8),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: AppTheme.secondaryDark,
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, i) =>
                            _buildReviewCard(reviews[i], context),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingSummary(double avg, int count) {
    return Container(
      color: AppTheme.secondaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            avg > 0 ? 'Av. ${avg.toStringAsFixed(1)} rating' : 'No ratings yet',
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Stars
              ...List.generate(5, (i) {
                IconData icon;
                if (i < avg.floor()) {
                  icon = Icons.star;
                } else if (i < avg && avg - i >= 0.5) {
                  icon = Icons.star_half;
                } else {
                  icon = Icons.star_border;
                }
                return Icon(icon, color: AppTheme.accentGold, size: 24);
              }),
              const SizedBox(width: 10),
              Text(
                '$count ${count == 1 ? 'review' : 'reviews'}',
                style: const TextStyle(
                    color: AppTheme.textGray, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review, BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isOwn = authProvider.user?.uid == review.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviewer name + timestamp
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentGold.withOpacity(0.2),
                child: Text(
                  review.displayName.isNotEmpty
                      ? review.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.displayName,
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (isOwn) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'You',
                              style: TextStyle(
                                  color: AppTheme.accentGold,
                                  fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _relativeTime(review.createdAt),
                      style: const TextStyle(
                          color: AppTheme.textGray, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Star rating badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  review.rating,
                  (_) => const Icon(Icons.star,
                      color: AppTheme.accentGold, size: 14),
                ),
              ),
            ],
          ),
          // Comment
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '"${review.comment}"',
              style: const TextStyle(
                color: AppTheme.textGray,
                fontSize: 14,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 72,
              color: AppTheme.textGray.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reviews yet',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Be the first to rate this place.',
              style: TextStyle(color: AppTheme.textGray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }
}
