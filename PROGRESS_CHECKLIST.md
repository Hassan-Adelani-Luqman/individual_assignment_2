# Progress Checklist - Kigali City Services Directory

## ✅ Phase Completion Tracker

### Phase 1: Project Setup ☐
- [ ] Flutter project created
- [ ] Dependencies added to pubspec.yaml
- [ ] Folder structure created
- [ ] Git initialized with first commit
- [ ] Theme file created

### Phase 2: Firebase Configuration ☐
- [ ] Firebase project created in console
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore database created
- [ ] google-services.json downloaded (Android)
- [ ] GoogleService-Info.plist downloaded (iOS)
- [ ] Android configuration updated
- [ ] Firebase initialized in main.dart
- [ ] Firestore collections planned
- [ ] Security rules configured
- [ ] **Commit #2 made**

### Phase 3: Authentication ☐
- [ ] UserModel created
- [ ] AuthService implemented with all methods
- [ ] Email verification enforced
- [ ] Error handling implemented
- [ ] **Commit #3 made**

### Phase 4: State Management ☐
- [ ] Provider added to dependencies
- [ ] AuthProvider created with ChangeNotifier
- [ ] Auth state management working
- [ ] Loading/error states handled
- [ ] MultiProvider setup in main.dart
- [ ] AuthWrapper created
- [ ] **Commit #4 made**

### Phase 5: Firestore Service ☐
- [ ] ListingModel created with fromFirestore/toFirestore
- [ ] FirestoreService created
- [ ] getAllListingsStream() implemented
- [ ] getUserListingsStream() implemented
- [ ] createListing() implemented
- [ ] updateListing() implemented
- [ ] deleteListing() implemented
- [ ] searchListings() implemented
- [ ] getListingsByCategory() implemented
- [ ] ListingsProvider created
- [ ] Real-time listeners working
- [ ] Search/filter logic in provider
- [ ] **Commit #5 made**

### Phase 6: Authentication UI ☐
- [ ] AppTheme created with dark blue/gold colors
- [ ] LoginScreen created
- [ ] SignupScreen created
- [ ] EmailVerificationScreen created
- [ ] Form validation working
- [ ] Loading indicators implemented
- [ ] Error messages displayed
- [ ] Navigation between auth screens working
- [ ] **Commit #6 made**

### Phase 7: Directory & CRUD UI ☐
- [ ] AppConstants with categories created
- [ ] DirectoryScreen created
- [ ] Search bar implemented
- [ ] Category filter chips implemented
- [ ] Real-time listing display working
- [ ] ListingCard widget created
- [ ] CreateListingScreen created
- [ ] EditListingScreen created
- [ ] MyListingsScreen created
- [ ] Form validation for listings
- [ ] Create operation working
- [ ] Update operation working (own listings only)
- [ ] Delete operation working (own listings only)
- [ ] Empty states handled
- [ ] Loading states shown
- [ ] **Commit #7 made**

### Phase 8: Map Integration ☐
- [ ] Google Maps API key obtained
- [ ] API key added to AndroidManifest.xml
- [ ] API key added to Info.plist
- [ ] google_maps_flutter package configured
- [ ] ListingDetailScreen created
- [ ] Embedded map showing on detail page
- [ ] Marker placed at correct coordinates
- [ ] Navigation button implemented
- [ ] url_launcher working to open Google Maps
- [ ] MapViewScreen created (showing all listings)
- [ ] Location permissions handled
- [ ] **Commit #8 made**

### Phase 9: Navigation & Settings ☐
- [ ] BottomNavigation widget created
- [ ] 4 screens accessible (Directory, My Listings, Map, Settings)
- [ ] Current tab highlighted
- [ ] SettingsScreen created
- [ ] User profile displayed
- [ ] Notification toggle implemented
- [ ] SharedPreferences for settings
- [ ] Logout button working
- [ ] **Commit #9 made**

