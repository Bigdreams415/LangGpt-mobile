# KinSpeak — Flutter Frontend

A production-quality Duolingo-style Flutter app for learning Igbo, Yoruba, and Hausa.

## Folder Structure

```
lib/
├── main.dart                          # App entry point + routing
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Complete design system colors
│   │   ├── app_text_styles.dart       # Typography using Sora font
│   │   └── app_constants.dart         # Strings, routes, dimensions
│   └── theme/
│       └── app_theme.dart             # Material 3 theme configuration
├── features/
│   ├── auth/
│   │   └── screens/
│   │       ├── get_started_screen.dart   # Onboarding / hero screen
│   │       ├── login_screen.dart         # Login with Google + email
│   │       ├── signup_step1_screen.dart  # Name, username, email
│   │       ├── signup_step2_screen.dart  # Password, DOB, country
│   │       └── signup_step3_screen.dart  # Language + level selection
│   ├── home/
│   │   └── screens/home_screen.dart      # Dashboard
│   ├── explore/
│   │   └── screens/explore_screen.dart   # Topic browser
│   ├── practice/
│   │   └── screens/practice_screen.dart  # Practice modes
│   └── account/
│       └── screens/account_screen.dart   # Profile + settings
├── navigation/
│   └── main_navigation.dart           # Bottom nav (Home/Explore/Practice/Account)
└── shared/
    └── widgets/
        ├── app_button.dart            # Reusable button (5 variants)
        └── app_text_field.dart        # Reusable form field

assets/
├── images/                            # App images
└── fonts/                             # Sora font files
```

## Design System

| Token | Value | Usage |
|---|---|---|
| Primary | `#2E8B57` Forest Green | Buttons, progress, active states |
| Secondary | `#CC5C3B` Terracotta | Accents, secondary actions |
| Accent Blue | `#1B4F8A` | Info, Hausa language color |
| Accent Yellow | `#F5C518` | XP, streak, highlights |
| Background | `#FAF8F3` Off-white/Cream | Scaffold background |
| Font | Sora | All text |

## Auth Flow

```
GetStarted → SignupStep1 (name/user/email)
                → SignupStep2 (password/DOB/country)
                   → SignupStep3 (language + level)
                      → MainNavigation

GetStarted → Login → MainNavigation
```

## Setup

1. **Install Flutter** (3.x or later): https://flutter.dev/docs/get-started/install

2. **Download Sora font** and add to `assets/fonts/`:
   - https://fonts.google.com/specimen/Sora
   - Download: Sora-Regular.ttf, Sora-Medium.ttf, Sora-SemiBold.ttf, Sora-Bold.ttf, Sora-ExtraBold.ttf

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## Navigation Tabs

| Tab | Screen | Description |
|---|---|---|
| 🏠 Home | `HomeScreen` | Dashboard, daily goal, continue lesson |
| 🔍 Explore | `ExploreScreen` | Browse all topics by language |
| 📚 Practice | `PracticeScreen` | Quiz, conversation, translation modes |
| 👤 Account | `AccountScreen` | Profile, progress, settings |

## Next Steps (Logic phase)

- [ ] Firebase Auth (email/password + Google Sign-In)
- [ ] Riverpod state management
- [ ] API service layer (Dio + Retrofit) connecting to FastAPI backend
- [ ] User progress persistence
- [ ] Actual quiz/lesson/conversation screens
- [ ] Push notifications (daily reminders)
- [ ] Offline mode
