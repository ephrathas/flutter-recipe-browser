# Recipe Browser

A premium, production-ready Flutter application for exploring culinary delights. Built with a focus on clean architecture, robust async programming, and a high-fidelity Material 3 design system.

---

## Student Information

- **Student Name**: Ephratha Samuel
- **Student ID**: ATE/2652/15
- **Course**: Mobile Application Development (Unit 4)
- **Assignment Track**: Flutter Development with API Integration
- **Submission Date**: May/10/2026

---

## Project Overview

Recipe Browser is a high-performance recipe discovery app that leverages TheMealDB API to provide users with a seamless browsing experience. From browsing international categories to following detailed cooking instructions, the app is designed to feel fluid, responsive, and visually stunning.

### Key Objectives
- Demonstrate clean architecture (Separation of Models, Services, and UI)
- Implement robust async/await patterns and declarative state management
- Provide premium UX using Material 3 and cinematic animations

---

## Features

- **Category Explorer**: Browse a rich list of meal categories with high-quality thumbnails and descriptions
- **Dynamic Meal Discovery**: Filter meals by category and explore thousands of recipes
- **Recipe Search**: Real-time search with debounced API calls (450ms) for optimal performance
- **Offline-Friendly Caching**: Category data is stored locally and shown when network access is unavailable
- **High-Fidelity Detail View**:
  - Collapsible image headers with Hero transitions
  - Organized ingredients list with measurement parsing
  - Formatted, easy-to-read cooking instructions
- **External Integrations**: Launch YouTube tutorials directly from the recipe page
- **Robust Networking**:
  - Declarative state handling (Loading, Success, Empty, Error)
  - Global error mapping (Timeout, Connection, Format errors)
  - Pull-to-refresh support

---

## Technologies & Dependencies

- **Framework**: Flutter (Channel Stable)
- **Language**: Dart
- **Networking**: http ^1.2.2
- **Local Storage**: shared_preferences ^2.1.0
- **Link Handling**: url_launcher ^6.3.1
- **Design System**: Material 3 (Custom Theme)

---

## Architecture & Folder Structure

The project follows a modular architecture to ensure scalability and ease of testing:

```
lib/
├── models/         # Immutable data classes (Meal, MealCategory)
├── services/       # API Networking logic & custom exceptions
├── screens/        # Full-page widgets (Home, Category, Detail)
├── widgets/        # Reusable UI components (Cards, Error, Loading)
└── main.dart       # App entry point & global theme configuration
```

### Core Principles
- **Immutability**: All models are @immutable to ensure thread-safety
- **Separation of Concerns**: UI widgets never call APIs directly; they consume data through service layers
- **Defensive Programming**: All JSON parsing is type-safe and handles malformed data gracefully

---

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code / Xcode
- A stable internet connection

### Setup Instructions
1. **Clone the repository:**
   ```bash
   git clone https://github.com/ephrathas/flutter-recipe-browser.git
   ```
2. **Navigate to the project directory:**
   ```bash
   cd recipe-browser
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

### Running the App
- **Windows / macOS / Linux**: Ensure you have the appropriate desktop support enabled
- **Mobile**: Connect your device or start an emulator and run:
  ```bash
  flutter run
  ```

---

## API Information

This application consumes the free tier of TheMealDB API.

| Endpoint | Purpose |
|----------|---------|
| `/categories.php` | Fetches all recipe categories |
| `/filter.php?c={id}` | Fetches meals for a category |
| `/lookup.php?i={id}` | Fetches full recipe details |
| `/search.php?s={query}` | Searches meals by name |

---

## Implementation Notes

### Async Programming Implementation
The application implements comprehensive async/await patterns throughout:
- **Exclusive async/await usage**: No .then() chains are used anywhere in the codebase
- **FutureBuilder integration**: Declarative state management for loading, error, and success states
- **Mounted checks**: All async operations after await gaps include context.mounted verification to prevent memory leaks
- **Error propagation**: Custom ApiException hierarchy ensures consistent error handling across all network operations
- **Debounced search**: Timer-based debouncing (450ms) prevents excessive API calls during user input
- **Cached category data**: Local JSON cache is used as a fallback when the network is unavailable

### Error Handling Architecture
- **Custom exception hierarchy**: ApiException with 7 factory constructors covering all error scenarios
- **Network error mapping**: SocketException, TimeoutException, and FormatException are caught and converted to user-friendly messages
- **UI error recovery**: All error states include retry mechanisms with proper state restoration
- **Defensive JSON parsing**: All API responses are validated for structure and type safety before model creation

### Architecture Summary
- **Service Layer Isolation**: All HTTP logic is contained within dedicated service classes with zero imports in UI layers
- **Generic API Wrapper**: The _safeApiCall<T> method provides reusable error handling and response validation
- **Immutable Models**: All data classes use @immutable annotation with comprehensive factory constructors
- **Type Safety**: Zero dynamic usage; all JSON parsing includes explicit type casting and null coalescing

---

## Known Limitations

- **API Rate Limits**: Subject to TheMealDB free tier limitations
- **Image Loading**: Network images may fail in poor connectivity (handled gracefully)

---

## Learning Outcomes

Developing this project provided deep insights into:
- **State Management**: Using FutureBuilder with AnimatedSwitcher for seamless transitions
- **Context Safety**: Implementing mounted checks to avoid memory leaks and crashes in async callbacks
- **Advanced Networking**: Building a custom ApiException wrapper for precise error feedback
- **UX Design**: Applying Material 3 principles like scrolledUnderElevation and custom ColorScheme generation

---

## Future Improvements


- [ ] **Favorites**: Add local persistence (SQLite/Hive) to save recipes offline
- [ ] **Multi-language**: Support for internationalization (i18n)
- [ ] **Unit Tests**: Implement comprehensive testing for the service and model layers

---

## Submission Notes

This project demonstrates professional-level Flutter development practices suitable for portfolio presentation. The codebase follows production standards with extensive documentation, defensive programming, and clean architecture principles.

All assignment requirements have been met including:
- HTTP package usage with proper Uri construction
- Immutable model classes with comprehensive JSON parsing
- Isolated service layer architecture
- Complete async/await implementation
- Custom error handling hierarchy
- Material 3 design system implementation
- All required screens and navigation
- Professional code organization and documentation
- Production-quality search feature with debouncing

---

Developed by Ephratha Samuel for Addis Ababa University Mobile Application Development Unit 4
