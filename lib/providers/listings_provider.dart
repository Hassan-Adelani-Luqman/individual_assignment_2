import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';

enum ListingsState { loading, loaded, error }

class ListingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ListingModel> _allListings = [];
  List<ListingModel> _filteredListings = [];
  List<ListingModel> _userListings = [];

  ListingsState _state = ListingsState.loading;
  String? _errorMessage;
  bool _isLoading = false;

  String _searchQuery = '';
  String? _selectedCategory;

  Position? _userPosition;

  // Getters
  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get filteredListings => _filteredListings;
  List<ListingModel> get userListings => _userListings;
  ListingsState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for error
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  Position? get userPosition => _userPosition;
  bool get hasLocation => _userPosition != null;

  // Returns distance in metres from user to listing, or null if location unknown
  double? distanceTo(ListingModel listing) {
    if (_userPosition == null) return null;
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      listing.latitude,
      listing.longitude,
    );
  }

  // Request location permission and get current position, then re-sort listings
  Future<void> loadUserLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }
      _userPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      _applyFilters();
      notifyListeners();
    } catch (_) {
      // Location unavailable — listings display without distance
    }
  }

  // Initialize real-time listener for all listings
  void initializeListingsListener() {
    _firestoreService.getAllListingsStream().listen(
      (listings) {
        _allListings = listings;
        _applyFilters();
        _state = ListingsState.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _state = ListingsState.error;
        notifyListeners();
      },
    );
  }

  // Initialize listener for user's listings
  void initializeUserListingsListener(String userId) {
    _firestoreService
        .getUserListingsStream(userId)
        .listen(
          (listings) {
            _userListings = listings;
            notifyListeners();
          },
          onError: (error) {
            _errorMessage = error.toString();
            notifyListeners();
          },
        );
  }

  // Apply search and category filters
  void _applyFilters() {
    _filteredListings = _allListings;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredListings = _filteredListings
          .where(
            (listing) =>
                listing.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                listing.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                listing.address.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredListings = _filteredListings
          .where((listing) => listing.category == _selectedCategory)
          .toList();
    }

    // Sort by distance when user location is available
    if (_userPosition != null) {
      _filteredListings.sort((a, b) =>
          distanceTo(a)!.compareTo(distanceTo(b)!));
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Update selected category
  void updateSelectedCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _applyFilters();
    notifyListeners();
  }

  // Create listing
  Future<void> createListing({
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final listing = ListingModel(
      name: name,
      category: category,
      address: address,
      contactNumber: contactNumber,
      description: description,
      latitude: latitude,
      longitude: longitude,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      imageUrl: imageUrl,
    );

    final result = await _firestoreService.createListing(listing);

    _setLoading(false);

    if (!result['success']) {
      _errorMessage = result['message'];
      notifyListeners();
      throw Exception(result['message']);
    }
  }

  // Update listing
  Future<void> updateListing({
    required String listingId,
    required String name,
    required String category,
    required String address,
    required String contactNumber,
    required String description,
    required double latitude,
    required double longitude,
    String? imageUrl,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    // Find the existing listing to preserve createdBy and createdAt
    final existingListing = _allListings.firstWhere(
      (l) => l.id == listingId,
      orElse: () => _userListings.firstWhere((l) => l.id == listingId),
    );

    final listing = ListingModel(
      id: listingId,
      name: name,
      category: category,
      address: address,
      contactNumber: contactNumber,
      description: description,
      latitude: latitude,
      longitude: longitude,
      createdBy: existingListing.createdBy,
      createdAt: existingListing.createdAt,
      updatedAt: DateTime.now(),
      rating: existingListing.rating,
      imageUrl: imageUrl,
    );

    final result = await _firestoreService.updateListing(listing);

    _setLoading(false);

    if (!result['success']) {
      _errorMessage = result['message'];
      notifyListeners();
      throw Exception(result['message']);
    }
  }

  // Delete listing
  Future<void> deleteListing(String listingId) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _firestoreService.deleteListing(listingId);

    _setLoading(false);

    if (!result['success']) {
      _errorMessage = result['message'];
      notifyListeners();
      throw Exception(result['message']);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
}
