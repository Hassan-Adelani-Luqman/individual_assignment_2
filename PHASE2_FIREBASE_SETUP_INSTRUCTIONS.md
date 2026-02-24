# Phase 2: Firebase Configuration - Detailed Instructions

## 📋 Overview
This phase will connect your Flutter app to Firebase, enabling Authentication and Cloud Firestore for real-time database operations. Follow these steps carefully and document any errors you encounter (required for your Reflection PDF).

---

## Part 1: Firebase Console Setup

### Step 1: Create Firebase Project

1. **Go to Firebase Console**
   - Navigate to: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click **"Add project"** or **"Create a project"**
   - Enter project name: `kigali-services-directory` (or your preferred name)
   - Click **Continue**

3. **Google Analytics (Optional)**
   - You can disable Google Analytics for this project (toggle off)
   - Or keep it enabled and select/create an Analytics account
   - Click **Create project**
   - Wait for project creation (takes 30-60 seconds)
   - Click **Continue** when ready

4. **Take Screenshot** 📸
   - Screenshot your Firebase project dashboard
   - Save as: `firebase-project-created.png`
   - (You'll need this for your documentation)

---

### Step 2: Enable Firebase Authentication

1. **Navigate to Authentication**
   - In Firebase Console left sidebar, click **"Authentication"**
   - Click **"Get started"** button

2. **Enable Email/Password Sign-in**
   - Click on **"Sign-in method"** tab
   - Find **"Email/Password"** in the providers list
   - Click on it to expand
   - Toggle **"Enable"** to ON
   - Leave **"Email link (passwordless sign-in)"** DISABLED
   - Click **"Save"**

3. **Verify Configuration**
   - Email/Password should now show as "Enabled" in the list
   - Take Screenshot 📸: `firebase-auth-enabled.png`

**Common Error #1 to Document:**
If you see "Error: Firebase Authentication is not enabled" later, return here and verify Email/Password is truly enabled.

---

### Step 3: Create Cloud Firestore Database

1. **Navigate to Firestore Database**
   - In left sidebar, click **"Firestore Database"**
   - Click **"Create database"** button

2. **Select Starting Mode**
   - Choose **"Start in test mode"** (for development)
   - ⚠️ **Important**: We'll secure this with proper rules later
   - Click **Next**

3. **Choose Location**
   - Select the location closest to you or your users
   - Recommended for Rwanda: **"europe-west1"** (Belgium) or **"asia-south1"** (Mumbai)
   - ⚠️ **Note**: Location cannot be changed after creation!
   - Click **Enable**
   - Wait for database creation (30-60 seconds)

4. **Verify Database Created**
   - You should see the Firestore data viewer interface
   - Currently empty (no collections yet)
   - Take Screenshot 📸: `firestore-database-created.png`

---

### Step 4: Set Up Firestore Security Rules

1. **Navigate to Rules Tab**
   - In Firestore Database page, click **"Rules"** tab

2. **Replace Default Rules**
   - Delete the existing rules
   - Copy and paste the following rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the document
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    // Users collection rules
    match /users/{userId} {
      // Anyone authenticated can read any user profile
      allow read: if isAuthenticated();
      
      // Users can only create/update their own profile
      allow create, update: if isAuthenticated() && isOwner(userId);
      
      // Users cannot delete their profile (optional - remove if needed)
      allow delete: if false;
    }
    
    // Listings collection rules
    match /listings/{listingId} {
      // Anyone authenticated can read all listings
      allow read: if isAuthenticated();
      
      // Only authenticated users can create listings
      // Must set createdBy to their own UID
      allow create: if isAuthenticated() 
                    && request.resource.data.createdBy == request.auth.uid;
      
      // Only the creator can update their own listings
      allow update: if isAuthenticated() 
                    && resource.data.createdBy == request.auth.uid;
      
      // Only the creator can delete their own listings
      allow delete: if isAuthenticated() 
                    && resource.data.createdBy == request.auth.uid;
    }
    
    // Bookmarks collection rules (optional - for future feature)
    match /bookmarks/{bookmarkId} {
      allow read, write: if isAuthenticated() 
                         && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

3. **Publish Rules**
   - Click **"Publish"** button
   - Take Screenshot 📸: `firestore-security-rules.png`

**Common Error #2 to Document:**
If you get "Permission denied" errors when testing CRUD operations, check these rules. Most common mistake: trying to create/update/delete without being authenticated.

---

### Step 5: Create Initial Collections (Optional but Recommended)

1. **Create Users Collection**
   - In Firestore Database **"Data"** tab
   - Click **"Start collection"**
   - Collection ID: `users`
   - Click **Next**
   - For Document ID: Click **"Auto-ID"**
   - Add fields (temporary test document):
     - Field: `email` | Type: string | Value: `test@example.com`
     - Field: `displayName` | Type: string | Value: `Test User`
     - Field: `createdAt` | Type: timestamp | Value: Click "Set value to current timestamp"
   - Click **Save**

2. **Create Listings Collection**
   - Click **"Start collection"** again
   - Collection ID: `listings`
   - Click **Next**
   - For Document ID: Click **"Auto-ID"**
   - Add fields (temporary test document):
     - Field: `name` | Type: string | Value: `Kimironko Market`
     - Field: `category` | Type: string | Value: `Shopping`
     - Field: `address` | Type: string | Value: `KN 3 Rd, Kigali`
     - Field: `createdBy` | Type: string | Value: `test-user-id`
     - Field: `createdAt` | Type: timestamp | Value: Current timestamp
   - Click **Save**

3. **Verify Collections**
   - You should see both `users` and `listings` collections in the left panel
   - Take Screenshot 📸: `firestore-collections-created.png`

**Note**: These test documents will be deleted once you create real data through your app.

---

## Part 2: Add Firebase to Your Flutter App

### Step 6: Register Android App with Firebase

1. **Add Android App**
   - In Firebase Console, click the **gear icon** (⚙️) next to "Project Overview"
   - Click **"Project settings"**
   - Scroll down to **"Your apps"** section
   - Click the **Android icon** to add an Android app

2. **Enter Android Package Name**
   - Android package name: `com.example.individual_assignment_2`
   - **How to find it**: Open `android/app/build.gradle` in your project
   - Look for `applicationId` under `defaultConfig`
   - Copy the exact value (case-sensitive)
   
3. **Optional Fields**
   - App nickname: `Kigali Services (Android)` (optional)
   - Debug signing certificate SHA-1: Leave blank for now
   - Click **"Register app"**

4. **Download google-services.json**
   - Click **"Download google-services.json"** button
   - **Important**: Save this file!
   - Take Screenshot 📸: `android-app-registered.png`

---

### Step 7: Add google-services.json to Android Project

1. **Move Configuration File**
   ```bash
   # In terminal, navigate to your project root
   cd /home/hassan/flutter_linux_3.38.6-stable/individual_assignment_2
   
   # Move google-services.json to android/app/
   # Replace ~/Downloads/google-services.json with actual location
   mv ~/Downloads/google-services.json android/app/
   ```

2. **Verify File Location**
   ```bash
   # Check if file exists in correct location
   ls -la android/app/google-services.json
   ```
   
   Expected output: Should show the file exists
   
   **Common Error #3 to Document:**
   If you get "google-services.json not found" error, the file is in the wrong location. It MUST be in `android/app/` directory, not in `android/`.

---

### Step 8: Configure Android for Firebase

#### 8.1 Update Project-Level build.gradle

Open `android/build.gradle` and make these changes:

**Location**: `android/build.gradle`

Find the `dependencies` section under `buildscript` and add the Google services plugin:

```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // Add this line for Firebase
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 8.2 Update App-Level build.gradle

Open `android/app/build.gradle` and make these changes:

**Location**: `android/app/build.gradle`

1. **At the TOP of the file** (after the first line), add:
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

// Add this line for Firebase
apply plugin: 'com.google.gms.google-services'
```

2. **Update minSdkVersion**:
Find `android { defaultConfig {` section and change:
```gradle
android {
    namespace = "com.example.individual_assignment_2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId = "com.example.individual_assignment_2"
        // Change this from 21 to 21 (or higher if already higher)
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Add this for multidex support
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}
```

3. **Add dependencies at the bottom**:
```gradle
dependencies {
    implementation 'com.android.support:multidex:1.0.3'
}
```

#### 8.3 Update AndroidManifest.xml

Open `android/app/src/main/AndroidManifest.xml` and add internet permission:

**Location**: `android/app/src/main/AndroidManifest.xml`

Add this BEFORE the `<application>` tag:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.individual_assignment_2">
    
    <!-- Add these permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:label="Kigali Services"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- rest of the file -->
```

---

### Step 9: Register iOS App with Firebase (Optional but Recommended)

1. **Add iOS App in Firebase Console**
   - In Project Settings, click the **iOS icon**
   - iOS bundle ID: `com.example.individualAssignment2`
   - **How to find it**: Open `ios/Runner.xcodeproj` in Xcode or check `ios/Runner/Info.plist`
   - App nickname: `Kigali Services (iOS)` (optional)
   - Click **"Register app"**

2. **Download GoogleService-Info.plist**
   - Click **"Download GoogleService-Info.plist"**
   - Move it to `ios/Runner/` directory:
   ```bash
   mv ~/Downloads/GoogleService-Info.plist ios/Runner/
   ```

3. **Update iOS Configuration**
   - Open `ios/Runner/Info.plist`
   - Add location permissions (copy from implementation plan)

**Note**: If you're only testing on Android, you can skip iOS configuration for now.

---

### Step 10: Initialize Firebase in Flutter App

Create the Firebase initialization file:

**File**: `lib/firebase_options.dart`

```dart
// This file will be auto-generated by FlutterFire CLI
// For now, we'll initialize Firebase manually in main.dart
```

Update your `main.dart`:

**File**: `lib/main.dart`

Add Firebase initialization:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

// Temporary splash screen - will be replaced with authentication flow
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_city,
              size: 80,
              color: AppTheme.accentGold,
            ),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppTheme.accentGold,
            ),
            const SizedBox(height: 16),
            const Text(
              'Connecting to Firebase...',
              style: TextStyle(color: AppTheme.textGray),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Part 3: Test Firebase Connection

### Step 11: Test the Setup

1. **Clean Build**
   ```bash
   cd /home/hassan/flutter_linux_3.38.6-stable/individual_assignment_2
   flutter clean
   flutter pub get
   ```

2. **Build and Run on Device/Emulator**
   ```bash
   # Make sure you have an Android emulator running or device connected
   flutter devices
   
   # Run the app
   flutter run
   ```

3. **Expected Results**
   - App should launch without errors
   - Splash screen should appear
   - Check terminal output for Firebase initialization confirmation
   - Look for: `[firebase_core] Successfully initialized Firebase`

4. **Common Errors and Solutions**

   **Error: "google-services.json is missing"**
   - Solution: Verify file is in `android/app/` directory
   - Run: `ls android/app/google-services.json`
   - If missing, re-download from Firebase Console

   **Error: "FirebaseException: No Firebase App '[DEFAULT]' has been created"**
   - Solution: Ensure `Firebase.initializeApp()` is called before `runApp()`
   - Check that `WidgetsFlutterBinding.ensureInitialized()` is called first

   **Error: "MinSdkVersion X is less than 21"**
   - Solution: Update `android/app/build.gradle` to set `minSdk = 21`

   **Error: "Execution failed for task ':app:processDebugGoogleServices'"**
   - Solution: Your `applicationId` in `build.gradle` doesn't match package name in `google-services.json`
   - Fix: Update `applicationId` to match exactly, or re-download `google-services.json`

   **Error: "MissingPluginException"**
   - Solution: Run `flutter clean && flutter pub get` and rebuild

5. **Take Screenshots** 📸
   - Screenshot of app running successfully: `app-running-with-firebase.png`
   - Screenshot of terminal showing successful Firebase init: `terminal-firebase-success.png`

---

### Step 12: Verify Firestore Connection

Create a test file to verify Firestore is accessible:

**File**: `lib/test_firebase.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTest {
  static Future<void> testFirestoreConnection() async {
    try {
      // Try to get a reference to Firestore
      final firestore = FirebaseFirestore.instance;
      
      // Try to access the listings collection
      final snapshot = await firestore
          .collection('listings')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));
      
      print('✅ Firestore connection successful!');
      print('📊 Found ${snapshot.docs.length} documents in listings collection');
      
      return;
    } catch (e) {
      print('❌ Firestore connection failed: $e');
      rethrow;
    }
  }
}
```

Update `main.dart` to test connection on startup:

```dart
// In main() function, after Firebase.initializeApp():
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Test Firebase connection (remove this after testing)
  try {
    await FirebaseTest.testFirestoreConnection();
  } catch (e) {
    print('Firebase test failed: $e');
  }
  
  runApp(const MyApp());
}
```

---

## Part 4: Git Commit

### Step 13: Commit Your Changes

1. **Check what changed**
   ```bash
   git status
   ```

2. **Add all changes**
   ```bash
   git add .
   ```

3. **Commit with descriptive message**
   ```bash
   git commit -m "Configure Firebase Authentication and Cloud Firestore
   
   - Added google-services.json for Android
   - Configured build.gradle files for Firebase
   - Updated AndroidManifest.xml with permissions
   - Initialized Firebase in main.dart
   - Set up Firestore security rules
   - Created test collections (users, listings)
   - Verified Firebase connection"
   ```

4. **Verify commit**
   ```bash
   git log --oneline -3
   ```

---

## 📸 Required Screenshots for Documentation

Make sure you have captured these screenshots:

1. ✅ `firebase-project-created.png` - Firebase project dashboard
2. ✅ `firebase-auth-enabled.png` - Email/Password authentication enabled
3. ✅ `firestore-database-created.png` - Firestore database created
4. ✅ `firestore-security-rules.png` - Security rules configured
5. ✅ `firestore-collections-created.png` - Initial collections created
6. ✅ `android-app-registered.png` - Android app registered in Firebase
7. ✅ `app-running-with-firebase.png` - App running successfully
8. ✅ `terminal-firebase-success.png` - Terminal showing Firebase init success

**Save all screenshots in a folder**: `documentation/screenshots/phase2/`

---

## 🔍 Troubleshooting Checklist

Before moving to Phase 3, verify:

- [ ] Firebase project created and accessible
- [ ] Email/Password authentication enabled in Firebase Console
- [ ] Firestore database created with test mode rules
- [ ] Security rules updated and published
- [ ] `google-services.json` in `android/app/` directory
- [ ] `android/build.gradle` has Google services plugin
- [ ] `android/app/build.gradle` has `apply plugin: 'com.google.gms.google-services'`
- [ ] `minSdk` is set to 21 or higher
- [ ] AndroidManifest.xml has internet permission
- [ ] `Firebase.initializeApp()` added to main.dart
- [ ] App builds and runs without errors
- [ ] Terminal shows "Successfully initialized Firebase"
- [ ] Git commit made with descriptive message
- [ ] All screenshots captured and saved

---

## 📝 Common Errors to Document for Reflection PDF

As you go through this phase, document these potential errors:

1. **Missing google-services.json Error**
   - What caused it
   - How you discovered it
   - Solution applied

2. **Build.gradle Configuration Issues**
   - What was wrong
   - Error message received
   - How you fixed it

3. **Firebase Initialization Errors**
   - Context when error occurred
   - Stack trace or error message
   - Resolution steps

4. **Security Rules Errors** (will encounter in Phase 3-4)
   - Permission denied errors
   - How rules were adjusted

---

## ✅ Phase 2 Complete! 

Once all checkboxes above are verified, you're ready to proceed to:
- **Phase 3: Authentication Implementation**

**Estimated Time**: 1-2 hours (depending on familiarity with Firebase Console)

**Next Phase Preview**: You'll create the authentication service, user models, and implement signup/login screens with email verification enforcement.

---

## 🆘 Need Help?

- Firebase Documentation: https://firebase.google.com/docs/flutter/setup
- FlutterFire Documentation: https://firebase.flutter.dev/
- Common Firebase Errors: https://firebase.flutter.dev/docs/manual-installation/

**Remember**: Document ALL errors you encounter with screenshots - you need at least 2 for your Reflection PDF!
