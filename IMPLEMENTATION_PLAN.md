# Kigali City Services & Places Directory - Complete Implementation Plan

## 📊 Points Distribution & Strategy (Total: 50 points)

1. **State Management (10 pts)** - Highest weighted, needs perfect execution
2. **Code Quality & Repository (7 pts)** - Consistent commits & documentation
3. **Authentication (5 pts)** - Firebase Auth with email verification
4. **CRUD Operations (5 pts)** - Full Create, Read, Update, Delete with real-time updates
5. **Map Integration (5 pts)** - Google Maps with markers & navigation
6. **Deliverables (5 pts)** - Reflection PDF, Design Summary, Demo Video
7. **Demo Video Quality (5 pts)** - Show code + Firebase Console
8. **Search & Filter (4 pts)** - Dynamic search and category filtering
9. **Navigation & Settings (4 pts)** - Bottom nav + Settings screen

---

## 🏗️ Phase 1: Project Setup & Architecture (Day 1)

### 1.1 Create Flutter Project
```bash
flutter create kigali_services_directory
cd kigali_services_directory
```

### 1.2 Add Dependencies to `pubspec.yaml`
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # State Management (Choose ONE - Recommended: Provider for simplicity)
  provider: ^6.1.1
  # OR riverpod: ^2.4.9
  # OR flutter_bloc: ^8.1.3
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  url_launcher: ^6.2.2
  
  # UI & Utilities
  intl: ^0.18.1
  uuid: ^4.2.1
  cached_network_image: ^3.3.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.13.1
```

### 1.3 Create Folder Structure
```
lib/
├── main.dart
├── models/
│   ├── user_model.dart
│   ├── listing_model.dart
│   └── category_model.dart
├── services/
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── location_service.dart
├── providers/ (if using Provider)
│   ├── auth_provider.dart
│   ├── listings_provider.dart
│   └── filter_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── email_verification_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── directory_screen.dart
│   ├── listings/
│   │   ├── listing_detail_screen.dart
│   │   ├── create_listing_screen.dart
│   │   ├── edit_listing_screen.dart
│   │   └── my_listings_screen.dart
│   ├── map/
│   │   └── map_view_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   ├── listing_card.dart
│   ├── category_chip.dart
│   ├── custom_button.dart
│   ├── loading_widget.dart
│   └── error_widget.dart
├── utils/
│   ├── constants.dart
│   ├── validators.dart
│   └── theme.dart
└── navigation/
    └── bottom_nav.dart
```

### 1.4 Git Initialization (Commit #1)
```bash
git init
git add .
git commit -m "Initial project setup with folder structure"
```

---

## 🔥 Phase 2: Firebase Configuration (Day 1)

### 2.1 Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "Kigali Services Directory"
3. Enable Firebase Authentication (Email/Password)
4. Create Cloud Firestore database (Start in test mode, will secure later)
5. Add Android/iOS apps to Firebase project

### 2.2 Firebase Configuration Files
- Download `google-services.json` → `android/app/`
- Download `GoogleService-Info.plist` → `ios/Runner/`

### 2.3 Android Configuration

**android/build.gradle:**
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

**android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
        multiDexEnabled true
    }
}
```

### 2.4 iOS Configuration
Update `ios/Runner/Info.plist` with location permissions

### 2.5 Initialize Firebase in main.dart
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
```

### 2.6 Firestore Database Structure

**Collections:**

1. **users** (Stores user profiles)
```json
{
  "uid": "string (document ID)",
  "email": "string",
  "displayName": "string",
  "photoURL": "string (optional)",
  "createdAt": "timestamp",
  "notificationsEnabled": "boolean"
}
```

2. **listings** (Stores all service/place listings)
```json
{
  "id": "string (auto-generated)",
  "name": "string",
  "category": "string (Hospital, Police, Library, Restaurant, Café, Park, Tourist Attraction)",
  "address": "string",
  "contactNumber": "string",
  "description": "string",
  "latitude": "double",
  "longitude": "double",
  "createdBy": "string (user UID)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "rating": "double (optional)",
  "reviewCount": "int (optional)",
  "imageUrl": "string (optional)"
}
```

3. **bookmarks** (Optional - for bookmark functionality)
```json
{
  "userId": "string",
  "listingId": "string",
  "createdAt": "timestamp"
}
```

### 2.7 Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.createdBy == request.auth.uid;
    }
    
    match /bookmarks/{bookmarkId} {
      allow read, write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

### 2.8 Commit #2
```bash
git add .
git commit -m "Configure Firebase Authentication and Firestore"
```

---

## 🔐 Phase 3: Authentication Implementation (Day 2)

### 3.1 Create Models (`models/user_model.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final bool notificationsEnabled;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationsEnabled': notificationsEnabled,
    };
  }
}
```

### 3.2 Create Auth Service (`services/auth_service.dart`)

**CRITICAL FOR 10/10 STATE MANAGEMENT POINTS:**
- No Firebase calls in UI widgets
- All auth logic in service layer
- Exposed to UI through Provider/Bloc/Riverpod

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Create user profile in Firestore
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore());

      return {
        'success': true,
        'message': 'Account created! Please verify your email.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Please verify your email before logging in',
          'needsVerification': true,
        };
      }

      return {
        'success': true,
        'message': 'Login successful',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await currentUser?.sendEmailVerification();
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  // Helper method for error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      default:
        return 'Authentication error: $code';
    }
  }
}
```

