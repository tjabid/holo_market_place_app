# Holo Marketplace App

A modern, scalable, and well-tested e-commerce Flutter application built with Clean Architecture principles. This project serves as a robust template for building feature-rich marketplace apps.

## ✨ Features

- **Product Discovery**: Browse a list of all available products.
- **Categorization**: Filter products by categories.
- **Product Details**: View detailed information for each product.
- **Shopping Cart**: Add, update, and remove items from the cart.
- **Dark Mode**: Seamless theme switching for a better user experience.
- **Local Caching**: Offline-first approach for products and categories, ensuring a fast and responsive UI.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.x or higher)
- An IDE like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/tjabid/holo_market_place_app.git
    cd holo_market_place_app
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Generate Mocks for Tests:**
    Before running tests, you need to generate the necessary mock files.
    ```sh
    # For macOS/Linux
    ./test/generate_mocks.sh

    # For Windows
    .\test\generate_mocks.bat
    ```

4.  **Run the application:**
    ```sh
    flutter run
    ```

---

## 🏛️ Architecture

This project follows **Clean Architecture** principles to create a separation of concerns, making the codebase scalable, maintainable, and testable. The code is organized into three main layers within each feature module:

-   **Presentation**: Contains the UI (Widgets), state management (BLoC/Cubit), and presentation logic.
-   **Domain**: The core of the application. Contains business logic, entities, use cases (interactors), and repository interfaces. This layer is independent of any framework.
-   **Data**: Implements the repository interfaces defined in the domain layer. It's responsible for fetching data from remote (API) and local (cache) data sources.

### Technical Stack

-   **State Management**: `flutter_bloc` for predictable and scalable state management.
-   **Functional Programming**: `dartz` to handle errors and exceptions gracefully using `Either`.
-   **Networking**: `http` for making API calls.
-   **Local Storage**: `shared_preferences` for caching cart data. An in-memory cache is used for products and categories.
-   **Testing**: `mockito` and `build_runner` for generating mock objects for unit tests.
-   **Image Loading**: `cached_network_image` for efficient loading and caching of network images.

---

## 🧪 Testing

The project has a strong emphasis on testing, with a comprehensive suite of unit tests.

### Running Tests

To run all unit tests, execute the following command:
```sh
flutter test
```

### Test Coverage

To generate a full test coverage report, use the provided script. This will run the tests and generate an HTML report in the `coverage/html` directory.

```sh
# For macOS/Linux
./test_coverage.sh

# For Windows
.\test_coverage.bat
```

After running, you can open `coverage/html/index.html` in a browser to view the detailed report.

---

## 📁 Project Structure

```
holo_market_place_app/
├── lib/
│   ├── core/         # Core utilities, constants, and error handling
│   └── features/     # Feature-based modules
│       └── products/
│           ├── data/
│           ├── domain/
│           └── presentation/
├── test/             # Unit and widget tests, mirroring the lib structure
│   ├── core/
│   └── features/
└── wiki/             # In-depth documentation and architecture notes
```

---

## 📚 Wiki & Documentation

For a deeper dive into the architecture, design decisions, and feature implementation details, please refer to the project [**Wiki**](./wiki/IMPLEMENTATION_SUMMARY.md). The wiki contains detailed documents on:

-   Cart Architecture
-   Dark Theme Implementation
-   Testing Guides
-   And more...
