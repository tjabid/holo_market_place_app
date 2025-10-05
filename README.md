# Holo Marketplace App

A modern, scalable, and well-tested e-commerce Flutter application built with Clean Architecture principles. This project serves as a robust template for building feature-rich marketplace apps.

## Features
This app is implemented with Clean Architecture + Cubit state management pattern.

- **Product Discovery**: Browse a list of all available products.
- **Categorization**: Filter products by categories.
- **Product Details**: View detailed information for each product.
- **Shopping Cart**: Add, update, and remove items from the cart.
- **Dark Mode**: Seamless theme switching for a better user experience.
- **Local Caching**: Offline-first approach for cart items, ensuring a fast and responsive UI.


## System Overview

```
┌────────────────────────────────────────────────┐
│      USER INTERFACE - (Presentation Layer)     │
└────────────────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────┐
│      STATE MANAGEMENT - (Cubit Layer)          │
└────────────────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────┐
│      DOMAIN ENTITIES - (Business Logic)        │
└────────────────────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────┐
│      DATA ENTITIES - (Data Retrieving Logic)   │
└────────────────────────────────────────────────┘
```

---
## Architecture Overview

### **1. Features Layer (Clean Architecture)**

#### **Domain Layer** (Business Logic)
- **Entities**: Pure Dart classes (Product)
- **Repositories**: Abstract interfaces
- No dependencies on outer layers

#### **Data Layer** (Implementation)
- **Models**: JSON serialization
- **Data Sources**: API communication
- **Repository Implementation**: Converts models to entities

#### **Presentation Layer** (UI)
- **Cubit**: State management
- **States**: Loading, Loaded, Error
- **Pages**: Main screens
- **Widgets**: Reusable UI components


### **2. Core Layer**
- **API Client**: Handles HTTP requests with error handling
- **Constants**: Centralized API endpoints
- **Failures & Exceptions**: Custom error handling
- **DI**: GetIt service locator setup

---

## Libraries Used

```yaml
dependencies:
  flutter_bloc: ^8.1.3      # State management
  equatable: ^2.0.5         # Value equality
  get_it: ^7.2.0            # Dependency injection
  http: ^1.2.0              # HTTP client
  dartz: ^0.10.1            # Functional programming (Either)
  cached_network_image      # Image caching
  shared_preferences        # Local storage
  flutter_launcher_icons    # App Icon generator
  mockito: ^5.4.2           # Unit Testing
  build_runner: ^2.4.6      # Mock generator
```
---

### Technical Stack

-   **State Management**: `flutter_bloc` for predictable and scalable state management.
-   **Functional Programming**: `dartz` to handle errors and exceptions gracefully using `Either`.
-   **Networking**: `http` for making API calls.
-   **Local Storage**: `shared_preferences` for caching cart data. An in-memory cache is used for products and categories.
-   **Testing**: `mockito` and `build_runner` for generating mock objects for unit tests.
-   **Image Loading**: `cached_network_image` for efficient loading and caching of network images.

---
## Key Features Implemented

### ✅ Product List
- Fetches products from `FakeStoreAPI`
- Displays in 2-column grid
- Shows: image, title, price, category, rating
- Pull-to-refresh

### ✅ Category Filtering
- Dynamic categories from API
- "All Items" + men's/women's clothing, jewelery, electronics
- Filter products with icons
- Real-time filtering

### ✅ Error Handling
- Network errors
- Server errors
- Retry functionality
- User-friendly error messages

### ✅ Loading States
- Custom shimmer loading animation
- Smooth transitions
- No jarring state changes

### ✅ Modern UI/UX
- Clean, minimal design
- Rounded corners
- White cards with shadows
- Black accent color
- Bottom navigation bar

### ✅ Dark Theme
- Light Theme 

---

## 🧪 Testing

The project has a strong emphasis on business logic testing, with a comprehensive suite of unit tests.

### Running Tests

To run all unit tests, execute the following command:
```sh
flutter test --coverage
```

### Test Coverage

To generate a full test coverage report, use the provided script. This will generate mocks, run the tests and generate an HTML report in the `coverage/html` directory using [LCOV](https://github.com/linux-test-project/lcov).

```sh
./test_coverage.sh
```

---





### Sets to run project

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
    ./generate_mocks.sh

    # For Windows
    .\generate_mocks.bat
    ```

4.  **Run the application:**
    ```sh
    flutter run
    ```

---
