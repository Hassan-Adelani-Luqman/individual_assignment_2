# Android Studio Setup Guide for Flutter Development

**Installation Date**: February 26, 2026  
**System**: Ubuntu 24.04.3 LTS  
**Purpose**: Enable Android emulation for Kigali Services Flutter project

---

## ✅ Step 1: Installation Complete

Android Studio has been installed via snap:
```bash
sudo snap install android-studio --classic
# Status: ✅ Installed (version 2025.1.3.7-wallpapers)
```

---

## 🚀 Step 2: Launch Android Studio (First Time Setup)

### 2.1 Start Android Studio
```bash
# Launch Android Studio
android-studio
```

**Or** search for "Android Studio" in your applications menu.

### 2.2 First Launch Wizard

When Android Studio opens for the first time, you'll see the **Setup Wizard**:

1. **Welcome Screen**
   - Click **"Next"**

2. **Install Type**
   - Select **"Standard"** installation
   - Click **"Next"**
   - This will install:
     - Android SDK
     - Android SDK Platform
     - Android Virtual Device (AVD)

3. **Select UI Theme**
   - Choose **"Darcula"** (dark) or **"Light"**
   - Click **"Next"**

4. **Verify Settings**
   - Review the components to be downloaded
   - Note the SDK location (usually `/home/hassan/Android/Sdk`)
   - Click **"Finish"**

5. **Downloading Components**
   - This will take 5-15 minutes depending on your internet speed
   - Android Studio will download:
     - Android SDK Tools
     - Android SDK Platform-Tools
     - Android SDK Build-Tools
     - Android Emulator
     - System Images
   - **Do not close Android Studio during this process!**

6. **Setup Complete**
   - Click **"Finish"** when download completes
   - You'll see the Android Studio welcome screen

### 📸 Screenshot This
Take a screenshot of the completed setup for your project documentation.

---

## 📱 Step 3: Create Android Virtual Device (AVD)

### 3.1 Open AVD Manager

**From Welcome Screen:**
- Click **"More Actions"** (three dots menu)
- Select **"Virtual Device Manager"**

**Or if you have a project open:**
- Go to **Tools → Device Manager**

### 3.2 Create New Virtual Device

1. **Click "Create Virtual Device"**

2. **Choose a Device**
   - Category: **Phone**
   - Select: **Pixel 6** (recommended) or **Pixel 7**
   - Resolution: 1080 x 2400
   - Click **"Next"**

3. **Select System Image**
   - **Recommended:** Select **API Level 34** (Android 14.0)
   - Release Name: **UpsideDownCake**
   - Target: **Android 14.0 (Google APIs)**
   - Click **"Download"** next to the system image (if not already downloaded)
   - Wait for download to complete (1-2 GB)
   - Click **"Next"**

4. **Configure AVD**
   - AVD Name: `Pixel_6_API_34` (or keep default)
   - Startup orientation: **Portrait**
   - **Advanced Settings** (optional):
     - RAM: 2048 MB (default is usually fine)
     - VM heap: 256 MB
     - Internal Storage: 2048 MB
     - SD card: 512 MB (optional)
   - Click **"Finish"**

### 3.3 Verify AVD Created

You should now see your AVD in the Device Manager list with:
- Name: Pixel 6 API 34
- Play Store icon
- Actions: Play button (▶️) to launch

---

## 🔧 Step 4: Configure Flutter to Use Android Studio

### 4.1 Set Environment Variables

Add Android SDK to your PATH:

```bash
# Open your .bashrc or .zshrc file
nano ~/.bashrc

# Add these lines at the end:
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

# Save and exit (Ctrl+X, Y, Enter)

# Reload your shell configuration
source ~/.bashrc
```

### 4.2 Accept Android Licenses

```bash
# Accept all Android SDK licenses
flutter doctor --android-licenses

# Type 'y' and press Enter for each license
```

### 4.3 Verify Flutter Configuration

```bash
# Check Flutter setup
flutter doctor -v
```

**Expected Output:**
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
    • Android SDK at /home/hassan/Android/Sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: [...]/android-studio/jbr/bin/java
    • All Android licenses accepted.
[✓] Android Studio (version 2025.1)
[✓] Connected device (1 available)
```

All sections should show **[✓]** (checkmarks). If any show **[!]** or **[✗]**, follow the suggestions provided.

---

## 🎮 Step 5: Test Emulator with Flutter

### 5.1 Launch Emulator from Command Line

```bash
# Navigate to your project
cd /home/hassan/flutter_linux_3.38.6-stable/individual_assignment_2

# List available emulators
flutter emulators

# Expected output:
# 1 available emulator:
# Pixel_6_API_34 • Pixel 6 API 34 • Google • android

