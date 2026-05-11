# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter mobile app (Igbo / Yoruba / Hausa learning) that talks to a FastAPI backend. The pubspec package is `LangGPT`; the user-facing app name is **KinSpeak** (`MaterialApp.title` and `AppStrings.appName`).

The backend base URL is hard-coded to `http://127.0.0.1:8001` in `lib/core/network/api_constants.dart`. Anything calling the API requires that backend to be running locally — running the Flutter app alone will hit timeouts on every protected screen.

## Common commands

```bash
flutter pub get                  # install dependencies
flutter run                      # run on the connected device/emulator
flutter run -d chrome            # run on web
flutter analyze                  # static analysis (uses analysis_options.yaml + flutter_lints)
flutter test                     # currently no tests committed (no test/ dir)
```

Code generation (Riverpod / Retrofit / json_serializable are declared in `dev_dependencies` but no `*.g.dart` files exist yet — run this once any annotated source is added):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch --delete-conflicting-outputs   # during active codegen work
```

## Architecture

### Layered (clean-ish) architecture per feature

Most features under `lib/features/<name>/` follow the same shape:

```
data/
  datasources/   # Dio calls — talk directly to the FastAPI backend
  models/        # JSON-serializable DTOs (hand-written fromJson/toJson, no codegen yet)
  repositories/  # *_repository_impl.dart — concrete implementations
domain/
  repositories/  # Abstract repository interfaces
presentation/
  providers/     # Riverpod StateNotifiers + state classes
screens/         # Top-level screen widgets
widgets/         # Feature-scoped widgets
```

Some older features (`auth/`, `home/`, `explore/`, `account/`) only have `screens/` plus partial layers — when adding logic to those, follow the data/domain/presentation pattern already used by `practice/`, `lessons/`, `quiz/`.

### Singletons everywhere

Repositories, remote datasources, the Dio client, and storage are exposed as private-ctor singletons accessed via `.instance` (e.g. `ApiClient.instance`, `AuthRepositoryImpl.instance`, `SecureStorageService.instance`). Riverpod providers wrap StateNotifiers but the underlying repos are not injected — they're grabbed from `.instance` inside the notifier. Keep this pattern when adding new repos; don't introduce a DI container partway.

### Networking

`lib/core/network/api_client.dart` builds the shared `Dio` and installs `_AuthInterceptor`, which:

1. Skips the `Authorization` header for `login`, `signup`, `googleAuth`, `refresh`.
2. On a 401, attempts **one** refresh using the stored refresh token, then retries the original request. If refresh fails, it clears all secure storage (effectively logging the user out).

`ApiClient.instance.initialize()` must be called from `main()` before `runApp` — `main.dart` already does this.

All endpoint paths live in `ApiConstants` (`api/v1/...`). Add new endpoints there rather than inlining strings.

### Auth & storage

Tokens and the cached user JSON are kept in `flutter_secure_storage` via `SecureStorageService` (encrypted shared prefs on Android). `SharedPreferences` is only used for non-sensitive UI prefs (currently the theme mode in `core/theme/theme_provider.dart`).

Google Sign-In uses a hard-coded `serverClientId` in `auth_repository_impl.dart` and sends the resulting ID token to `/auth/google` for the backend to exchange. The repo calls `_googleSignIn.signOut()` before every sign-in to force a fresh token under the right audience — keep that behavior.

### Routing

Routing is **manual** via `MaterialApp.onGenerateRoute` in `lib/main.dart` with route name constants in `AppRoutes` (`core/constants/app_constants.dart`). `go_router` is in pubspec but **not used yet** — when adding a new route, add it to both `AppRoutes` and the `switch` in `main.dart`. Routes that take args read them from `settings.arguments as Map<String, dynamic>` (see `lessonDetail`).

### Theming & design system

`core/constants/app_colors.dart`, `app_text_styles.dart`, `app_constants.dart` (sizes/strings/routes), and `core/theme/app_theme.dart` define the full design system. The Sora font is bundled in `assets/fonts/`. Light + dark themes are both wired; the active mode comes from `themeProvider` (Riverpod) backed by `SharedPreferences`. Prefer existing `AppColors`, `AppDimensions`, and `AppStrings` constants over magic values.

### Conversation/chat state

`features/practice/presentation/providers/conversation_provider.dart` keeps the full message list in memory and rebuilds the `conversation_history` list it sends to the backend **before** appending the new user message — the backend expects the new turn separately as `user_message`. Don't reorder that.

## Conventions

- Models use hand-written `fromJson` / `toJson`. Backend uses snake_case (`full_name`, `id_token`, `selected_language`, `date_of_birth`); Dart side uses camelCase — keep the mapping in the model.
- `print` is used for `[API]` request/response logging via the `LogInterceptor` — that's intentional.
- `flutter_lints` is enabled with no extra rule overrides; don't disable lints inline unless there's a specific reason.
