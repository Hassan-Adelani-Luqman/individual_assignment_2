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

**Important**: Your Flutter project uses **Kotlin DSL** with `.kts` files. There is **NO** `android/build.gradle` file!

---

#### 8.1 Configure settings.gradle.kts (Project-Level Plugin Declaration)

**File to Edit**: `android/settings.gradle.kts`

**What it looks like NOW** (default Flutter project):
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}
```

**What you need to ADD** (add ONE line):
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.0" apply false  // ← ADD THIS LINE
}
```

**Action**: Add the Google Services line INSIDE the plugins block, after the Kotlin line.

**Verification**: 
```bash
# Check if you added it correctly
grep "google-services" android/settings.gradle.kts
```
Expected output: `id("com.google.gms.google-services") version "4.4.0" apply false`

---

#### 8.2 Configure app/build.gradle.kts (App-Level Configuration)

**File to Edit**: `android/app/build.gradle.kts`

This file has **THREE changes** to make:

---

**CHANGE #1: Add Firebase Plugin**

**Location**: At the very TOP of the file (lines 1-6)

**BEFORE** (current):
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
```

**AFTER** (add one line):
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← ADD THIS LINE
}
```

---

**CHANGE #2: Update minSdk and Add Multidex**

**Location**: Inside `defaultConfig` block (around line 24-30)

**BEFORE** (current):
```kotlin
    defaultConfig {
        applicationId = "com.example.individual_assignment_2"
        minSdk = flutter.minSdkVersion  // ← This line will change
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
```

**AFTER** (change minSdk and add multiDexEnabled):
```kotlin
    defaultConfig {
        applicationId = "com.example.individual_assignment_2"
        minSdk = 21  // ← CHANGED from flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ← ADD THIS LINE
    }
```

---

**CHANGE #3: Add Dependencies**

**Location**: At the BOTTOM of the file, AFTER the `flutter { }` block

**BEFORE** (current - file ends like this):
```kotlin
flutter {
    source = "../.."
}
```

**AFTER** (add dependencies block):
```kotlin
flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
}
```

---

**Complete app/build.gradle.kts Reference** (for verification):

After all changes, your file should look like this:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← ADDED
}

android {
    namespace = "com.example.individual_assignment_2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.individual_assignment_2"
        minSdk = 21  // ← CHANGED
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true  // ← ADDED
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")  // ← ADDED
}
```

**Verification Commands**:
```bash
# Check if Firebase plugin is applied
grep "google-services" android/app/build.gradle.kts

# Check if minSdk is set to 21
grep "minSdk = 21" android/app/build.gradle.kts

# Check if multidex is enabled
grep "multiDexEnabled" android/app/build.gradle.kts

# Check if dependencies block exists
grep "androidx.multidex" android/app/build.gradle.kts
```

All four commands should return matches. If any don't, you missed that change!

#### 8.3 Update AndroidManifest.xml (Add Permissions and Change App Name)

**File to Edit**: `android/app/src/main/AndroidManifest.xml`

This file needs **TWO changes**:

---

**CHANGE #1: Add Permissions**

**Location**: AFTER `<manifest>` tag, BEFORE `<application>` tag (around line 2)

**BEFORE** (current):
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="individual_assignment_2"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
```

**AFTER** (add three permission lines):
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    
    <application
        android:label="individual_assignment_2"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
```

---

**CHANGE #2: Update App Label**

**Location**: Inside `<application>` tag (same area as above)

**BEFORE**:
```xml
    <application
        android:label="individual_assignment_2"
```

**AFTER**:
```xml
    <application
        android:label="Kigali Services"
```

---

**Verification**:
```bash
# Check permissions were added
grep "INTERNET" android/app/src/main/AndroidManifest.xml
grep "ACCESS_FINE_LOCATION" android/app/src/main/AndroidManifest.xml

