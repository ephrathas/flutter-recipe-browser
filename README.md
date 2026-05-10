# 🍽️ Recipe Browser

A premium, production-ready Flutter application for exploring culinary delights. Built with a focus on clean architecture, robust async programming, and a high-fidelity Material 3 design system.

---

## 🌟 Overview

Recipe Browser is a high-performance recipe discovery app that leverages [TheMealDB API](https://www.themealdb.com/api.php) to provide users with a seamless browsing experience. From browsing international categories to following detailed cooking instructions, the app is designed to feel fluid, responsive, and visually stunning.

### 🎯 Key Objectives
- Demonstrate **Clean Architecture** (Separation of Models, Services, and UI).
- Implement robust **Async/Await** patterns and declarative state management.
- Provide a **Premium UX** using Material 3 and cinematic animations.

---

## ✨ Features

- **Category Explorer**: Browse a rich list of meal categories with high-quality thumbnails and descriptions.
- **Dynamic Meal Discovery**: Filter meals by category and explore thousands of recipes.
- **High-Fidelity Detail View**: 
  - Collapsible image headers with Hero transitions.
  - Organized ingredients list with measurement parsing.
  - Formatted, easy-to-read cooking instructions.
- **External Integrations**: Launch YouTube tutorials directly from the recipe page.
- **Robust Networking**:
  - Declarative state handling (Loading, Success, Empty, Error).
  - Global error mapping (Timeout, Connection, Format errors).
  - Pull-to-refresh support.

---

## 🛠️ Technologies & Dependencies

- **Framework**: [Flutter](https://flutter.dev/) (Channel Stable)
- **Language**: [Dart](https://dart.dev/)
- **Networking**: `http: ^1.2.2`
- **Link Handling**: `url_launcher: ^6.3.1`
- **Design System**: Material 3 (Custom Theme)

---

## 📁 Architecture & Folder Structure

The project follows a modular architecture to ensure scalability and ease of testing:

```text
lib/
├── models/         # Immutable data classes (Meal, MealCategory)
├── services/       # API Networking logic & custom exceptions
├── screens/        # Full-page widgets (Home, Category, Detail)
├── widgets/        # Reusable UI components (Cards, Error, Loading)
└── main.dart       # App entry point & global theme configuration
```

### 🧠 Core Principles
- **Immutability**: All models are `@immutable` to ensure thread-safety.
- **Separation of Concerns**: UI widgets never call APIs directly; they consume data through service layers.
- **Defensive Programming**: All JSON parsing is type-safe and handles malformed data gracefully.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code / Xcode
- A stable internet connection

### Setup Instructions
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/recipe-browser.git
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
- **Windows / macOS / Linux**: Ensure you have the appropriate desktop support enabled.
- **Mobile**: Connect your device or start an emulator and run:
  ```bash
  flutter run
  ```

---

## 🌐 API Information

This application consumes the free tier of [TheMealDB API](https://www.themealdb.com/api.php).

| Endpoint | Purpose |
| :--- | :--- |
| `/categories.php` | Fetches all recipe categories |
| `/filter.php?c={id}` | Fetches meals for a category |
| `/lookup.php?i={id}` | Fetches full recipe details |

---

## 🎓 Learning Outcomes

Developing this project provided deep insights into:
- **State Management**: Using `FutureBuilder` with `AnimatedSwitcher` for seamless transitions.
- **Context Safety**: Implementing `mounted` checks to avoid memory leaks and crashes in async callbacks.
- **Advanced Networking**: Building a custom `ApiException` wrapper for precise error feedback.
- **UX Design**: Applying Material 3 principles like `scrolledUnderElevation` and custom `ColorScheme` generation.

---

## 🔮 Future Improvements

- [ ] **Search**: Implement a real-time search bar for specific meals.
- [ ] **Favorites**: Add local persistence (SQLite/Hive) to save recipes offline.
- [ ] **Multi-language**: Support for internationalization (i18n).
- [ ] **Unit Tests**: Implement comprehensive testing for the service and model layers.

---

## 📸 Screenshots

*(Add your screenshots here to showcase the premium UI!)*

| Home Screen | Category View | Recipe Details |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/300x600?text=Home+Screen) | ![Category](https://via.placeholder.com/300x600?text=Category+View) | ![Detail](https://via.placeholder.com/300x600?text=Recipe+Details) |

---

Developed with ❤️ by Ephratha Samuel