### Phase 10: Polish & Testing ☐
- [ ] UI matches reference design
- [ ] All screens responsive
- [ ] Empty states designed
- [ ] Error states designed
- [ ] Loading states smooth
- [ ] Tested signup flow
- [ ] Tested email verification
- [ ] Tested login flow
- [ ] Tested create listing
- [ ] Tested edit listing
- [ ] Tested delete listing
- [ ] Tested search functionality
- [ ] Tested category filter
- [ ] Tested map navigation
- [ ] Tested on emulator/device (NOT browser)
- [ ] **Commit #10 made**

---

## 📚 Documentation Checklist

### README.md ☐
- [ ] Project title and description
- [ ] Features list
- [ ] Firebase setup instructions
- [ ] Firestore database structure explained
- [ ] Collections schema documented
- [ ] State management approach explained (Provider)
- [ ] Installation instructions
- [ ] How to run the app
- [ ] Folder structure explanation
- [ ] Architecture diagram (optional but impressive)
- [ ] Screenshots (optional)

### Reflection PDF ☐
- [ ] Title page with name and project title
- [ ] Introduction paragraph
- [ ] Error #1 documented with screenshot
- [ ] Solution #1 explained
- [ ] Error #2 documented with screenshot
- [ ] Solution #2 explained
- [ ] Additional errors (optional for bonus points)
- [ ] Lessons learned section
- [ ] Challenges faced section
- [ ] What worked well section
- [ ] Conclusion

### Design Summary Document ☐
- [ ] Title page
- [ ] Firestore database schema section
- [ ] Collections diagram/explanation
- [ ] Document structure for users collection
- [ ] Document structure for listings collection
- [ ] Relationships between collections
- [ ] State management section
- [ ] Provider architecture explanation
- [ ] Data flow diagram (Firestore → Service → Provider → UI)
- [ ] Design decisions section
- [ ] Trade-offs explained
- [ ] Technical challenges section
- [ ] Solutions implemented
- [ ] Future improvements section (optional)

---

## 🎥 Demo Video Checklist (7-12 minutes)

### Pre-Recording Setup ☐
- [ ] Screen recording software ready (OBS, QuickTime, etc.)
- [ ] Emulator/Device running app
- [ ] Firebase Console open in browser
- [ ] VS Code open with project code
- [ ] Internet connection stable
- [ ] Microphone tested
- [ ] Practice run completed

### Video Content Checklist ☐

**1. Introduction (1 min)** ☐
- [ ] Introduce yourself
- [ ] State project name
- [ ] Show Firebase Console dashboard
- [ ] Briefly explain app purpose

**2. Authentication Demo (1.5 min)** ☐
- [ ] Show AuthService code (signup method)
- [ ] Perform signup with new email
- [ ] Show user created in Firebase Console
- [ ] Show email verification enforcement code
- [ ] Show EmailVerificationScreen
- [ ] Verify email and login
- [ ] Show successful login

**3. Create Listing Demo (45 sec)** ☐
- [ ] Show CreateListingScreen code
- [ ] Show FirestoreService createListing() method
- [ ] Show ListingsProvider createListing() method
- [ ] Fill out create form in app
- [ ] Submit new listing
- [ ] Show listing appear in Firebase Console
- [ ] Show listing appear in Directory screen (real-time)

**4. Read Listings Demo (30 sec)** ☐
- [ ] Show DirectoryScreen code
- [ ] Show Provider consumption (Consumer widget)
- [ ] Show real-time listener in ListingsProvider
- [ ] Show all listings displaying
- [ ] Explain how real-time updates work

**5. Update Listing Demo (45 sec)** ☐
- [ ] Open My Listings screen
- [ ] Show EditListingScreen code
- [ ] Show updateListing() method code
- [ ] Edit one of your listings
- [ ] Save changes
- [ ] Show update in Firebase Console
- [ ] Show update reflected in Directory (real-time)

**6. Delete Listing Demo (30 sec)** ☐
- [ ] Show deleteListing() method code
- [ ] Delete a listing from My Listings
- [ ] Show deletion in Firebase Console
- [ ] Show listing removed from Directory (real-time)