# Check app label was changed
grep "Kigali Services" android/app/src/main/AndroidManifest.xml
```

All three commands should return matches!

---

#### Step 8 Summary: What You Just Changed

✅ **Changed 3 files total:**

| File | What Changed | Why |
|------|--------------|-----|
| `android/settings.gradle.kts` | Added Google Services plugin declaration | Makes plugin available to app |
| `android/app/build.gradle.kts` | 3 changes: Plugin, minSdk=21, multidex | Applies Firebase plugin and compatibility |
| `android/app/src/main/AndroidManifest.xml` | Added permissions + changed label | Internet access for Firebase, location for maps |

✅ **Quick Verification Checklist:**
```bash
# Run all these commands - all should show results:
grep "google-services" android/settings.gradle.kts
grep "google-services" android/app/build.gradle.kts
grep "minSdk = 21" android/app/build.gradle.kts
grep "multiDexEnabled" android/app/build.gradle.kts
grep "androidx.multidex" android/app/build.gradle.kts
grep "INTERNET" android/app/src/main/AndroidManifest.xml
grep "Kigali Services" android/app/src/main/AndroidManifest.xml
```

If ANY command returns nothing, go back and check that file!

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

**File to Edit**: `lib/main.dart`

**What to Change**: The `main()` function needs to become `async` and initialize Firebase before running the app.

---

**BEFORE** (current Flutter default):
```dart
import 'package:flutter/material.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}
```

**AFTER** (add Firebase initialization):
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  // ← ADD this import
import 'utils/theme.dart';
import 'utils/constants.dart';

void main() async {  // ← ADD async
  // ← ADD these 3 lines:
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}
```

---

**What Each Line Does**:

1. `import 'package:firebase_core/firebase_core.dart';`
   - Imports Firebase initialization functions

2. `void main() async {`
   - Makes main function asynchronous (required for `await`)

3. `WidgetsFlutterBinding.ensureInitialized();`
   - Ensures Flutter is ready before Firebase initializes
   - **Must be called FIRST** in async main()

4. `await Firebase.initializeApp();`
   - Initializes Firebase connection
   - Waits for completion before continuing

---

**Optional: Update Splash Screen Text**

While you're in `main.dart`, find the splash screen text (around line 60):

**BEFORE**:
```dart
const Text(
  'Setting up...',
  style: TextStyle(color: AppTheme.textGray),
),
```

**AFTER**:
```dart
const Text(
  'Connecting to Firebase...',
  style: TextStyle(color: AppTheme.textGray),
),
```

---

**Verification**:
```bash
# Check if Firebase import was added
grep "firebase_core" lib/main.dart

# Check if main is async
grep "void main() async" lib/main.dart

# Check if Firebase.initializeApp is called
grep "Firebase.initializeApp" lib/main.dart
```

All three should return matches!

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

   **Error #1: "google-services.json is missing"**
   - **Cause**: File not in correct location
   - **Solution**: Verify file is in `android/app/` directory (NOT in `android/`)
   - **Command**: `ls android/app/google-services.json`
   - **Screenshot this error** 📸 for your Reflection PDF!

   **Error #2: "FirebaseException: No Firebase App '[DEFAULT]' has been created"**
   - **Cause**: Firebase not initialized before app starts
   - **Solution**: Ensure `Firebase.initializeApp()` is called before `runApp()` in main.dart
   - **Check**: `WidgetsFlutterBinding.ensureInitialized()` must be called first
   - **Screenshot this error** 📸 for your Reflection PDF!

   **Error #3: "MinSdkVersion X is less than 21"**
   - **Cause**: Firebase requires minSdk 21 or higher
   - **Solution**: Update `android/app/build.gradle.kts` → set `minSdk = 21`
   - **Line to change**: `minSdk = flutter.minSdkVersion` → `minSdk = 21`

   **Error #4: "Execution failed for task ':app:processDebugGoogleServices'"**
   - **Cause**: Package name mismatch
   - **Check**: `applicationId` in `build.gradle.kts` must match package name in `google-services.json`
   - **Solution**: Either update `applicationId` or re-download `google-services.json` with correct package name

   **Error #5: "MissingPluginException"**
   - **Cause**: Native code not rebuilt after adding plugins
   - **Solution**: Run `flutter clean && flutter pub get` and rebuild app
   - **For persistent issues**: Stop app, uninstall from device, then rebuild

   **Error #6: "Could not find com.google.gms:google-services"**
   - **Cause**: Google Services plugin not added to settings.gradle.kts
   - **Solution**: Verify you added the plugin to `android/settings.gradle.kts` (NOT build.gradle!)
   
   **Error #7: "Plugin with id 'com.google.gms.google-services' not found"**
   - **Cause**: Wrong file modified or syntax error
   - **Solution**: Check `android/settings.gradle.kts` has: `id("com.google.gms.google-services") version "4.4.0" apply false`
   - **Then**: Check `android/app/build.gradle.kts` has: `id("com.google.gms.google-services")` in plugins block
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

