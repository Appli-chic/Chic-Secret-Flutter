# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development Commands
- `flutter run` - Run the app on connected device/emulator
- `flutter run -d macos` - Run on macOS
- `flutter run -d chrome` - Run on web (Chrome)
- `flutter run -d android` - Run on Android
- `flutter run -d ios` - Run on iOS

### Build Commands
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build macos` - Build macOS app
- `flutter build windows` - Build Windows app

### Testing & Analysis
- `flutter test` - Run unit tests
- `flutter analyze` - Run static analysis using analysis_options.yaml
- `flutter doctor` - Check Flutter installation and dependencies

### Maintenance
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies

## Architecture

### Project Structure
This is a cross-platform Flutter password manager (Chic Secret) supporting iOS, Android, macOS, and Windows.

### Key Architecture Patterns
- **MVVM Pattern**: Each screen follows Model-View-ViewModel pattern
  - Screens are in `lib/feature/` with corresponding `_view_model.dart` files
  - ViewModels extend `ChangeNotifier` for state management
  - Use `Provider` package for dependency injection

- **Service Layer**: Business logic separated into services (`lib/service/`)
  - Database operations handled by service classes (e.g., `VaultService`, `EntryService`)
  - API communication in `lib/api/` directory

- **Repository Pattern**: Data access abstracted through services
  - SQLite database using `sqflite` package
  - Local encryption for sensitive data

### Core Components
- **Database Models**: `lib/model/database/` - Data entities (Vault, Entry, Category, etc.)
- **Services**: `lib/service/` - Business logic and data operations
- **API Layer**: `lib/api/` - Remote synchronization endpoints
- **UI Components**: `lib/component/` - Reusable UI widgets
- **Utils**: `lib/utils/` - Shared utilities (security, database, platform detection)

### Platform-Specific Implementation
- Platform detection via `ChicPlatform.isDesktop()`
- Separate app creation methods: `_createIosApp()`, `_createAndroidApp()`, `_createDesktopApp()`
- Desktop uses `window_manager` package for window management

### State Management
- Uses `Provider` package with `ChangeNotifier`
- Global providers: `ThemeProvider`, `SynchronizationProvider`
- Screen-specific ViewModels for local state

### Security Features
- Local encryption using `encrypt` package
- Biometric authentication via `local_auth`
- Secure storage with SQLite database
- Password generation and security analysis

### Cross-Platform Considerations
- iOS uses nested `CupertinoApp` within `MaterialApp`
- Desktop and Android use `MaterialApp` directly
- File operations use `file_picker` and `file_saver` packages
- Platform-specific UI adaptations throughout components

The app follows a feature-first organization where each major feature (vault, entry, category, etc.) has its own directory with screen, view model, and sub-features.