# Kigali City Services & Places Directory

A mobile application built with Flutter to help Kigali residents locate and navigate to essential public services and leisure locations including hospitals, police stations, libraries, restaurants, cafés, parks, and tourist attractions.

## 🚀 Features (In Development)

- **Authentication**: Firebase Authentication with email verification
- **CRUD Operations**: Create, read, update, and delete service listings
- **Real-time Updates**: Cloud Firestore integration for instant data synchronization
- **Search & Filter**: Dynamic search by name and filter by category
- **Map Integration**: Google Maps with markers and turn-by-turn navigation
- **User Management**: Personal listings management and user profiles
- **Location-based Features**: Geographic coordinates and distance calculations

## 🏗️ Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
├── services/                 # Business logic layer (Firebase, location services)
├── providers/                # State management (Provider pattern)
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── home/                # Home and directory screens
│   ├── listings/            # Listing CRUD screens
│   ├── map/                 # Map view screen
│   └── settings/            # Settings screen
├── widgets/                  # Reusable UI components
├── utils/                    # Utilities (theme, constants, validators)
└── navigation/              # Navigation logic
```

## 📦 Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase (Authentication & Cloud Firestore)
- **State Management**: Provider
- **Maps**: Google Maps Flutter
- **Location**: Geolocator & Geocoding

## 🎨 Design

The app features a dark blue theme with gold accents, matching the provided UI mockups for a professional and modern look.

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.10.8 or higher)
- Android Studio / VS Code with Flutter plugins
- Firebase account
- Google Maps API key

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd individual_assignment_2
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration** (Coming Soon)
   - Create a Firebase project
   - Add Android/iOS apps to Firebase
   - Download configuration files
   - Enable Authentication and Firestore

4. **Google Maps Setup** (Coming Soon)
   - Obtain Google Maps API key
   - Add to Android and iOS configuration files

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Development Status

### Phase 1: Project Setup ✅
- [x] Flutter project initialized
- [x] Dependencies configured
- [x] Folder structure created
- [x] Theme and constants defined
- [x] Form validators implemented
- [x] Initial git commit

### Phase 2: Firebase Configuration 🔄
- [ ] Firebase project created
- [ ] Authentication enabled
- [ ] Firestore database configured
- [ ] Security rules implemented

### Phase 3: Authentication Implementation 📋
- [ ] User model created
- [ ] Auth service implemented
- [ ] Email verification enforced

### Phase 4: State Management 📋
- [ ] AuthProvider implemented
- [ ] ListingsProvider implemented
- [ ] Provider integration in main.dart

### Phases 5-10: Coming Soon
- CRUD Operations
- Search & Filtering
- Map Integration
- Navigation & Settings
- Testing & Polish
- Documentation

## 🔥 Firestore Database Structure

### Collections

**users**
- uid (string)
- email (string)
- displayName (string)
- createdAt (timestamp)
- notificationsEnabled (boolean)

**listings**
- id (string)
- name (string)
- category (string)
- address (string)
- contactNumber (string)
- description (string)
- latitude (double)
- longitude (double)
- createdBy (string - user UID)
- createdAt (timestamp)
- updatedAt (timestamp)

## 🎯 State Management Architecture

```
Firestore Database
       ↓
Service Layer (services/firestore_service.dart)
       ↓
Provider Layer (providers/listings_provider.dart)
       ↓
UI Widgets (screens/)
```

This ensures proper separation of concerns with NO direct Firebase calls from UI components.

## 📝 License

This project is created for academic purposes as part of Individual Assignment 2.

## 👨‍💻 Author

Hassan - Individual Assignment 2

---

**Note**: This is an actively developing project. Features are being implemented phase by phase following best practices for Flutter development and Firebase integration.