1. ✅ `firebase-project-created.png` - Firebas in Firebase Console
- [ ] Email/Password authentication enabled in Firebase Console
- [ ] Firestore database created with test mode rules
- [ ] Security rules updated and published
- [ ] `google-services.json` in `android/app/` directory (verify with: `ls android/app/google-services.json`)
- [ ] `android/settings.gradle.kts` has Google Services plugin in plugins block
- [ ] `android/app/build.gradle.kts` has `id("com.google.gms.google-services")` in plugins block
- [ ] `minSdk = 21` in `android/app/build.gradle.kts` defaultConfig
- [ ] `multiDexEnabled = true` in `android/app/build.gradle.kts` defaultConfig
- [ ] `dependencies` block with multidex at bottom of `android/app/build.gradle.kts`
- [ ] AndroidManifest.xml has internet and location permissions
- [ ] App label changed to "Kigali Services" in AndroidManifest.xml
- [ ] `Firebase.initializeApp()` added to main.dart with `async`/`await`
- [ ] `WidgetsFlutterBinding.ensureInitialized()` called before Firebase init
- [ ] `flutter clean && flutter pub get` executed successfully
- [ ] App builds without errors (`flutter build apk --debug` or `flutter run`)
- [ ] App runs on emulator/device without crashes
- [ ] Terminal shows "[firebase_core] Successfully initialized Firebase"
- [ ] Git commit made with descriptive message
- [ ] All screenshots captured and saved

**Quick Verification Commands**:
```bash
# Verify google-services.json location
ls android/app/google-services.json

# Verify Kotlin DSL files exist
ls android/settings.gradle.kts
ls android/app/build.gradle.kts

# Clean and rebuild
flutter clean && flutter pub get

# Check for errors
flutter analyze

**IMPORTANT**: You need at least 2 Firebase errors with screenshots for your Reflection PDF!

As you go through this phase, document these errors if you encounter them:

### Error Template (Use this format):

**Error #X: [Error Title]**
- **When it occurred**: [During which step]
- **Error message**: [Exact error text]
- **Screenshot**: 📸 [Attach screenshot of error]
- **What I tried first**: [Initial troubleshooting attempts]
- **Root cause**: [What actually caused the error]
- **Solution applied**: [How you fixed it]
- **Prevention**: [How to avoid this in future]

### Recommended Errors to Document:

1. **Kotlin DSL Configuration Confusion**
   - Error when trying to follow Groovy syntax in Kotlin DSL files
   - Shows importance of checking project structure first
   - Good learning point about Flutter's evolution to Kotlin DSL

2. **google-services.json Location Error**
   - Classic mistake: putting file in wrong directory
   - Screenshot the terminal showing file not found
   - Screenshot the correct location after fixing

3. **Package Name Mismatch** 
   - applicationId doesn't match google-services.json
   - Shows Firebase Console relationship to app config
   - Screenshot both the error and Firebase console

4. **minSdk Version Error**
   - Firebase requires minSdk 21, project defaults to lower
   - Screenshot build error before and successful build after fix
   - Demonstrates Android compatibility requirements

5. **Firebase Initialization Async Error**
   - Forgetting `async`/`await` in main()
   - Runtime crash with clear stack trace
   - Shows importance of asynchronous initialization

**Tips for Great Documentation**:
- ✅ Take screenshot of error IMMEDIATELY when it occurs
- ✅ Include full error message, not just highlighted part
- ✅ Show your solution (code before and after)
- ✅ Explain what you learned from the error
- ✅ Be honest - professors value learning over perfection!ed and saved

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
