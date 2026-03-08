# Features Implementation Plan

## Overview

Four features visible in the UI mockup are not yet implemented. This document details the full implementation plan for each feature including Firestore structure, new files, modified files, and code patterns.

| # | Feature | New Files | Modified Files | Status |
|---|---------|-----------|----------------|--------|
| 1 | Distance Display ("Near You") | 0 | 3 | Pending |
| 2 | Image Display on Detail Page | 0 | 4 | Pending |
| 3 | Bookmarks | 3 | 5 | Pending |
| 4 | Reviews & Rating System | 5 | 4 | Pending |

---

## Feature 1: Distance Display ("Near You")

### What it does
- Requests user location on the Directory screen
- Calculates distance from user to each listing using `Geolocator.distanceBetween()`
- Displays "X km" on every listing card
- Sorts listings nearest-first when location is available
- Shows "Near You" section heading above the list
- Falls back gracefully if permission is denied

### No new files needed
`geolocator` is already in `pubspec.yaml`. Only existing files are modified.

### Modified Files

#### `lib/providers/listings_provider.dart`
Add `Position? _userPosition`, a `loadUserLocation()` method, and distance sorting inside `_applyFilters()`:

```dart
import 'package:geolocator/geolocator.dart';

Position? _userPosition;
Position? get userPosition => _userPosition;

Future<void> loadUserLocation() async {
  try {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    _userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    _applyFilters(); // re-sort with distance
    notifyListeners();
  } catch (_) {
    // Location unavailable — listings display without distance
  }
}

double? distanceTo(ListingModel listing) {
  if (_userPosition == null) return null;
  return Geolocator.distanceBetween(
    _userPosition!.latitude,
    _userPosition!.longitude,
    listing.latitude,
    listing.longitude,
  );
}

// Inside _applyFilters(), after filtering, add:
if (_userPosition != null) {
  _filteredListings.sort((a, b) =>
    distanceTo(a)!.compareTo(distanceTo(b)!));
}
```

#### `lib/widgets/listing_card.dart`
Add optional `distanceMeters` parameter and a distance row:

```dart
final double? distanceMeters;

// In build(), add distance row below the address row:
if (distanceMeters != null)
  Row(children: [
    const Icon(Icons.near_me, size: 14, color: AppTheme.accentGold),
    const SizedBox(width: 4),
    Text(
      _formatDistance(distanceMeters!),
      style: const TextStyle(color: AppTheme.accentGold, fontSize: 13),
    ),
  ])

String _formatDistance(double meters) {
  final km = meters / 1000;
  return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
}
```

#### `lib/screens/home/directory_screen.dart`
- Call `loadUserLocation()` in `initState`
- Pass `distanceTo(listing)` to each `ListingCard`
- Add "Near You" heading above list when location is available:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<ListingsProvider>(context, listen: false).loadUserLocation();
  });
}

// In the list header area:
if (provider.userPosition != null)
  const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text('Near You',
      style: TextStyle(color: AppTheme.textWhite,
        fontSize: 18, fontWeight: FontWeight.bold)),
  ),

// In itemBuilder:
ListingCard(
  listing: listing,
  distanceMeters: provider.distanceTo(listing),
  onTap: () { ... },
)
```

---

## Feature 2: Image Display on Detail Page

### What it does
- Shows a full-width image at the top of the listing detail page
- Uses `CachedNetworkImage` (already in `pubspec.yaml`)
- Falls back to a styled placeholder with category icon when no image URL
- Adds an optional "Image URL" field to the Create and Edit listing forms

### No new files needed

### Modified Files

#### `lib/screens/listings/listing_detail_screen.dart`
Add image widget at the very top of `SingleChildScrollView`:

```dart
// At top of Column in SingleChildScrollView:
if (listing.imageUrl != null && listing.imageUrl!.isNotEmpty)
  SizedBox(
    height: 220,
    width: double.infinity,
    child: CachedNetworkImage(
      imageUrl: listing.imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppTheme.secondaryDark,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.accentGold),
        ),
      ),
      errorWidget: (context, url, error) => _buildImagePlaceholder(listing.category),
    ),
  )
else
  _buildImagePlaceholder(listing.category),

