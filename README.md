# Performance Tracker

A Flutter application for tracking training, nutrition, and overall fitness progress. Data is stored locally on device, with optional AI coaching that connects through your own API key.

## Features

- **Nutrition** — Log meals, track calories and macro/micronutrients, and review nutritional analysis over time.
- **Training** — Build routines, record workouts, monitor muscle fatigue, and receive training advice.
- **Activity** — A dashboard summarising daily activity and long-term journeys, with health data (such as steps) pulled from the device.
- **Coach** — An AI assistant for personalised guidance and reports, driven by a user-supplied model API key.
- **Profile & Journal** — Manage personal details and goals, and keep an encrypted private journal.

## Tech Stack

- **Framework:** Flutter (Dart SDK `^3.8.0`)
- **Local storage:** Hive
- **State/DI:** `get_it`
- **Charts:** `fl_chart`
- **Health data:** `health`, `permission_handler`
- **Security:** `encrypt`, `crypto`, `flutter_secure_storage`

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and configured
- An Android or iOS device/emulator, or a supported desktop platform

### Setup

```bash
# Install dependencies
flutter pub get

# Generate model/serialization code (Hive adapters)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### AI Coach

The Coach feature requires a model API key, which you provide from within the app under the AI management settings. No key is bundled with the project.

## Project Structure

```
lib/
├── main.dart            # App entry point and navigation
├── DI.dart              # Dependency injection setup
├── db.dart              # Hive database initialisation
├── models/              # Data models and generated adapters
├── repositories/        # Data access layer
├── services/            # Business logic and integrations
└── src/
    ├── components/      # Shared widgets
    └── features/        # Feature modules (Nutrition, Workout, Coach, Dashboard)
```

## Build

```bash
# Android
flutter build apk

# iOS
flutter build ios
```
## Contributing

Contributions are welcome and appreciated.

If you'd like to contribute:

1. Fork the repository.
2. Create a feature or bug-fix branch.
3. Make your changes and test them.
4. Submit a Pull Request with a clear description of your changes.

Please keep pull requests focused and follow the existing code style where possible.

For significant changes or new features, consider opening an issue first to discuss the proposal.