**7. Search Demo (30 sec)** ☐
- [ ] Show search implementation code
- [ ] Type in search bar
- [ ] Show filtered results
- [ ] Clear search

**8. Category Filter Demo (30 sec)** ☐
- [ ] Show filter implementation code
- [ ] Click different category chips
- [ ] Show filtered results updating

**9. Detail Page & Map Demo (1 min)** ☐
- [ ] Show ListingDetailScreen code
- [ ] Show GoogleMap widget configuration
- [ ] Open a listing detail page
- [ ] Show embedded map with marker
- [ ] Explain coordinate source (from Firestore)
- [ ] Click navigation button
- [ ] Show Google Maps opening

**10. Map View Screen (30 sec)** ☐
- [ ] Navigate to Map View tab
- [ ] Show all listings as markers
- [ ] Click a marker

**11. Settings Demo (30 sec)** ☐
- [ ] Navigate to Settings
- [ ] Show SettingsScreen code
- [ ] Show user profile info
- [ ] Toggle notifications
- [ ] Show logout

**12. Architecture Explanation (1.5 min)** ☐
- [ ] Show folder structure in VS Code
- [ ] Explain models folder
- [ ] Explain services folder
- [ ] Explain providers folder
- [ ] Explain screens folder
- [ ] Show data flow: Firestore → FirestoreService → ListingsProvider → DirectoryScreen
- [ ] Explain separation of concerns
- [ ] Highlight that NO Firebase calls in UI

**13. Conclusion (30 sec)** ☐
- [ ] Summarize key features
- [ ] Mention state management approach
- [ ] Thank viewer

### Post-Recording ☐
- [ ] Video edited (if needed)
- [ ] Duration is 7-12 minutes
- [ ] Video exported
- [ ] Video uploaded (YouTube, Google Drive, etc.)
- [ ] Video link added to submission PDF
- [ ] Video accessible (not private)

---

## 📊 Points Verification Checklist

### State Management (10 pts) ☐
- [ ] Provider/Riverpod/Bloc used throughout
- [ ] ALL Firestore operations in service layer
- [ ] NO direct Firebase calls in UI widgets
- [ ] Loading states handled in all CRUD ops
- [ ] Error states handled in all CRUD ops
- [ ] Success states handled in all CRUD ops
- [ ] Can explain in video how data flows
- [ ] Can show service/provider code in video
- [ ] UI rebuilds automatically on Firestore changes
- [ ] Demo shows Firebase Console updating in real-time

### Code Quality (7 pts) ☐
- [ ] ≥10 commits made
- [ ] Commit messages are meaningful
- [ ] Each commit shows progressive development
- [ ] README is comprehensive
- [ ] Firebase setup explained in README
- [ ] Firestore collections explained in README
- [ ] State management approach explained in README
- [ ] Navigation structure explained in README
- [ ] Folder structure is clean
- [ ] Files properly organized
- [ ] Can explain folder structure in video
- [ ] Can show how files connect in video

### Authentication (5 pts) ☐
- [ ] Signup working with Firebase Auth
- [ ] Login working
- [ ] Logout working
- [ ] Email verification ENFORCED
- [ ] Cannot access app without verified email
- [ ] User profile created in Firestore
- [ ] User profile includes UID
- [ ] Can explain auth flow in video
- [ ] Can show auth implementation code in video
- [ ] Firebase Console shows verified users in video

### CRUD Operations (5 pts) ☐
- [ ] Create listing working
- [ ] Read all listings working
- [ ] Update listing working (own listings only)
- [ ] Delete listing working (own listings only)
- [ ] All fields included (name, category, address, contact, description, lat, lng, createdBy, timestamp)
- [ ] Changes reflect immediately in UI
- [ ] Directory updates in real-time
- [ ] My Listings updates in real-time
- [ ] Can explain each CRUD operation in video
- [ ] Can show Firestore service code in video

### Search & Filter (4 pts) ☐
- [ ] Search by name working
- [ ] Category filter working
- [ ] Both can work together
- [ ] Results update dynamically
- [ ] Backed by Firestore (not just local)
- [ ] Can explain implementation in video
- [ ] Can show filter code in video