### 3.3 Commit #3
```bash
git add .
git commit -m "Implement authentication service with email verification"
```

---

## 📦 Phase 4: State Management Layer (Day 2-3)

### 4.1 Setup Provider (Recommended for simplicity)

**main.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'screens/auth/login_screen.dart';
import 'navigation/bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
      ],
      child: MaterialApp(
        title: 'Kigali Services Directory',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFF0F1B2E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0F1B2E),
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.user == null) {
          return const LoginScreen();
        } else if (!authProvider.isEmailVerified) {
          return const EmailVerificationScreen();
        } else {
          return const BottomNavigation();
        }
      },
    );
  }
}
```

### 4.2 Create Auth Provider (`providers/auth_provider.dart`)

**CRITICAL: This demonstrates proper state management for full points**

```dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthState { loading, authenticated, unauthenticated, needsVerification }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userProfile;
  AuthState _authState = AuthState.loading;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    _initAuth();
  }

  // Initialize auth state listener
  void _initAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      
      if (user != null) {
        if (user.emailVerified) {
          // Load user profile from Firestore
          _userProfile = await _authService.getUserProfile(user.uid);
          _authState = AuthState.authenticated;
        } else {
          _authState = AuthState.needsVerification;
        }
      } else {
        _userProfile = null;
        _authState = AuthState.unauthenticated;
      }
      
      notifyListeners();
    });
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.signIn(
      email: email,
      password: password,
    );

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    await _authService.resendVerificationEmail();
  }

  // Reload user to check verification status
  Future<void> reloadUser() async {
    await _user?.reload();
    _user = _authService.currentUser;
    notifyListeners();
  }

  // Update notification preference
  Future<void> updateNotificationPreference(bool enabled) async {
    if (_user != null) {
      await _authService.updateUserProfile(
        _user!.uid,
        {'notificationsEnabled': enabled},
      );
      _userProfile = await _authService.getUserProfile(_user!.uid);
      notifyListeners();
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
}
```

### 4.3 Commit #4
```bash
git add .
git commit -m "Implement state management with Provider for authentication"
```

---

## 🗄️ Phase 5: Service/Repository Layer for Listings (Day 3)

### 5.1 Create Listing Model (`models/listing_model.dart`)
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rating;
  final int? reviewCount;
  final String? imageUrl;

  ListingModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contactNumber,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.reviewCount,
    this.imageUrl,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ListingModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contactNumber': contactNumber,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
    };
  }

  ListingModel copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contactNumber,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    String? imageUrl,
  }) {
    return ListingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contactNumber: contactNumber ?? this.contactNumber,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
```

### 5.2 Create Firestore Service (`services/firestore_service.dart`)

**CRITICAL: All Firestore operations in service layer, not in UI**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of all listings (real-time updates)
  Stream<List<ListingModel>> getAllListingsStream() {
    return _firestore
        .collection('listings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  // Stream of user's listings (real-time updates)
  Stream<List<ListingModel>> getUserListingsStream(String userId) {
    return _firestore
        .collection('listings')
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }

  // Create new listing
  Future<Map<String, dynamic>> createListing(ListingModel listing) async {
    try {
      await _firestore.collection('listings').add(listing.toFirestore());
      return {
        'success': true,
        'message': 'Listing created successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create listing: ${e.toString()}',
      };
    }
  }

  // Update listing
  Future<Map<String, dynamic>> updateListing(ListingModel listing) async {
    try {
      await _firestore
          .collection('listings')
          .doc(listing.id)
          .update(listing.toFirestore());
      return {
        'success': true,
        'message': 'Listing updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update listing: ${e.toString()}',
      };
    }
  }

  // Delete listing
  Future<Map<String, dynamic>> deleteListing(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).delete();
      return {
        'success': true,
        'message': 'Listing deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete listing: ${e.toString()}',
      };
    }
  }

  // Get single listing
  Future<ListingModel?> getListing(String listingId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('listings').doc(listingId).get();
      if (doc.exists) {
        return ListingModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Search listings by name
  Future<List<ListingModel>> searchListings(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('listings')
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      return snapshot.docs
          .map((doc) => ListingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Filter by category
  Stream<List<ListingModel>> getListingsByCategory(String category) {
    return _firestore
        .collection('listings')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ListingModel.fromFirestore(doc)).toList());
  }
}
```

### 5.3 Create Listings Provider (`providers/listings_provider.dart`)

**CRITICAL: This connects service layer to UI for full state management points**

```dart
import 'package:flutter/foundation.dart';
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

  // Getters
  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get filteredListings => _filteredListings;
  List<ListingModel> get userListings => _userListings;
  ListingsState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

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
    _firestoreService.getUserListingsStream(userId).listen(
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
          .where((listing) =>
              listing.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              listing.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredListings = _filteredListings
          .where((listing) => listing.category == _selectedCategory)
          .toList();
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
  Future<bool> createListing(ListingModel listing) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _firestoreService.createListing(listing);

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Update listing
  Future<bool> updateListing(ListingModel listing) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _firestoreService.updateListing(listing);

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Delete listing
  Future<bool> deleteListing(String listingId) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _firestoreService.deleteListing(listingId);

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
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
}
```

### 5.4 Commit #5
```bash
git add .
git commit -m "Implement Firestore service and listings state management"
```

---

## 🎨 Phase 6: UI Implementation - Authentication (Day 4)

### 6.1 Create Theme (`utils/theme.dart`)
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF0F1B2E);
  static const Color secondaryDark = Color(0xFF1A2942);
  static const Color accentGold = Color(0xFFEAA24A);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: primaryDark,
      primaryColor: accentGold,
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: accentGold,
        background: primaryDark,
        surface: secondaryDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textWhite),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarTheme(
        backgroundColor: secondaryDark,
        selectedItemColor: accentGold,
        unselectedItemColor: textGray,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textWhite, fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textWhite, fontSize: 16),
        bodyMedium: TextStyle(color: textGray, fontSize: 14),
      ),
    );
  }
}
```

### 6.2 Create Login Screen (`screens/auth/login_screen.dart`)

**Example showing proper Provider consumption:**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted && !success && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Kigali City',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Services & Places Directory',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB0B0B0),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                    filled: true,
                    fillColor: const Color(0xFF1A2942),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email, color: Color(0xFFEAA24A)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                    filled: true,
                    fillColor: const Color(0xFF1A2942),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFFEAA24A)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFFB0B0B0),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAA24A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F1B2E),
                              ),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Color(0xFFB0B0B0)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFFEAA24A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 6.3 Create Signup Screen (`screens/auth/signup_screen.dart`)
