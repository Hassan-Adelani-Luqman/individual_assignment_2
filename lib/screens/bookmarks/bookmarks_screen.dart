import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/listing_card.dart';
import '../listings/listing_detail_screen.dart';

/// Screen displaying all bookmarked listings for the current user.
///
/// Shows a toggle switch at the top to sort listings A–Z, and a list of
/// saved places. Displays an empty state when no bookmarks exist.
class BookmarksScreen extends StatefulWidget {
  final VoidCallback? onBrowseDirectory;

  const BookmarksScreen({super.key, this.onBrowseDirectory});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  bool _sortAlphabetically = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: const Text(
          'Bookmarks',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer3<BookmarksProvider, ListingsProvider, AuthProvider>(
        builder:
            (context, bookmarksProvider, listingsProvider, authProvider, _) {
              if (bookmarksProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                );
              }

              var bookmarkedListings = bookmarksProvider
                  .getBookmarkedListings(listingsProvider.allListings);

              if (_sortAlphabetically) {
                bookmarkedListings = List.from(bookmarkedListings)
                  ..sort((a, b) => a.name.compareTo(b.name));
              }

              return Column(
                children: [
                  // Header with sort toggle
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _sortAlphabetically ? 'Sort: A–Z' : 'Sort: Recent',
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Toggle to switch sort order
                        Switch(
                          value: _sortAlphabetically,
                          onChanged: (val) =>
                              setState(() => _sortAlphabetically = val),
                          activeColor: AppTheme.accentGold,
                          activeTrackColor: AppTheme.accentGold.withOpacity(
                            0.3,
                          ),
                          inactiveThumbColor: AppTheme.textGray,
                          inactiveTrackColor: AppTheme.textGray.withOpacity(
                            0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bookmarks list or empty state
                  Expanded(
                    child: bookmarkedListings.isEmpty
                        ? _buildEmptyState(context)
                        : _buildBookmarksList(
                            context,
                            bookmarkedListings,
                            bookmarksProvider,
                            listingsProvider,
                            authProvider,
                          ),
                  ),
                ],
              );
            },
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
              Icons.bookmark_border,
              size: 80,
              color: AppTheme.textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'No saved places yet',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tap the bookmark icon on any listing to save it here for quick access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textGray,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: widget.onBrowseDirectory,
              icon: const Icon(Icons.explore),
              label: const Text('Browse Directory'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.primaryDark,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList(
    BuildContext context,
    List bookmarkedListings,
    BookmarksProvider bookmarksProvider,
    ListingsProvider listingsProvider,
    AuthProvider authProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookmarkedListings.length,
      itemBuilder: (context, index) {
        final listing = bookmarkedListings[index];
        return ListingCard(
          listing: listing,
          distanceMeters: listingsProvider.distanceTo(listing),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListingDetailScreen(listing: listing),
              ),
            );
          },
        );
      },
    );
  }
}
