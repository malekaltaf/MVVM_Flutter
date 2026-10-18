# Products_Demo

Building an MVVM Program with Flutter.

![Design File](user_design.PNG)

---

## 📖 Overview

A modern Flutter application demonstrating the **Model-View-ViewModel (MVVM)** architectural pattern. It retrieves high-resolution imagery from the [Lorem Picsum API](https://picsum.photos/) and renders them in a responsive, staggered masonry grid layout styled with **Material 3**.

---

## ✨ Features

- **MVVM Architecture**: Clean separation of concerns between business logic, network communication, and presentation layer.
- **Reactive State Management**: Powered by Flutter's built-in `ChangeNotifier` and `ListenableBuilder` with an explicit `ViewStatus` state machine (`initial`, `loading`, `success`, `error`).
- **Material 3 Design**: Supports dynamic light/dark theming, modern card elevation, rounded surfaces, and modal bottom sheets.
- **Masonry Grid**: Fluid, responsive staggered layout (`MasonryGridView`) adapting dynamically across phone, tablet, and desktop viewports.
- **Pull to Refresh**: Seamless swipe-down refresh indicator to fetch updated feeds.
- **Image Details & Link Sharing**: Tap any image card to open a detailed modal sheet showing author credentials, dimensions, photo ID, and clipboard link copying.
- **Resilient Network & Error Handling**: Custom `ApiException` handling network timeouts, connection drops, and malformed responses with in-app retry capabilities.
- **Comprehensive Test Suite**: Unit and widget tests covering models, services, view models, and UI components with mock network injection.

---

## 🏛 Architecture (MVVM)

```
┌─────────────────┐        ┌───────────────────────┐        ┌─────────────────┐
│                 │        │                       │        │                 │
│      View       │◄───────┤       ViewModel       │◄───────┤  Model/Service  │
│  (UI / Widgets) │ Notify │ (ListPictureViewModel)│ Data   │ (Picsum Photos) │
│                 │        │                       │        │                 │
└─────────────────┘        └───────────────────────┘        └─────────────────┘
```

1. **Model** (`lib/model/picsum_model.dart`): Immutable data representations with robust JSON deserialization and utility computed properties (e.g. aspect ratio).
2. **Service Layer** (`lib/services/services.dart`): Abstracted API contract with injectable HTTP client, timeouts, and structured exception handling.
3. **ViewModel** (`lib/view_model/`):
   - `ListPictureViewModel`: Manages application state, API calls, caching, and state transitions.
   - `PictureViewModel`: Exposes presentation-ready formatting for individual image cards.
4. **View** (`lib/view/home.dart`): Pure declarative Flutter widgets reacting to ViewModel updates without direct network logic.

---

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & Material 3 theme configuration
├── model/
│   └── picsum_model.dart              # PicSum data model & serialization logic
├── services/
│   └── services.dart                  # API service contract, client injection & exceptions
├── view/
│   └── home.dart                      # Home screen, masonry grid view & detail bottom sheet
└── view_model/
    ├── list_picture_viewmode.dart     # MVVM ChangeNotifier & ViewStatus management
    └── list_picture_viewmodel.dart    # Standardized export barrel
test/
├── model/
│   └── picsum_model_test.dart         # Unit tests for JSON parsing & equality
├── services/
│   └── services_test.dart             # Unit tests for HTTP client & status code handling
├── view_model/
│   └── list_picture_viewmodel_test.dart # State transitions & caching tests
└── widget_test.dart                   # UI widget & smoke tests
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.1.5`)
- Dart SDK (`>= 3.1.5 < 4.0.0`)

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/malekaltaf/MVVM_Flutter.git
   cd MVVM_Flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests & Code Analysis

Run static analysis to verify code quality:
```bash
flutter analyze
```

Execute the unit and widget test suite:
```bash
flutter test
```

---

## 📦 Key Dependencies

- [`flutter_staggered_grid_view`](https://pub.dev/packages/flutter_staggered_grid_view): Modern staggered masonry grid layout.
- [`http`](https://pub.dev/packages/http): Composable HTTP networking client.
- [`transparent_image`](https://pub.dev/packages/transparent_image): Transparent memory placeholders for smooth image transitions.
- [`flutter_lints`](https://pub.dev/packages/flutter_lints): Recommended lint rules for high code quality.