### 6.4 Create Email Verification Screen (`screens/auth/email_verification_screen.dart`)

### 6.5 Commit #6
```bash
git add .
git commit -m "Implement authentication UI screens"
```

---

## 📋 Phase 7: CRUD Implementation - Listings UI (Day 5)

### 7.1 Create Constants (`utils/constants.dart`)
```dart
class AppConstants {
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
  ];

  // Kigali center coordinates
  static const double kigaliLat = -1.9441;
  static const double kigaliLng = 30.0619;
}
```

### 7.2 Create Directory Screen (`screens/home/directory_screen.dart`)

**CRITICAL: Shows proper Provider consumption and real-time updates**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/listing_card.dart';
import '../../utils/constants.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/create_listing_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({Key? key}) : super(key: key);

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize real-time listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingsProvider>(context, listen: false)
          .initializeListingsListener();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
                Provider.of<ListingsProvider>(context, listen: false)
                    .updateSearchQuery(value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for a service',
                hintStyle: const TextStyle(color: Color(0xFFB0B0B0)),
                filled: true,
                fillColor: const Color(0xFF1A2942),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFEAA24A)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFFB0B0B0)),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<ListingsProvider>(context, listen: false)
                              .updateSearchQuery('');
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
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: provider.selectedCategory == null,
                      onSelected: (selected) {
                        provider.updateSelectedCategory(null);
                      },
                      selectedColor: const Color(0xFFEAA24A),
                      backgroundColor: const Color(0xFF1A2942),
                      labelStyle: TextStyle(
                        color: provider.selectedCategory == null
                            ? const Color(0xFF0F1B2E)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          selectedColor: const Color(0xFFEAA24A),
                          backgroundColor: const Color(0xFF1A2942),
                          labelStyle: TextStyle(
                            color: provider.selectedCategory == category
                                ? const Color(0xFF0F1B2E)
                                : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
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
                      color: Color(0xFFEAA24A),
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
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredListings.isEmpty) {
                  return const Center(
                    child: Text(
                      'No listings found',
                      style: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
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
```

### 7.3 Create Listing Card Widget (`widgets/listing_card.dart`)
### 7.4 Create Create/Edit Listing Screens with form validation
### 7.5 Create My Listings Screen showing only user's listings

### 7.6 Commit #7
```bash
git add .
git commit -m "Implement directory screen with search and category filters"
```

---

## 🗺️ Phase 8: Map Integration (Day 6)

### 8.1 Setup Google Maps API
1. Enable Maps SDK for Android/iOS in Google Cloud Console
2. Add API keys to AndroidManifest.xml and Info.plist

### 8.2 Create Detail Page with Embedded Map
### 8.3 Implement Navigation to Google Maps
### 8.4 Create Map View Screen

### 8.5 Commit #8
```bash
git add .
git commit -m "Integrate Google Maps with markers and navigation"
```

---

## 📱 Phase 9: Navigation & Settings (Day 7)

### 9.1 Create Bottom Navigation (`navigation/bottom_nav.dart`)
### 9.2 Create Settings Screen showing user profile
### 9.3 Implement notification toggle using SharedPreferences

### 9.4 Commit #9
```bash
git add .
git commit -m "Implement bottom navigation and settings screen"
```

---

## 📖 Phase 10: Documentation & Deliverables (Day 8)

### 10.1 Create Comprehensive README.md
```markdown
# Kigali City Services & Places Directory

## Features
- Firebase Authentication with email verification
- Real-time CRUD operations for listings
- Search by name and filter by category
- Google Maps integration with navigation
- User-specific listings management
- Location-based notifications toggle

## Firebase Structure

### Collections:
1. **users**: User profiles
2. **listings**: Service/place listings

### State Management:
Using Provider pattern with:
- AuthProvider: Manages authentication state
- ListingsProvider: Manages listings CRUD and filtering

## Installation
[Include Firebase setup instructions]

## Architecture
[Explain folder structure and separation of concerns]
```

### 10.2 Create Reflection PDF
**Must include:**
- At least 2 Firebase integration errors with screenshots
- How you resolved them
- Lessons learned

**Common errors to document:**
1. Firebase configuration issues
2. Email verification flow challenges
3. Firestore security rules errors
4. Real-time listener management

### 10.3 Create Design Summary Document (1-2 pages)
**Must include:**
- Firestore database schema diagram
- State management flow diagram
- Architecture explanation
- Trade-offs and challenges

### 10.4 Final Commits
```bash
git add .
git commit -m "Add comprehensive documentation and README"
```

---

## 🎥 Phase 11: Demo Video (7-12 minutes)

### Video Structure:

**1. Introduction (1 min)**
- Project overview
- Show Firebase Console open

**2. Authentication Demo (1.5 min)**
- Show signup code
- Perform signup
- Check Firebase Console for new user
- Show email verification code
- Verify email and login

**3. CRUD Operations (3 min)**
- **CREATE:** Show CreateListingScreen code, create a listing, verify in Firebase Console
- **READ:** Show DirectoryScreen code, display listings updating in real-time
- **UPDATE:** Show EditListingScreen code, update a listing, verify changes
- **DELETE:** Show delete logic, delete listing, verify removal

**4. Search & Filter (1.5 min)**
- Show search/filter implementation code
- Demonstrate searching by name
- Demonstrate category filtering

**5. Map Integration (1.5 min)**
- Show detail page code
- Show embedded map with marker
- Demonstrate navigation feature

**6. State Management Explanation (1.5 min)**
- Show Provider code structure
- Explain data flow from Firestore → Service → Provider → UI
- Show how UI rebuilds automatically

**7. Settings & Navigation (1 min)**
- Show bottom navigation
- Show settings screen with user profile
- Toggle notifications

**CRITICAL:** Always show corresponding code on screen while demonstrating each feature AND show Firebase Console updates

---

## ✅ Pre-Submission Checklist

### Code Quality (7 pts)
- [ ] ≥10 meaningful incremental commits
- [ ] Clean folder structure with separation of concerns
- [ ] README explains Firebase setup, Firestore structure, state management
- [ ] No Firebase credentials exposed in code

### State Management (10 pts)
- [ ] All Firestore operations in service layer
- [ ] No direct Firebase calls in UI widgets
- [ ] Loading/error/success states handled
- [ ] Real-time UI updates working
- [ ] Can explain state flow in video

### Authentication (5 pts)
- [ ] Signup/Login/Logout working
- [ ] Email verification enforced
- [ ] User profile created in Firestore
- [ ] Can show auth code in video

### CRUD Operations (5 pts)
- [ ] Create listing works
- [ ] Read listings works with real-time updates
- [ ] Update listing works (user's own listings only)
- [ ] Delete listing works (user's own listings only)
- [ ] Can show CRUD code in video

### Search & Filter (4 pts)
- [ ] Search by name works
- [ ] Category filter works
- [ ] Results update dynamically
- [ ] Can show filter code in video

### Map Integration (5 pts)
- [ ] Embedded map on detail page
- [ ] Marker shows correct location
- [ ] Navigation button launches Google Maps
- [ ] Can show map code in video

### Navigation & Settings (4 pts)
- [ ] Bottom navigation with 4 screens
- [ ] Settings shows user profile
- [ ] Notification toggle works
- [ ] Smooth navigation between screens

### Deliverables (5 pts)
- [ ] Reflection PDF with ≥2 Firebase errors + solutions
- [ ] Design Summary with Firestore schema
- [ ] GitHub repo link included

### Demo Video (5 pts)
- [ ] Duration: 7-12 minutes
- [ ] Shows all features working
- [ ] Shows implementation code for each feature
- [ ] Shows Firebase Console updates
- [ ] Explains state management architecture

---

## 🎯 Critical Success Factors for Full Points

1. **Perfect State Management (10 pts):**
   - NEVER call Firebase directly from UI widgets
   - ALL operations through service → provider → UI
   - Show this architecture clearly in video

2. **Code Quality (7 pts):**
   - Make commits THROUGHOUT development, not at the end
   - Write detailed commit messages
   - README must be comprehensive

3. **Demo Video (5 pts):**
   - Split screen: app on one side, code/Firebase Console on other
   - ALWAYS show code while explaining features
   - Practice before recording to stay within 7-12 minutes

4. **Documentation (5 pts):**
   - Document REAL errors you encountered (take screenshots)
   - Explain Firestore schema with diagrams
   - Be thorough but concise

5. **Real-time Updates:**
   - Use StreamBuilder or Provider listeners
   - UI should update automatically when Firestore changes
   - Demonstrate this clearly in video

---

## 📅 Recommended Timeline

- **Day 1:** Setup, Firebase config
- **Day 2-3:** Authentication + State Management
- **Day 4:** Listing models + Firestore service
- **Day 5:** CRUD UI implementation
- **Day 6:** Map integration
- **Day 7:** Navigation, Settings, Polish
- **Day 8:** Documentation + Demo video
- **Day 9:** Review and submit

---

## 🔧 Common Pitfalls to Avoid

1. ❌ Calling Firebase directly in build() methods
2. ❌ Not enforcing email verification
3. ❌ Hardcoding coordinates instead of using Firestore data
4. ❌ Making one giant commit instead of incremental commits
5. ❌ Demo video without showing code
6. ❌ Not showing Firebase Console in demo
7. ❌ README without Firebase setup instructions
8. ❌ Not documenting real Firebase errors
9. ❌ App only working in browser (must work on emulator/device)
10. ❌ No separation between service layer and UI

---

## 🏆 Tips for Maximum Points

1. **Over-communicate in video:** Explain the WHY, not just WHAT
2. **Show the flow:** Firestore → Service → Provider → UI
3. **Document everything:** Screenshots of errors, solutions, architecture
4. **Test thoroughly:** Every CRUD operation, every filter, every navigation
5. **Polish the UI:** Match or exceed the reference design
6. **Commit often:** Every feature = new commit
7. **Handle edge cases:** Empty states, loading states, error states
8. **Use proper naming:** Clear, descriptive variable/function names
9. **Comment complex logic:** Especially in service/provider layers
10. **Practice the demo:** Rehearse before recording

---

Good luck! Follow this plan systematically, and you'll achieve full points. Remember: **Architecture matters more than features**—show proper separation of concerns and state management flow, and you'll excel.