// Placeholder builder:
Widget _buildImagePlaceholder(String category) {
  return Container(
    height: 220,
    color: AppTheme.secondaryDark,
    child: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.place, size: 64, color: AppTheme.accentGold),
        const SizedBox(height: 8),
        Text(category,
          style: const TextStyle(color: AppTheme.textGray, fontSize: 14)),
      ]),
    ),
  );
}
```

#### `lib/screens/listings/create_listing_screen.dart`
Add optional image URL text field at the bottom of the form:

```dart
TextFormField(
  controller: _imageUrlController,
  style: const TextStyle(color: AppTheme.textWhite),
  decoration: InputDecoration(
    labelText: 'Image URL (optional)',
    hintText: 'https://example.com/image.jpg',
    prefixIcon: const Icon(Icons.image, color: AppTheme.accentGold),
    ...
  ),
  // No validator — field is optional
),
```

Pass `imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim()` to `listingsProvider.createListing()`.

#### `lib/screens/listings/edit_listing_screen.dart`
Same field as above, pre-populated with `listing.imageUrl ?? ''`.

#### `lib/providers/listings_provider.dart`
Add `imageUrl` parameter to `createListing()` and `updateListing()` and pass it to `ListingModel`.

---

## Feature 3: Bookmarks

### What it does
- Users can bookmark/unbookmark any listing with a single tap
- Bookmark icon appears on listing cards (top-right) and on the detail page AppBar
- Filled gold icon = bookmarked; outlined icon = not bookmarked
- New "Bookmarks" tab in the bottom navigation shows all saved listings
- Data persists in Firestore per user

### Firestore Structure

```
bookmarks/{userId}_{listingId}
  - userId:    string   ← owner
  - listingId: string   ← the saved listing
  - createdAt: timestamp
```

**Why compound document ID?** `${userId}_${listingId}` ensures uniqueness without a query. Toggling is a single `set()` or `delete()` call, not a query-then-write.

### New Files

#### `lib/services/bookmark_service.dart`

```dart
class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _docId(String userId, String listingId) => '${userId}_$listingId';

  Future<void> toggleBookmark(String userId, String listingId) async {
    final ref = _firestore
        .collection(AppConstants.bookmarksCollection)
        .doc(_docId(userId, listingId));
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'userId': userId,
        'listingId': listingId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<Set<String>> getBookmarkedIdsStream(String userId) {
    return _firestore
        .collection(AppConstants.bookmarksCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d['listingId'] as String).toSet());
  }
}
```

#### `lib/providers/bookmarks_provider.dart`

```dart
class BookmarksProvider with ChangeNotifier {
  final BookmarkService _service = BookmarkService();
  Set<String> _bookmarkedIds = {};
  StreamSubscription? _subscription;
  bool _isLoading = false;

  Set<String> get bookmarkedIds => _bookmarkedIds;
  bool get isLoading => _isLoading;
  bool isBookmarked(String listingId) => _bookmarkedIds.contains(listingId);

  void initialize(String userId) {
    _subscription?.cancel();
    _subscription = _service.getBookmarkedIdsStream(userId).listen((ids) {
      _bookmarkedIds = ids;
      notifyListeners();
    });
  }

  Future<void> toggle(String userId, String listingId) async {
    await _service.toggleBookmark(userId, listingId);
    // Stream update triggers notifyListeners() automatically
  }

  List<ListingModel> getBookmarkedListings(List<ListingModel> allListings) =>
      allListings.where((l) => _bookmarkedIds.contains(l.id)).toList();

