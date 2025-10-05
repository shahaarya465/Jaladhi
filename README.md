<<<<<<< HEAD
# jaladhi

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# Jaladhi - Groundwater Monitoring App

A Flutter application for monitoring groundwater levels using DWLR (Digital Water Level Recorder) data.

## Project Structure

```
lib/
├── main.dart                   # App entry point with provider setup
├── models/
│   └── dwlr_data.dart         # Data model for groundwater information
├── providers/
│   └── dwlr_provider.dart     # State management for DWLR data
└── screens/
    └── data/
        └── dashboard_screen.dart # Main dashboard UI

assets/
└── i18n/                      # Internationalization files
    ├── en.json               # English translations
    ├── gu.json               # Gujarati translations
    └── hi.json               # Hindi translations
```

## Features

- **Dashboard View**: Overview of groundwater monitoring stations
- **Real-time Data**: Display current water levels and station information
- **Statistics**: Summary cards showing min, max, and average water levels
- **Multi-language Support**: English, Hindi, and Gujarati
- **State Management**: Provider pattern for efficient data management

## Getting Started

1. Make sure you have Flutter installed
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Dependencies

- `provider`: ^6.1.2 - State management
- `cupertino_icons`: ^1.0.8 - iOS style icons

## Architecture

The app follows a clean architecture pattern:

- **Models**: Data structures for groundwater information
- **Providers**: Business logic and state management
- **Screens**: UI components and user interactions
- **Assets**: Static resources and translations

## Sample Data

The app includes sample data for testing:
- Delhi: 15.5m water level (Bore Well)
- Mumbai: 12.3m water level (Open Well)  
- Chennai: 8.7m water level (Tube Well)

Ready for integration with your specific UI design and additional features!
>>>>>>> 61a8fe5 (uploaded)
