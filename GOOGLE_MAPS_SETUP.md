# Google Maps API Setup Guide (Updated March 2026)

## Prerequisites

⚠️ **IMPORTANT**: Google Maps Platform requires billing to be enabled, even for free tier ($200/month credit). You won't be charged unless you exceed the free quota.

---

## Step 1: Enable Billing on Google Cloud

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Navigate to **Billing** in the left sidebar
4. Click **Link a billing account** or **Create billing account**
5. Add a payment method (credit/debit card)
6. ✅ You get **$200/month free credit** - sufficient for development

---

## Step 2: Enable Required APIs

Navigate to **APIs & Services** → **Library** and enable these APIs:

### Required APIs:
1. ✅ **Maps SDK for Android** - Display maps on Android
2. ✅ **Geocoding API** - Convert addresses ↔ coordinates (used by your app)
3. ✅ **Geolocation API** - Get device location (used by your app)
4. ✅ **Maps JavaScript API** - For web support (if needed)

### Optional APIs:
- **Places API** - Autocomplete search (future enhancement)
- **Directions API** - Turn-by-turn navigation (future enhancement)

**How to enable:**
- Search for each API by name
- Click on it
- Click **ENABLE** button
- Wait for activation (takes 5-10 seconds)

---

## Step 3: Create API Key

1. Navigate to **APIs & Services** → **Credentials**
2. Click **+ CREATE CREDENTIALS** → **API Key**
3. Copy the generated API key (starts with `AIzaSy...`)
4. **IMPORTANT**: Don't close this tab yet!

---

## Step 4: Configure API Key Restrictions (REQUIRED for Security)

### Get Your SHA-1 Fingerprint (Required):

**For Debug Keystore (Development):**
```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Mac/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release Keystore (Production):**
```bash
keytool -list -v -keystore /path/to/your-release-key.keystore -alias your-alias-name
```

Copy the **SHA-1** fingerprint (looks like: `50:24:9D:4B:D3:42:73:B3:D4:5B:9E:CB:52:BC:22:38:16:B7:CF:70`)

### Configure Restrictions:

1. In Google Cloud Console, click on your newly created API key
2. Under **Application restrictions**:
   - Select **Android apps**
   - Click **+ ADD AN ITEM**
   - Enter package name: `com.example.individual_assignment_2`
   - Enter your SHA-1 fingerprint
   - Click **DONE**
3. Under **API restrictions**:
   - Select **Restrict key**
   - Check these APIs:
     - ✅ Maps SDK for Android
     - ✅ Geocoding API
     - ✅ Geolocation API
4. Click **SAVE** at the bottom

⚠️ **Note**: For development, you can initially select "Don't restrict key" to test, but **always add restrictions for production**.

---

## Step 5: Add API Key to Android App

Open `android/app/src/main/AndroidManifest.xml` and locate this section:

```xml
<!-- Google Maps API Key -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

Replace `YOUR_API_KEY_HERE` with your actual API key.

**Current API key in your app:** `AIzaSyB6t5a0b3Wjdh8f1xOU3zTSKduRecqBbVY`

---

## Step 6: Verify Setup

### Check API Key Validity:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** → **Credentials**
3. Find your API key and check:
   - ✅ Status shows "Active" (not "Disabled")
   - ✅ Restrictions match your SHA-1 and package name
   - ✅ All required APIs are enabled

### Check Billing:
1. Navigate to **Billing** → **Overview**
2. Verify billing account is linked
3. Check usage under **Reports** (should show API calls after testing)

---

## Step 7: Test in Your App

1. **Clean and rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Test Map Views:**
   - Navigate to **Map** tab in bottom navigation
   - Tap a listing to see detail screen with embedded map
   - Check if markers appear for all listings

3. **Expected Result:**
   - Map displays with Kigali centered
   - Markers show for all listings
   - Tapping marker shows listing info
   - No "Authorization failure" errors

---

## Troubleshooting (Updated 2026)

### ❌ Map shows blank/gray screen

**Causes & Solutions:**

1. **Billing not enabled**
   - Go to Billing → Link billing account
   - Verify payment method is valid

