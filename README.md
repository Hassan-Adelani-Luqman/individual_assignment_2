# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure locations — hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions. Built with Firebase Authentication, Cloud Firestore, Google Maps, and the Provider state management pattern.

---

## Features

- **Authentication** — Sign up, log in, and log out using Firebase Authentication. Email verification is enforced before users can access the app. Each user has a profile stored in Firestore.
- **Location Listings (CRUD)** — Create, read, update, and delete service listings stored in Cloud Firestore. All changes reflect in real time across the app.
- **Directory View** — Browse all listings with real-time search (by name, description, or address) and category filter chips.
- **My Listings** — View and manage only your own listings.
- **Map View** — Interactive Google Map showing all listings as markers. Tap a marker to preview the listing and navigate to the detail page.
- **Listing Detail** — Full listing information with an embedded Google Map, a "Get Directions" button (launches Google Maps turn-by-turn navigation), and a direct phone call shortcut.
- **Settings** — Displays your profile (name, email, member since), email verification status, a notification toggle that persists to your Firestore profile, and logout.

---

## Firestore Database Structure

### `users` collection
| Field | Type | Description |
|-------|------|-------------|
| `uid` | string | Firebase Auth user ID (document ID) |
| `email` | string | User email address |
| `displayName` | string | Display name entered at signup |
| `createdAt` | timestamp | Account creation date |
| `notificationsEnabled` | boolean | Notification preference (default: true) |

### `listings` collection
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Firestore document ID |
| `name` | string | Place or service name |
| `category` | string | Category (e.g., Hospital, Café, Park) |
| `address` | string | Physical address |
| `contactNumber` | string | Phone number |
| `description` | string | Full description |
| `latitude` | double | Geographic latitude |
| `longitude` | double | Geographic longitude |
| `createdBy` | string | UID of the user who created the listing |
| `createdAt` | timestamp | Creation timestamp |
| `updatedAt` | timestamp | Last update timestamp |

---

## State Management Architecture

Provider pattern is used throughout. No Firebase SDK calls are made directly from UI widgets.

```
Firestore / Firebase Auth
         ↓
  Service Layer
  ├── AuthService      (lib/services/auth_service.dart)
  └── FirestoreService (lib/services/firestore_service.dart)
         ↓
  Provider Layer
  ├── AuthProvider     (lib/providers/auth_provider.dart)
  └── ListingsProvider (lib/providers/listings_provider.dart)
         ↓
  UI Widgets (lib/screens/)
```

- **AuthProvider** manages authentication state (`loading`, `authenticated`, `unauthenticated`, `needsVerification`), exposes user and user profile, and subscribes to `authStateChanges`.
- **ListingsProvider** subscribes to Firestore real-time streams for all listings and the current user's listings, applies in-memory search and category filters, and exposes CRUD methods to the UI.

---

## Navigation Structure

A `BottomNavigationBar` with four tabs:

| Tab | Screen | Description |
|-----|--------|-------------|
| Home | Directory | Browse all listings with search and category filters |
| Map | Map View | Interactive map with markers for all listings |
| My Listings | My Listings | Listings created by the authenticated user |
| Settings | Settings | Profile info, notification toggle, logout |

---

## Project Structure

```
lib/
├── main.dart                      # App entry point, Provider setup, AuthWrapper routing
├── models/
│   ├── listing_model.dart         # Listing data model with Firestore serialization
│   └── user_model.dart            # User profile model
├── services/
│   ├── auth_service.dart          # Firebase Auth + Firestore user operations
│   └── firestore_service.dart     # Firestore CRUD + real-time streams for listings
├── providers/
│   ├── auth_provider.dart         # Authentication state management
│   └── listings_provider.dart     # Listings state, filtering, CRUD
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── email_verification_screen.dart
│   ├── home/
│   │   ├── directory_screen.dart  # Listing directory with search and filters
│   │   └── map_view_screen.dart   # Google Maps with all listing markers
│   ├── listings/
│   │   ├── create_listing_screen.dart
│   │   ├── edit_listing_screen.dart
│   │   ├── listing_detail_screen.dart
│   │   └── my_listings_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   └── listing_card.dart          # Reusable listing card widget
├── navigation/
│   └── bottom_navigation.dart     # Bottom nav bar with PageView
└── utils/
    ├── constants.dart             # App constants and category list
    ├── theme.dart                 # Dark theme with gold accent
    └── validators.dart            # Form field validators
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x / Dart SDK 3.10.8+ |
| Authentication | Firebase Authentication 6.x |
| Database | Cloud Firestore 6.x |
| State Management | Provider 6.x |
| Maps | google_maps_flutter 2.14.x |
| Location | geolocator 14.x, geocoding 4.x |
| Navigation | url_launcher 6.x |
| Local storage | shared_preferences 2.x |

---

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10 or higher
- Android Studio or VS Code with Flutter/Dart plugins
- A Firebase project with Authentication and Firestore enabled
- A Google Maps API key with the Maps SDK for Android (and iOS) enabled

### 1. Clone the repository
```bash
git clone <repository-url>
cd individual_assignment_2
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a project.
2. Add an Android app (package name: `com.example.individual_assignment_2`).
3. Download `google-services.json` and place it in `android/app/`.
4. In the Firebase Console, enable **Authentication → Email/Password**.
5. Create a **Cloud Firestore** database in production mode.
6. Add the following Firestore security rules:
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
     }
   }
   ```

### 4. Google Maps API Key

**Android:** Open `android/app/src/main/AndroidManifest.xml` and replace the existing API key value:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 5. Run the application
```bash
flutter run
```

---

## Author

Hassan — Individual Assignment 2  
GitHub: [Hassan-Adelani-Luqman/individual_assignment_2](https://github.com/Hassan-Adelani-Luqman/individual_assignment_2)
