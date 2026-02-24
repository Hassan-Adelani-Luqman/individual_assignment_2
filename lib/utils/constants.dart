class AppConstants {
  // App Info
  static const String appName = 'Kigali City Services';
  static const String appTagline = 'Services & Places Directory';
  
  // Categories for listings (matching UI design)
  static const List<String> categories = [
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
    'Pharmacy',
    'Bank',
    'School',
    'Hotel',
    'Shopping Mall',
  ];
  
  // Kigali center coordinates (default map center)
  static const double kigaliCenterLat = -1.9441;
  static const double kigaliCenterLng = 30.0619;
  
  // Map zoom levels
  static const double defaultZoom = 13.0;
  static const double detailZoom = 15.0;
  
  // Form validation
  static const int minPasswordLength = 6;
  static const int maxDescriptionLength = 500;
  static const int maxNameLength = 100;
  
  // Firestore collection names
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';
  static const String bookmarksCollection = 'bookmarks';
  
  // SharedPreferences keys
  static const String notificationsPrefKey = 'notifications_enabled';
  
  // Error messages
  static const String networkError = 'Please check your internet connection';
  static const String unexpectedError = 'An unexpected error occurred';
  static const String noListingsFound = 'No listings found';
  
  // Success messages
  static const String listingCreated = 'Listing created successfully';
  static const String listingUpdated = 'Listing updated successfully';
  static const String listingDeleted = 'Listing deleted successfully';
}