2. **APIs not enabled**
   - Check all 3 required APIs are enabled:
     - Maps SDK for Android ✓
     - Geocoding API ✓
     - Geolocation API ✓

3. **API key incorrect**
   - Verify key in AndroidManifest.xml matches Google Cloud Console
   - Check for typos or extra spaces

4. **Wait time**
   - After enabling APIs/billing, wait 5-10 minutes for propagation

### ❌ "Authorization failure" or "Google Maps Platform rejected your request"

**Check Logcat for exact error:**
```bash
adb logcat | grep -i "maps\|authorization"
```

**Common causes:**

1. **SHA-1 fingerprint mismatch**
   - Get your current SHA-1: `keytool -list -v -keystore ~/.android/debug.keystore ...`
   - Add it to API key restrictions in Google Cloud Console
   - For **Windows**: Use `%USERPROFILE%\.android\debug.keystore`

2. **Package name mismatch**
   - Verify in `android/app/build.gradle.kts`: `applicationId = "com.example.individual_assignment_2"`
   - Must match package name in API key restrictions

3. **API restrictions too strict**
   - Temporarily remove all restrictions (for testing only)
   - If map works → SHA-1 or package name is wrong
   - Re-add restrictions with correct values

### ❌ App crashes when opening map

**Solutions:**

1. **Update Google Play Services on emulator:**
   - Open Play Store in emulator
   - Search "Google Play Services"
   - Update to latest version

2. **Check package version compatibility:**
   ```bash
   flutter pub outdated
   ```
   - Ensure `google_maps_flutter` is up to date

3. **Clean build:**
   ```bash
   flutter clean
   cd android && ./gradlew clean
   cd .. && flutter pub get
   flutter run
   ```

### ❌ Markers not showing on map

**Check these:**

1. **Listings have valid coordinates**
   - Latitude should be around -1.9 to -2.0 (Kigali)
   - Longitude should be around 30.0 to 30.1 (Kigali)

2. **Check debugPrint logs:**
   ```
   🗺️ onMapCreated fired!
   🔄 Refreshing markers for X listings
   📍 Listing name: (lat, lng)
   ✅ Markers updated: X total
   ```

3. **Verify in Firebase:**
   - Check Firestore console
   - Ensure listings exist with latitude/longitude fields

---

## Security Best Practices (2026)

### ✅ DO:
- ✅ Enable billing (required)
- ✅ Add SHA-1 restrictions for Android
- ✅ Restrict key to specific APIs only
- ✅ Use different API keys for debug/release builds
- ✅ Monitor usage in Google Cloud Console
- ✅ Set up budget alerts (prevent overage)

### ❌ DON'T:
- ❌ Share API keys publicly (e.g., GitHub)
- ❌ Use unrestricted keys in production
- ❌ Skip billing setup
- ❌ Forget to add all SHA-1s (debug + release)

---

## Cost Monitor (Free Tier - 2026)

**Your free credits:**
- $200/month free credit
- Covers ~28,000 map loads/month
- Covers ~40,000 geocoding requests/month

**Monitor usage:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **Billing** → **Reports**
3. Filter by "Maps" services
4. Set up alerts at 50%, 80%, and 90% of free tier

**Typical usage for this app:**
- Map views: ~100-500/day (development)
- Geocoding: ~50-100/day (when creating listings)
- **Total**: Well within free tier ✓

---

## Step 8: Verify Everything Works

### Final Checklist:

- [ ] Billing enabled with valid payment method
- [ ] Maps SDK for Android enabled
- [ ] Geocoding API enabled
- [ ] Geolocation API enabled
- [ ] API key created and copied
- [ ] API key added to AndroidManifest.xml
- [ ] SHA-1 fingerprint added to restrictions
- [ ] Package name matches restrictions
- [ ] App rebuilt with `flutter clean && flutter run`
- [ ] Map displays on Map tab
- [ ] Markers appear for listings
- [ ] Detail screen shows map with marker
- [ ] No authorization errors in logcat

**If all boxes checked:** ✅ Your Google Maps is properly configured!

**Still having issues?** Check logcat for specific errors:
```bash
adb logcat | grep -E "maps|authorization|google" > maps_log.txt
```
Then review maps_log.txt for error messages.