# Launch the emulator
flutter emulators --launch Pixel_6_API_34
```

**Wait 1-2 minutes** for the emulator to fully boot.

### 5.2 Verify Device Connected

```bash
# Check connected devices
flutter devices
```

**Expected output:**
```
Found 3 connected devices:
  sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64  • Android 14 (API 34)
  Linux (desktop)              • linux         • linux-x64      • Ubuntu 24.04.3
  Chrome (web)                 • chrome        • web-javascript • Google Chrome 145.0
```

### 5.3 Run Your Flutter App

```bash
# Run on the emulator
flutter run

# Or specify the device explicitly
flutter run -d emulator-5554
```

**Expected Behavior:**
1. App builds successfully (1-3 minutes first build)
2. App installs on emulator
3. Firebase initializes: `[firebase_core] Successfully initialized Firebase`
4. App launches showing splash screen
5. You can interact with the app in the emulator

### 📸 Screenshot This
- Take a screenshot of the emulator running your app
- Take a screenshot of the terminal showing successful Firebase initialization
- **These prove Phase 2 is fully working!**

---

## 🐛 Troubleshooting Common Issues

### Issue 1: Emulator Won't Start

**Error**: "The emulator process has terminated"

**Solution**:
```bash
# Check hardware virtualization
egrep -c '(vmx|svm)' /proc/cpuinfo
# If output is 0, virtualization is disabled in BIOS

# Install KVM
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils

# Add user to kvm group
sudo adduser $USER kvm

# Log out and log back in, then try again
```

### Issue 2: Emulator is Slow

**Solution**:
1. Open AVD Manager
2. Click **Edit** (pencil icon) on your AVD
3. Click **"Show Advanced Settings"**
4. Under **Emulated Performance**:
   - Graphics: **Hardware - GLES 2.0**
   - Boot option: **Cold boot**
5. Increase RAM to **3072 MB** if you have 8GB+ RAM
6. Click **"Finish"**

### Issue 3: "ANDROID_HOME not set"

**Solution**:
```bash
# Verify SDK location
ls ~/Android/Sdk

# If exists, add to .bashrc again
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools

# Reload
source ~/.bashrc

# Verify
echo $ANDROID_HOME
# Should output: /home/hassan/Android/Sdk
```

### Issue 4: Flutter Can't Find Android SDK

**Solution**:
```bash
# Tell Flutter where Android SDK is
flutter config --android-sdk ~/Android/Sdk

# Verify
flutter doctor -v
```

### Issue 5: "Unable to locate adb"

**Solution**:
```bash
# adb is in platform-tools
export PATH=$PATH:$HOME/Android/Sdk/platform-tools

# Verify adb works
adb version

# Test adb connection to emulator
adb devices
```

---

## 📋 Quick Command Reference

```bash
# Launch Android Studio
android-studio

# List Flutter emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch Pixel_6_API_34

# Check connected devices
flutter devices

# Run app on emulator
flutter run

# Run with device selection
flutter run -d emulator-5554

# Kill all running emulators
adb kill-server
adb start-server

# Check Flutter doctor
flutter doctor -v

# Accept Android licenses
flutter doctor --android-licenses

# Clean Flutter project
flutter clean

# Get dependencies
flutter pub get

# Build Android APK
flutter build apk

