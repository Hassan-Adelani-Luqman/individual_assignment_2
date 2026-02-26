# Physical Android Device Setup for Flutter Testing

**Date**: February 26, 2026  
**Reason**: Emulator cannot run without KVM (BIOS password protected)  
**Solution**: Use physical Android device for testing

---

## 🔧 Quick Setup (5 Minutes)

### Step 1: Enable Developer Mode on Your Phone

1. Open **Settings** on your Android phone
2. Scroll down and tap **About Phone** (or **About Device**)
3. Find **Build Number**
4. **Tap "Build Number" 7 times** rapidly
5. You'll see a message: **"You are now a developer!"**
6. Enter your phone's PIN/password if prompted

---

### Step 2: Enable USB Debugging

1. Go back to **Settings**
2. Tap **System** (or **Additional Settings**)
3. Tap **Developer Options** (now visible)
4. Scroll down and find:
   - **USB Debugging** → Toggle **ON**
   - **Install via USB** → Toggle **ON** (if available)
   - **USB debugging (Security settings)** → Toggle **ON** (if available)
5. You'll see a warning - tap **OK**

---

### Step 3: Connect Phone to Computer

1. **Connect your phone via USB cable** to your laptop

2. **On your phone**: You'll see a popup:
   - "Allow USB debugging?"
   - "The computer's RSA key fingerprint is: ..."
   - Check **"Always allow from this computer"**
   - Tap **"Allow"** or **"OK"**

3. **Verify connection** in terminal:
```bash
# Check if phone is detected
~/Android/platform-tools/adb devices

# Expected output:
List of devices attached
XXXXXXXXXX      device
# (XXXXXXXXXX is your phone's serial number)
```

If you see **"unauthorized"** instead of **"device"**:
- Check your phone screen for the authorization popup
- Tap "Allow" on your phone
- Run `adb devices` again

---

### Step 4: Run Your Flutter App

```bash
# Navigate to project
cd /home/hassan/flutter_linux_3.38.6-stable/individual_assignment_2

# Check Flutter sees your phone
flutter devices

# Expected output should include your phone, something like:
# SM G998B (mobile) • XXXXXXXXXX • android-arm64 • Android 13 (API 33)

# Run the app
flutter run

# If multiple devices, select your phone from the list
# The app will build and install on your phone (2-3 minutes first time)
```

---

## ✅ Expected Results

1. **Terminal shows:**
   ```
   Launching lib/main.dart on [Your Phone Model] in debug mode...
   ✓ Built build/app/outputs/flutter-apk/app-debug.apk
   Installing build/app/outputs/flutter-apk/app.apk...
   [firebase_core] Successfully initialized Firebase
   ```

2. **On your phone:**
   - App installs automatically
   - App launches showing splash screen
   - Firebase connects successfully

3. **Hot Reload works:**
   - Make code changes in VS Code
   - Press `r` in terminal for hot reload
   - Changes appear instantly on phone

---

## 🐛 Troubleshooting

### Issue: "No devices detected"

```bash
# Check USB connection mode on phone
# Swipe down notification bar → Tap "USB for charging"
# Change to "File Transfer" or "PTP"

# Restart adb
~/Android/platform-tools/adb kill-server
~/Android/platform-tools/adb start-server
~/Android/platform-tools/adb devices
```

### Issue: "Device unauthorized"

- Check phone screen for authorization popup
- Tap "Always allow" and "OK"
- If popup doesn't appear:
  ```bash
  ~/Android/platform-tools/adb kill-server
  ~/Android/platform-tools/adb start-server
  ```

### Issue: "Insufficient permissions for device"

```bash
# Add udev rules for Android devices
sudo apt-get install android-sdk-platform-tools-common

# Or manually:
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="*", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules
```

### Issue: Phone won't install app ("Installation failed")

```bash
# Enable "Install from unknown sources" on phone
# Settings → Security → Unknown Sources → ON

# Or check for existing app and uninstall
~/Android/platform-tools/adb uninstall com.example.individual_assignment_2

# Then try flutter run again
```

---

## 📸 Screenshots to Take

For your project documentation:

1. **Developer Options enabled** on phone
2. **USB Debugging enabled** on phone  
3. **Terminal showing** `adb devices` with your phone listed
4. **Terminal showing** `flutter devices` with your phone
5. **Terminal showing** successful `flutter run` with Firebase initialization
6. **Your phone screen** showing the app running
7. **Firebase Console** showing your app connected

---

## 💡 Advantages of Physical Device Testing

✅ **Fast**: No slow emulator  
✅ **Reliable**: No crashes or freezing  
✅ **Real-world**: Test actual device performance  
✅ **Hot Reload**: Instant code updates  
✅ **Sensors**: Test GPS, camera, accelerometer on real hardware  
✅ **No KVM needed**: Works without virtualization  

---

## 🎯 Testing Your Kigali Services App

Once connected, you can test:

1. **Firebase Authentication**:
   - Sign up with email/password
   - Email verification
   - Login/logout

2. **Firestore CRUD**:
   - Create new listings
   - View all listings
   - Update your listings
   - Delete your listings

3. **Map Integration**:
   - GPS location on real device
   - Map displays correctly
   - Search for places

4. **Search & Filter**:
   - Search by name
   - Filter by category
   - Real-time updates

---

## ⚠️ Keep Phone Connected

While developing:
- Keep USB cable connected
- Keep phone unlocked (optional but helpful)
- Keep Developer Options enabled
- Hot reload works while phone is locked

---

## 📝 Phase 2 Completion

**With physical device:**
✅ Phase 2 (Firebase Configuration) - Can now be **FULLY TESTED**  
✅ Error documentation complete (3 errors + resolution)  
✅ Ready to proceed with Phase 3 (Authentication)

---

## 🔄 Alternative: Borrow an Android Device

If you don't own an Android phone:
- Borrow from a friend/family member (just for 30-60 minutes)
- Use it to test and take screenshots
- Return when done

---

**Your Flutter development environment is complete!**  
Just need a physical Android device to test. 🚀
