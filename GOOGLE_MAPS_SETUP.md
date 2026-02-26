# Google Maps API Setup Guide

## Step 1: Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (or create a new one)
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if testing on iOS)
   - Places API (optional, for autocomplete)

4. Create API Key:
   - Navigate to **APIs & Services** → **Credentials**
   - Click **+ CREATE CREDENTIALS** → **API Key**
   - Copy the generated API key

5. (Optional) Restrict your API key:
   - Click on the API key you just created
   - Under **Application restrictions**, select **Android apps**
   - Add your package name: `com.example.individual_assignment_2`
   - Get your SHA-1 fingerprint:
     ```bash
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```
   - Add the SHA-1 fingerprint

## Step 2: Add API Key to Android App

Open `android/app/src/main/AndroidManifest.xml` and locate this line:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyDummyKeyReplaceWithYourActualKey"/>
```

Replace `AIzaSyDummyKeyReplaceWithYourActualKey` with your actual API key.

## Step 3: Test

Run the app and navigate to any listing detail. You should see a map with a marker showing the location.

## Troubleshooting

### Map shows blank/gray
- Check if API key is correct
- Verify Maps SDK for Android is enabled in Google Cloud Console
- Check Logcat for error messages: `adb logcat | grep -i maps`

### "Authorization failure" error
- Make sure SHA-1 fingerprint is added to API key restrictions
- Or temporarily remove restrictions for testing

### App crashes on map screen
- Ensure `google_maps_flutter` plugin is properly installed
- Run `flutter clean && flutter pub get`
- Rebuild the app

## Note

For production apps, you should:
1. Use API key restrictions
2. Enable billing on Google Cloud (free tier includes $200/month credit)
3. Monitor API usage in Google Cloud Console
