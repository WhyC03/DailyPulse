# Firebase Configuration Setup

## Required Firebase Setup

To run the DailyPulse app, you need to set up Firebase with the following services:

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Follow the setup wizard

### 2. Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" authentication

### 3. Enable Cloud Firestore
1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for development)
4. Select a location for your database

### 4. Add Android App
1. In Firebase Console, click "Add app" → Android
2. Enter package name: `com.example.dailypulse`
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

### 5. Add iOS App (if needed)
1. In Firebase Console, click "Add app" → iOS
2. Enter bundle ID: `com.example.dailypulse`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

### 6. Update Android Build Files

Add to `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

### 7. Firestore Security Rules

Update your Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own mood entries
    match /mood_entries/{entryId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
  }
}
```

## Testing the Setup

After completing the setup:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `flutter run`

The app should now connect to Firebase successfully!