### Map Integration (5 pts) ☐
- [ ] Detail page includes embedded map
- [ ] Map shows marker at correct location
- [ ] Location from Firestore coordinates
- [ ] Navigation button present
- [ ] Navigation launches Google Maps
- [ ] Turn-by-turn directions work
- [ ] Can explain map integration in video
- [ ] Can show map widget code in video
- [ ] Can show coordinate retrieval from Firestore in video

### Navigation & Settings (4 pts) ☐
- [ ] BottomNavigationBar implemented
- [ ] Directory screen accessible
- [ ] My Listings screen accessible
- [ ] Map View screen accessible
- [ ] Settings screen accessible
- [ ] Settings shows user profile
- [ ] Settings has notification toggle
- [ ] Toggle works (saves preference)
- [ ] Can explain navigation logic in video

### Deliverables (5 pts) ☐
- [ ] Reflection PDF created
- [ ] Reflection includes ≥2 Firebase errors
- [ ] Errors have screenshots
- [ ] Solutions explained clearly
- [ ] Design Summary created (1-2 pages)
- [ ] Design Summary explains Firestore schema
- [ ] Design Summary explains state management
- [ ] Design Summary mentions trade-offs/challenges
- [ ] GitHub repository link included
- [ ] Referenced in demo video

### Demo Video Quality (5 pts) ☐
- [ ] Duration is 7-12 minutes
- [ ] ALL major features demonstrated
- [ ] Authentication flow shown
- [ ] All CRUD operations shown
- [ ] Search/filter shown
- [ ] Map integration shown
- [ ] Implementation code shown for EACH feature
- [ ] Firebase Console shown concurrently
- [ ] Backend updates visible
- [ ] Architecture explained
- [ ] State management flow explained
- [ ] Folder structure shown
- [ ] Can clearly see code on screen
- [ ] Audio is clear
- [ ] Explanations are thorough

---

## 🚨 Final Pre-Submission Check

### Critical Requirements ☐
- [ ] App runs on emulator or physical device (NOT browser)
- [ ] All commits pushed to GitHub
- [ ] Repository is public or accessible
- [ ] No Firebase credentials exposed in code
- [ ] Code is original (not >50% AI-generated)
- [ ] All deliverables in single PDF:
  - [ ] Reflection section
  - [ ] GitHub repository link
  - [ ] Demo video link
  - [ ] Design Summary section

### Quality Assurance ☐
- [ ] Test signup flow one more time
- [ ] Test all CRUD operations one more time
- [ ] Test search and filter one more time
- [ ] Test map and navigation one more time
- [ ] Verify Firebase Console shows all data
- [ ] Verify video is accessible
- [ ] Verify GitHub repo is accessible
- [ ] Read through entire submission PDF
- [ ] Check for typos and errors

---

## 🎯 Estimated Points Breakdown

Based on this checklist:
- State Management: **10/10** (if all service layer separation is perfect)
- Code Quality: **7/7** (if ≥10 commits + good README)
- Authentication: **5/5** (if email verification enforced)
- CRUD Operations: **5/5** (if all 4 operations work with real-time updates)
- Search & Filter: **4/4** (if both work dynamically)
- Map Integration: **5/5** (if detail map + navigation work)
- Navigation & Settings: **4/4** (if all 4 screens + toggle work)
- Deliverables: **5/5** (if all docs are thorough)
- Demo Video: **5/5** (if 7-12 min + shows code + Firebase Console)

**Total: 50/50** ✅

---

## 📝 Notes Section

Use this space to track specific errors you encounter (for Reflection PDF):

### Error #1:
**Error:** 
**Screenshot:** 
**Solution:** 

### Error #2:
**Error:** 
**Screenshot:** 
**Solution:** 

### Error #3 (Optional):
**Error:** 
**Screenshot:** 
**Solution:** 

---

**Remember:** Quality over quantity. Focus on clean architecture, proper state management, and thorough documentation. Good luck! 🚀
