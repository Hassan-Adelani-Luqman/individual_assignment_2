import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../widgets/listing_card.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/create_listing_screen.dart';
import 'map_view_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kigali City',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppTheme.textWhite),
            tooltip: 'Map View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapViewScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.accentGold),
            tooltip: 'Add Listing',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateListingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                Provider.of<ListingsProvider>(
                  context,
                  listen: false,
                ).updateSearchQuery(value);
              },
              style: const TextStyle(color: AppTheme.textWhite),
              decoration: InputDecoration(
                hintText: 'Search for a service',
                hintStyle: const TextStyle(color: AppTheme.textGray),
                filled: true,
                fillColor: AppTheme.secondaryDark,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.accentGold,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textGray),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ListingsProvider>(
                            context,
                            listen: false,
                          ).updateSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category chips
          Consumer<ListingsProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: provider.selectedCategory == null,
                        onSelected: (selected) {
                          provider.updateSelectedCategory(null);
                        },
                        selectedColor: AppTheme.accentGold,
                        backgroundColor: AppTheme.secondaryDark,
                        labelStyle: TextStyle(
                          color: provider.selectedCategory == null
                              ? AppTheme.primaryDark
                              : AppTheme.textWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...AppConstants.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: provider.selectedCategory == category,
                          onSelected: (selected) {
                            provider.updateSelectedCategory(
                              selected ? category : null,
                            );
                          },
                          selectedColor: AppTheme.accentGold,
                          backgroundColor: AppTheme.secondaryDark,
                          labelStyle: TextStyle(
                            color: provider.selectedCategory == category
                                ? AppTheme.primaryDark
                                : AppTheme.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Listings list
          Expanded(
            child: Consumer<ListingsProvider>(
              builder: (context, provider, _) {
                if (provider.state == ListingsState.loading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accentGold,
                    ),
                  );
                }

                if (provider.state == ListingsState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.errorMessage ?? 'An error occurred',
                          style: const TextStyle(color: AppTheme.textWhite),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredListings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textGray,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No listings found',
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.filteredListings.length,
                  itemBuilder: (context, index) {
                    final listing = provider.filteredListings[index];
                    return ListingCard(
                      listing: listing,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListingDetailScreen(listing: listing),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
