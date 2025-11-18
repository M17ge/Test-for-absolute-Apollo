# Setup Guide for Apollo Agriculture

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (version 3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Dart SDK** (included with Flutter)

3. **IDE** (choose one):
   - Android Studio (recommended for Android development)
   - VS Code with Flutter extensions
   - IntelliJ IDEA

4. **Git** for version control

5. **Firebase Account**
   - Create a free account at https://firebase.google.com

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/M17ge/Test-for-absolute-Apollo.git
cd Test-for-absolute-Apollo
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### A. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name your project (e.g., "Apollo Agriculture")
4. Follow the setup wizard

#### B. Enable Firebase Services

In your Firebase project console:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password" authentication

2. **Cloud Firestore**
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode (change to production rules later)
   - Choose a location

3. **Storage**
   - Go to Storage
   - Click "Get started"
   - Start in test mode

#### C. Add Firebase to Your App

**For Android:**

1. In Firebase Console, click "Add app" > Android
2. Register app with package name: `com.apolloagro.app`
3. Download `google-services.json`
4. Place it in `android/app/` directory

**For iOS:**

1. In Firebase Console, click "Add app" > iOS
2. Register app with bundle ID: `com.apolloagro.app`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

**For Web:**

1. In Firebase Console, click "Add app" > Web
2. Register your web app
3. Copy the configuration
4. Create `lib/firebase_options.dart` from the template and add your config

#### D. Configure Firebase Options

1. Copy the template file:
   ```bash
   cp lib/firebase_options_template.dart lib/firebase_options.dart
   ```

2. Edit `lib/firebase_options.dart` with your Firebase project credentials

### 4. Firestore Security Rules

In Firebase Console > Firestore > Rules, add these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['inventoryManager', 'admin'];
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.farmerId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['dispatchManager', 'driver', 'admin']);
    }
    
    // Credits collection
    match /credits/{creditId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.farmerId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['financeManager', 'admin']);
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.farmerId || 
         request.auth.uid == resource.data.trainerId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

### 5. Run the App

**Check Flutter Setup:**
```bash
flutter doctor
```

**Run on Android/iOS:**
```bash
flutter run
```

**Run on Web:**
```bash
flutter run -d chrome
```

**Build for Production:**

Android:
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

iOS:
```bash
flutter build ios --release
```

Web:
```bash
flutter build web --release
```

## Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test
```

## Troubleshooting

### Common Issues

1. **Firebase not initialized**
   - Ensure `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
   - Run `flutter clean` and `flutter pub get`

2. **Build errors**
   - Make sure all dependencies are up to date: `flutter pub upgrade`
   - Check Flutter version: `flutter --version`
   - Clean build: `flutter clean`

3. **Authentication not working**
   - Verify Firebase Authentication is enabled in Firebase Console
   - Check that email/password sign-in method is enabled

4. **Firestore permission denied**
   - Update Firestore security rules as shown above
   - Ensure user is authenticated before accessing data

## Initial Data Setup

To populate initial data:

1. Create an admin user through the app signup
2. Manually update the user's role in Firestore Console to 'admin'
3. Use the admin portal to add products, manage users, etc.

## Deployment

### Android
1. Configure signing in `android/app/build.gradle`
2. Build release APK/Bundle
3. Upload to Google Play Console

### iOS
1. Configure signing in Xcode
2. Build release app
3. Upload to App Store Connect

### Web
1. Build web version: `flutter build web --release`
2. Deploy `build/web` folder to hosting service (Firebase Hosting, Netlify, Vercel, etc.)

For Firebase Hosting:
```bash
firebase init hosting
firebase deploy
```

## Support

For issues or questions:
- Open an issue on GitHub
- Check Flutter documentation: https://flutter.dev/docs
- Check Firebase documentation: https://firebase.google.com/docs
