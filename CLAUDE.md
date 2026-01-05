# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

```bash
# Get dependencies
flutter pub get

# Run the app (debug mode)
flutter run

# Run on specific platform
flutter run -d chrome      # Web
flutter run -d ios         # iOS simulator
flutter run -d android     # Android emulator

# Build for release
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze
dart analyze

# Run tests
flutter test

# Fix lint issues automatically
dart fix --apply

# Clean build artifacts
flutter clean
```

### Firebase Deployment
```bash
cd functions && npm install && firebase deploy --only functions
```

## Architecture Overview

This is a Flutter chat application ("Kvitter") with Firebase backend, supporting Android, iOS, and Web platforms.

### Project Structure

- **`lib/model/`** - Data models (ChatUser, Message, RoomChat, PrivateChat)
- **`lib/repository/`** - Firebase and data access layer
  - `firestore_repository.dart` - Main data repository (users, chats, messages, reports collections)
  - `login_repository.dart` - Authentication (Google, Apple sign-in)
  - `fcm_repository.dart` - Push notifications
  - `subscription_repository.dart` - RevenueCat subscriptions
  - `presence_database.dart` - Firebase Realtime Database for online status
- **`lib/screens/`** - Feature screens, each following BLoC pattern
- **`lib/utils/`** - Shared utilities (colors, dialogs, analytics, audio)
- **`functions/`** - Firebase Cloud Functions (Node.js)

### State Management Pattern

Each screen follows a consistent BLoC pattern with three files:
- `*_bloc.dart` - Business logic and event handling
- `*_event.dart` - Event definitions
- `*_state.dart` - State definitions

BLoCs use `mapEventToState` pattern with Equatable for state comparison.

### Key Dependencies

- **State Management**: flutter_bloc, provider
- **Backend**: Firebase suite (Auth, Firestore, Storage, Cloud Functions, FCM, Crashlytics)
- **Monetization**: purchases_flutter (RevenueCat), google_mobile_ads
- **Authentication**: google_sign_in, sign_in_with_apple
- **Internationalization**: flutter_i18n (translations in `assets/flutter_i18n/`)

### Platform-Specific Behavior

The app uses `kIsWeb` checks for platform-specific code paths:
- Mobile: RevenueCat subscriptions, mobile ads, FCM notifications
- Web: Alternative implementations via `WebOnlineUsersProcessor`

### Firebase Collections

- `users` - User profiles
- `chats` - Room chat metadata
- `privateChats` - Direct messages
- `messages` - Chat messages
- `reports` - User reports

## Code Style & Conventions

### State Management Philosophy

- UI is generated from Cubit/BLoC state
- Prefer `StatelessWidget` unless animations require `StatefulWidget`
- All state lives in Cubit and flows down via `BlocBuilder`/`BlocConsumer`
- Navigation logic lives in `BlocConsumer` listeners (not in widgets)

### State Management Migration

**Legacy code** uses BLoC with `mapEventToState` (three files: `*_bloc.dart`, `*_event.dart`, `*_state.dart`).

**New code should use Cubit pattern** (two files only):
- `*_cubit.dart` - Logic with methods instead of events
- `*_state.dart` - State class

When modifying existing screens, migrate from BLoC to Cubit if making significant changes.

### Cubit Pattern (Preferred)

```dart
// my_cubit.dart
class MyCubit extends Cubit<MyState> {
  final MyRepository _repository;

  MyCubit({required MyRepository repository})
      : _repository = repository,
        super(const MyState());

  Future<void> loadItems() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await _repository.getItems();
      emit(state.copyWith(items: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
    }
  }

  void clearError() => emit(state.clearError());
}
```

**State Class Structure**:
```dart
class MyState extends Equatable {
  final List<Item> items;
  final bool isLoading;
  final String? errorMessage;

  const MyState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [items, isLoading, errorMessage];

  MyState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  // Explicit method for clearing nullable fields
  MyState clearError() => MyState(items: items, isLoading: isLoading);
}

// Navigation states extend base state
class NavigateToDetail extends MyState {
  final Item item;
  NavigateToDetail({required this.item, required MyState state})
      : super(items: state.items, isLoading: state.isLoading);
}
```

### Screen Structure Pattern

```dart
// Screen provides Cubit
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyCubit(repository: context.read<MyRepository>()),
      child: const MyScreenBuilder(),
    );
  }
}

// Builder consumes Cubit
class MyScreenBuilder extends StatelessWidget {
  const MyScreenBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyCubit, MyState>(
      listener: (context, state) {
        // Handle navigation and side effects
        if (state is NavigateToDetail) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => DetailScreen(item: state.item),
          ));
        }
      },
      builder: (context, state) {
        return MyScreenContent(state: state);
      },
    );
  }
}
```

### Entities & Models

- All entities extend `Equatable`
- Include `copyWith()` for immutability
- Use `const` constructors with `final` fields
- Include `toJson()`/`fromJson()` for Firestore serialization

### Theme & Styling

- Use `AppColors` constants from `utils/app_colors.dart` - never hardcode colors
- Use `Theme.of(context).textTheme.*` for text styles
- Material 3 design with Google Fonts (Lobster for titles)

### Code Formatting

- Trailing commas for multi-line arguments
- Use `const` constructors wherever possible
- Prefer `final` over `var`
- Private fields/methods prefixed with `_`
- Boolean variables: `isValid`, `hasWinner`, `shouldShow`

### Import Order

1. Dart/Flutter SDK imports
2. Package imports
3. Local imports (with blank lines between groups)