# Install APK on device
flutter install
```

---

## ✅ Setup Verification Checklist

After completing all steps, verify:

- [ ] Android Studio installed and launched successfully
- [ ] Android SDK downloaded (check: `ls ~/Android/Sdk`)
- [ ] AVD (Pixel 6 API 34) created and visible in Device Manager
- [ ] Environment variables set in `.bashrc`
- [ ] Android licenses accepted: `flutter doctor --android-licenses`
- [ ] `flutter doctor` shows all green checkmarks
- [ ] Emulator launches without errors
- [ ] `flutter devices` shows emulator as available device
- [ ] Flutter app runs on emulator successfully
- [ ] Firebase initialization message appears in logs
- [ ] App is interactive in emulator

**Once all items are checked:** You have a fully functional Android development environment! 🎉

---

## 🎯 Next Steps for Your Project

Now that Android Studio is set up:

### Immediate Actions
1. ✅ Launch emulator: `flutter emulators --launch Pixel_6_API_34`
2. ✅ Run your app: `flutter run`
3. 📸 Take screenshots of:
   - Emulator running your app
   - Terminal showing Firebase initialization success
   - Any interactions in the app
4. ✅ Update `ERROR_DOCUMENTATION.md`:
   - Document how you resolved the emulator issues
   - Add screenshots of successful setup
   - Note: "Error #2 RESOLVED by installing Android Studio"

### Ready for Phase 3
With working emulation, you can now:
- Test Firebase authentication in real-time
- See UI changes immediately
- Debug with Android Studio's tools
- Test CRUD operations with Firestore
- Verify map integration with Google Maps

---

## 📚 Additional Resources

- **Android Studio Documentation**: https://developer.android.com/studio/intro
- **Flutter Android Setup**: https://docs.flutter.dev/get-started/install/linux#android-setup
- **AVD Manager Guide**: https://developer.android.com/studio/run/managing-avds
- **Emulator Documentation**: https://developer.android.com/studio/run/emulator
- **Flutter Doctor Guide**: https://docs.flutter.dev/get-started/install/linux#run-flutter-doctor

---

## 🔥 Pro Tips

1. **Keep Emulator Running**: Once the emulator is running, keep it open while developing. Hot reload works instantly!

2. **Use Hot Reload**:
   ```bash
   # While app is running, press:
   r  # Hot reload (reloads changed code)
   R  # Hot restart (restarts entire app)
   q  # Quit
   ```

3. **Android Studio Benefits**:
   - Open your Flutter project in Android Studio
   - Get code completion, suggestions, and refactoring
   - Use visual layout editor
   - Debug with breakpoints
   - View logs with Logcat
   - Profile app performance

4. **Multiple Emulators**:
   - You can create multiple AVDs (different Android versions)
   - Useful for testing compatibility
   - Each uses ~2-4 GB disk space

5. **Physical Device Alternative**:
   - Often faster than emulator
   - Enable USB Debugging on your Android phone
   - Connect via USB
   - Run `flutter devices` - phone will appear
   - Run `flutter run` - it will deploy to phone

---

## ⚠️ KVM/Hardware Acceleration Issues

### Problem: "Your CPU does not support KVM extensions"

This means hardware virtualization is either:
- Disabled in BIOS/UEFI settings
- Not supported by your CPU
- System is running inside a virtual machine

### Impact
- Android emulator runs WITHOUT hardware acceleration
- **VERY SLOW** performance (10-20x slower)
- May freeze or be unusable for development

### Solutions (in order of preference):

#### **Solution 1: Use Physical Android Device** ⭐ BEST OPTION

**Advantages**: Fast, reliable, real-world testing  

**Steps**:
1. Enable Developer Options on your Android phone:
   - Go to **Settings → About Phone**
   - Tap **Build Number** 7 times
   - You'll see "You are now a developer!"

2. Enable USB Debugging:
   - Go to **Settings → System → Developer Options**
   - Toggle **USB Debugging** ON
   - Toggle **Install via USB** ON (optional but helpful)

3. Connect phone:
   ```bash
   # Connect phone via USB cable
   # On phone: Tap "Allow" when asked to authorize the computer
   
   # Verify connection
   adb devices
   # Should show: List of devices attached
   #              XXXXXXXX   device
   
   # Check Flutter recognizes it
   flutter devices
   ```

4. Run your app:
   ```bash
   cd /home/hassan/flutter_linux_3.38.6-stable/individual_assignment_2
   flutter run
   # Select your phone from the list
   ```

#### **Solution 2: Enable Virtualization in BIOS** (If Available)

**For HP EliteBook Folio 1040 G3**:

1. Restart computer
2. Press **F10** during boot to enter BIOS/UEFI
3. Navigate to **Security → System Security**
4. Find **Virtualization Technology (VTx)** or **Intel VT-x**
5. Set to **Enabled**
6. Save and Exit (F10)

After enabling:
```bash
# Verify KVM is now available
sudo kvm-ok
# Should say: "KVM acceleration can be used"

# Install KVM
sudo apt-get install qemu-kvm libvirt-daemon-system
sudo adduser $USER kvm

# Log out and back in
# Then recreate AVD with x86_64 image
```

#### **Solution 3: Create x86_64 AVD Without KVM** (Slow but Works)

**WARNING**: This will be VERY slow. Only use if you have no other option.

```bash
# Delete current ARM64 AVD
~/Android/Sdk/tools/bin/avdmanager delete avd -n Pixel_6_API_34

# Create new x86_64 AVD (command line method - faster for setup)
echo "no" | ~/Android/Sdk/cmdline-tools/latest/bin/avdmanager create avd \
  -n Pixel_6_API_34_x86 \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_6"

# Launch without KVM (add -no-accel flag)
~/Android/emulator/emulator -avd Pixel_6_API_34_x86 -no-accel -gpu swiftshader_indirect
```

**Note**: Emulator may take 10-15 minutes to boot and will be laggy.

---

**Setup Guide Complete!** 🎉

Your Android development environment is now configured. **STRONGLY RECOMMEND using a physical Android device for best experience.**