  void clear() {
    _subscription?.cancel();
    _bookmarkedIds = {};
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

#### `lib/screens/bookmarks/bookmarks_screen.dart`

```
- AppBar: "Bookmarks"
- Consumer<BookmarksProvider> + Consumer<ListingsProvider>
- Empty state: icon + "No saved places yet" + "Browse the directory" button
- ListView of ListingCard widgets using bookmarksProvider.getBookmarkedListings(listingsProvider.allListings)
- Each card navigates to ListingDetailScreen on tap
```

### Modified Files

#### `lib/main.dart`
- Add `ChangeNotifierProvider(create: (_) => BookmarksProvider())` to MultiProvider
- In `AuthWrapper`, when state becomes `authenticated`, call `bookmarksProvider.initialize(user.uid)`
- When state becomes `unauthenticated`, call `bookmarksProvider.clear()`

#### `lib/navigation/bottom_navigation.dart`
Add 5th tab between "My Listings" and "Settings":

```dart
// New 5-tab layout:
// 0: Home (Icons.home)
// 1: Map  (Icons.map)
// 2: My Listings (Icons.list)
// 3: Bookmarks (Icons.bookmark)  ← new
// 4: Settings (Icons.settings)

BottomNavigationBarItem(
  icon: Icon(Icons.bookmark_border),
  activeIcon: Icon(Icons.bookmark),
  label: 'Bookmarks',
),
```

#### `lib/widgets/listing_card.dart`
Add bookmark icon button in the top-right corner (alongside category badge):

```dart
// Wrap the category badge in a Row with a bookmark icon:
Consumer<BookmarksProvider>(
  builder: (context, bookmarks, _) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isBookmarked = bookmarks.isBookmarked(listing.id ?? '');
    return IconButton(
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: AppTheme.accentGold,
        size: 20,
      ),
      onPressed: () => bookmarks.toggle(
        authProvider.user!.uid,
        listing.id ?? '',
      ),
    );
  },
),
```

#### `lib/screens/listings/listing_detail_screen.dart`
Add bookmark icon to AppBar `actions`:

```dart
Consumer<BookmarksProvider>(
  builder: (context, bookmarks, _) {
    final isBookmarked = bookmarks.isBookmarked(listing.id ?? '');
    return IconButton(
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: AppTheme.accentGold,
      ),
      onPressed: () => bookmarks.toggle(authProvider.user!.uid, listing.id ?? ''),
    );
  },
),
```

---

## Feature 4: Reviews & Rating System

### What it does
- "Rate this service" gold button on the listing detail page
- Tapping opens a full-screen rate form: 5-star selector + comment field
- One review per user per listing (re-opening shows existing review for editing)
- After submission: listing's `rating` (average) and `reviewCount` updated atomically
- Tapping "X reviews" on detail page opens the full Reviews screen
- Reviews screen shows: average rating header + scrollable list of individual reviews

### Firestore Structure

```
reviews/{reviewId}
  - id:          string     ← Firestore doc ID
  - listingId:   string
  - userId:      string
  - displayName: string     ← denormalized to avoid extra reads on display
  - rating:      int        ← 1 to 5
  - comment:     string
  - createdAt:   timestamp
```

After each review write, the listing document is updated:
```
listings/{listingId}
  - rating:      double   ← recalculated average
  - reviewCount: int      ← total number of reviews
```

### New Files

#### `lib/models/review_model.dart`

```dart
class ReviewModel {
  final String? id;
  final String listingId;
  final String userId;
  final String displayName;
  final int rating;        // 1–5
  final String comment;
  final DateTime createdAt;

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
  ReviewModel copyWith({ ... }) { ... }
}
```

#### `lib/services/review_service.dart`

```dart
class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add review + atomically recalculate listing rating
  Future<void> addReview(ReviewModel review) async {
    final batch = _db.batch();

    // 1. Write the review document
    final reviewRef = _db.collection('reviews').doc();
    batch.set(reviewRef, review.toFirestore());

    // 2. Commit batch then recalculate rating
    await batch.commit();
    await _recalculateRating(review.listingId);
  }

  Future<void> _recalculateRating(String listingId) async {
    final snap = await _db
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .get();
    if (snap.docs.isEmpty) return;
    final ratings = snap.docs.map((d) => (d['rating'] as int).toDouble()).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    await _db.collection('listings').doc(listingId).update({
      'rating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': ratings.length,
    });
  }

  // Real-time stream of reviews for a listing
  Stream<List<ReviewModel>> getReviewsStream(String listingId) {
    return _db
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  // Check if current user already has a review for this listing
  Future<ReviewModel?> getUserReview(String listingId, String userId) async {
    final snap = await _db
        .collection('reviews')
        .where('listingId', isEqualTo: listingId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ReviewModel.fromFirestore(snap.docs.first);
  }
}
```

#### `lib/providers/reviews_provider.dart`

```dart
enum ReviewsState { idle, loading, submitting, loaded, error }

class ReviewsProvider with ChangeNotifier {
  final ReviewService _service = ReviewService();
  List<ReviewModel> _reviews = [];
  ReviewsState _state = ReviewsState.idle;
  String? _errorMessage;
  StreamSubscription? _subscription;

  List<ReviewModel> get reviews => _reviews;
  ReviewsState get state => _state;
  String? get errorMessage => _errorMessage;
  double get averageRating => _reviews.isEmpty ? 0 :
      _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length;

  void listenToReviews(String listingId) {
    _state = ReviewsState.loading;
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

  Future<bool> submitReview({
    required String listingId,
    required int rating,
    required String comment,
    required String userId,
    required String displayName,
  }) async {
    _state = ReviewsState.submitting;
    notifyListeners();
    try {
      final review = ReviewModel(
        listingId: listingId, userId: userId,
        displayName: displayName, rating: rating,
        comment: comment, createdAt: DateTime.now(),
      );
      await _service.addReview(review);
      _state = ReviewsState.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ReviewsState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
```

#### `lib/screens/listings/rate_listing_screen.dart`

```
Screen layout:
- AppBar: "Rate [listing.name]"
- 5 tappable star icons in a Row (gold filled = selected, outlined = unselected)
- TextField: "Share your experience (optional)", max 300 chars
- ElevatedButton: "Submit Review" (gold) — shows CircularProgressIndicator when submitting
- If user already has a review: pre-fills stars and comment (edit mode, replaces old review)
- On success: Navigator.pop() + SnackBar "Review submitted!"
- On error: SnackBar with error message
```

#### `lib/screens/listings/reviews_screen.dart`

```
Screen layout:
- AppBar: "Reviews" — subtitle: listing.name
- Header card:
    - Large rating number (e.g. "4.3")
    - Row of 5 stars (filled/half/empty based on average)
    - Subtitle: "45 reviews"
- Divider
- ListView of review cards:
    - Row: displayName (bold) — Spacer — relative time ("2 days ago")
    - Row of N filled stars
    - Comment text (if not empty)
- Empty state: "No reviews yet. Be the first to rate this place."
- FAB or button: "Write a Review" → navigates to RateListingScreen
```

### Modified Files

#### `lib/screens/listings/listing_detail_screen.dart`
Add below the description section:

```dart
// Reviews summary row (tappable → ReviewsScreen):
if (listing.reviewCount != null && listing.reviewCount! > 0)
  InkWell(
    onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => ReviewsScreen(listing: listing))),
    child: Row(children: [
      ...List.generate(5, (i) => Icon(
        i < listing.rating!.round() ? Icons.star : Icons.star_border,
        color: AppTheme.accentGold, size: 18)),
      const SizedBox(width: 8),
      Text('${listing.reviewCount} reviews',
          style: TextStyle(color: AppTheme.textGray)),
      const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textGray),
    ]),
  ),

// "Rate this service" button:
ElevatedButton(
  onPressed: () => Navigator.push(context,
      MaterialPageRoute(builder: (_) => RateListingScreen(listing: listing))),
  style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.accentGold,
      foregroundColor: AppTheme.primaryDark),
  child: const Text('Rate this service',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
),
```

#### `lib/main.dart`
Add `ChangeNotifierProvider(create: (_) => ReviewsProvider())` to MultiProvider.

#### `lib/utils/constants.dart`
Add: `static const String reviewsCollection = 'reviews';`

#### `README.md`
Add `reviews` collection to the Firestore schema section.

---

## Firestore Security Rules

Apply these in **Firebase Console → Firestore → Rules**:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }

    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }

    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }

    match /bookmarks/{bookmarkId} {
      allow read, write: if request.auth != null
        && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## Implementation Order

Implement in this order to respect dependencies and minimise risk:

| Step | Feature | Reason |
|------|---------|--------|
| 1 | Distance Display | No new files, no new dependencies |
| 2 | Image Display | No new files, no new dependencies |
| 3 | Bookmarks | New files but no dependency on reviews |
| 4 | Reviews | Most files, most complex — implement last |

---

## Complete File Checklist

### New Files (8)
- [ ] `lib/models/review_model.dart`
- [ ] `lib/services/review_service.dart`
- [ ] `lib/providers/reviews_provider.dart`
- [ ] `lib/screens/listings/reviews_screen.dart`
- [ ] `lib/screens/listings/rate_listing_screen.dart`
- [ ] `lib/services/bookmark_service.dart`
- [ ] `lib/providers/bookmarks_provider.dart`
- [ ] `lib/screens/bookmarks/bookmarks_screen.dart`

### Modified Files (10)
- [ ] `lib/main.dart`
- [ ] `lib/navigation/bottom_navigation.dart`
- [ ] `lib/providers/listings_provider.dart`
- [ ] `lib/widgets/listing_card.dart`
- [ ] `lib/screens/home/directory_screen.dart`
- [ ] `lib/screens/listings/listing_detail_screen.dart`
- [ ] `lib/screens/listings/create_listing_screen.dart`
- [ ] `lib/screens/listings/edit_listing_screen.dart`
- [ ] `lib/utils/constants.dart`
- [ ] `README.md`

---

## Verification Checklist

- [ ] Directory screen requests location → "Near You" heading appears → cards show "X km" → sorted nearest first
- [ ] Deny location permission → directory works normally without distance
- [ ] Create listing with an image URL → detail page shows the image at top
- [ ] Create listing without image URL → detail page shows category icon placeholder
- [ ] Tap bookmark icon on a listing card → icon fills gold → Bookmarks tab shows the listing
- [ ] Tap bookmark icon again → icon empties → listing removed from Bookmarks tab
- [ ] Bookmarks persist after app restart (stored in Firestore)
- [ ] Tap "Rate this service" → rate screen opens → submit 3★ review → Firebase Console shows review document
- [ ] Listing card and detail page now show "3.0★" and "1 reviews"
- [ ] Second user submits 5★ → average recalculates to "4.0★" and "2 reviews"
- [ ] Tap "X reviews" → Reviews screen opens showing all submitted reviews
- [ ] Same user tries to review again → their existing review is pre-filled for editing
