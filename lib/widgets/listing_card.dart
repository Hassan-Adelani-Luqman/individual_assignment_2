import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/listing_model.dart';
import '../providers/auth_provider.dart';
import '../providers/bookmarks_provider.dart';
import '../utils/theme.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;
  final double? distanceMeters;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.distanceMeters,
  });

  String _formatDistance(double meters) {
    final km = meters / 1000;
    return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.secondaryDark,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Category with Bookmark
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      listing.name,
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.category,
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Bookmark icon
                      Consumer2<BookmarksProvider, AuthProvider>(
                        builder: (context, bookmarksProvider, authProvider, _) {
                          final isBookmarked = bookmarksProvider.isBookmarked(
                            listing.id ?? '',
                          );
                          return GestureDetector(
                            onTap: () async {
                              if (authProvider.user != null &&
                                  listing.id != null) {
                                try {
                                  await bookmarksProvider.toggle(
                                    authProvider.user!.uid,
                                    listing.id!,
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Could not save bookmark: $e',
                                        ),
                                        backgroundColor: Colors.red[700],
                                        duration: const Duration(seconds: 4),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: AppTheme.accentGold,
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Address + distance
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.accentGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.address,
                      style: const TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (distanceMeters != null) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.near_me,
                      size: 13,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _formatDistance(distanceMeters!),
                      style: const TextStyle(
                        color: AppTheme.accentGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                listing.description,
                style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Contact Number
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    color: AppTheme.accentGold,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    listing.contactNumber,
                    style: const TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  // Rating (if available)
                  if (listing.rating != null && listing.rating! > 0)
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.accentGold,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          listing.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
