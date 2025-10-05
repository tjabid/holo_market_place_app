# holo_market_place_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/to/state-management-sample).

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/to/resolution-aware-images).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter apps](https://flutter.dev/to/internationalization).

## Unit tests
Coverage

### Technical Details
- `mockito` - For creating mock objects
- `build_runner` - For generating mock files

### Generated Mock Files:
Used `@GenerateMocks` annotation for mock generation
Run `build_runner` to create *_test.mocks.dart

#### Data Flow Testing:
1. Local cache-first strategy validation
2. Remote fallback with local caching

Error handling:
- ServerException → ServerFailure mapping
- NetworkException → NetworkFailure mapping
- Generic Exception → ServerFailure with "Unexpected error" handling
- Proper error message propagation
