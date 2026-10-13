# CRT Quiz — Campus Recruitment Training & Aptitude Prep

A production-quality Flutter application (Android + Web PWA) built for students preparing for Campus Placement Drives, CRT assessments, and corporate aptitude tests.

---

## Features

- **8 Complete Screens**:
  1. **Splash Screen**: Animated branded entrance with minimum 1.6s display time and auth-guard routing.
  2. **Login Screen**: Email & password authentication with form validation, forgot-password modal, and friendly error mapper.
  3. **Signup Screen**: Account registration, client-side validation, and instant Firestore user profile creation.
  4. **Home Screen**: Personalized greeting, live metrics (Quizzes taken, Average score, Best score), category filter chips, search, and responsive cards grid.
  5. **Profile Screen**: Initials avatar badge, editable display name, stats overview, password management, and attempt history records.
  6. **Quiz Screen**: Single-question focus, linear progress bar, live countdown timer with low-time warning, selectable option cards, question palette jump grid, and pop-confirmation exit guard.
  7. **Result Screen**: Circular accuracy gauge, performance badge (*Mastery*, *Passed*, *Needs Practice*), metric breakdown (Correct, Incorrect, Skipped, Time), and navigation CTAs.
  8. **Review Screen**: Complete question-by-question breakdown, filter by answer status (All, Correct, Incorrect, Skipped), correct vs chosen indicators, and solution explanations.
- **Design System**: Material 3 with Deep Indigo & Vibrant Teal palette, Poppins and Inter typography scale via Google Fonts, custom rounded cards, and responsive layout breakpoints (`<600px`, `600–1024px`, `>1024px`).
- **State Management**: Flutter Riverpod (`ProviderScope`, `StreamProvider`, `StateNotifierProvider`).
- **Routing**: Declarative navigation using `go_router`.
- **Offline / Sample Seeding**: Built-in sample quiz seeder ensuring tests are immediately available upon first load.

---

## Firebase Configuration & Security Rules

### 1. Enable Firebase Email/Password Authentication
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select project **`quiz-2193c`**.
3. Navigate to **Authentication** > **Sign-in method**.
4. Enable **Email/Password** provider and save.

### 2. Firestore Database & Security Rules
1. Navigate to **Firestore Database** > **Create database**.
2. Go to the **Rules** tab and paste the following security rules:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // User profile document & attempts subcollection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /attempts/{attemptId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }

    // Quizzes collection: readable by all authenticated users
    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // or restrict to admin
    }
  }
}
```

---

## Build & Run Commands

### Run Locally (Chrome Web / Android emulator)
```bash
flutter pub get
flutter run -d chrome
```

### Build Web Release
```bash
flutter build web --release
```
The output will be generated in `build/web/`.

### Build Android Release APK
```bash
flutter build apk --release
```
The output APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Project Structure

```
lib/
├── firebase_options.dart       # Multiplatform Firebase options
├── main.dart                   # Entry point with ProviderScope & Firebase init
├── models/                     # UserModel, QuizModel, QuestionModel, AttemptModel
├── providers/                  # Riverpod auth, quiz, session, and stats providers
├── router/                     # GoRouter route definitions & redirects
├── screens/                    # All 8 app pages
├── services/                   # AuthService, FirestoreService, QuizSeederService
├── theme/                      # AppColors, AppTextStyles, AppTheme
├── utils/                      # Constants, ErrorHelpers, ResponsiveHelper
└── widgets/                    # PrimaryButton, AppTextField, AppCard, EmptyState, etc.
```
