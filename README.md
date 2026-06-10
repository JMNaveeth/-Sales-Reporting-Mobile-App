# Sales Reporting App — Cyber Mas Solutions Flutter Assessment

A Flutter mobile application for sales reporting, built as part of the **Cyber Mas Solutions Flutter Developer Trainee Assessment**.

---

## Features

### Core Requirements

| Feature | Status |
|---|---|
| Login (Email + Password + Validation) | ✅ Complete |
| POST /login + Save token securely | ✅ Complete |
| Persist login after app restart | ✅ Complete |
| Dashboard (User Name, Total Customers, Total Sales, Total Revenue) | ✅ Complete |
| GET /customers with Name, Email, Phone | ✅ Complete |
| Customer search by name | ✅ Complete |
| Pull to refresh (Customers) | ✅ Complete |
| GET /reports (Monthly Sales, Revenue, Orders) | ✅ Complete |
| Logout (clear token + redirect to Login) | ✅ Complete |

### Bonus Features

| Feature | Status |
|---|---|
| fl_chart sales chart (line + bar) | ✅ Complete |
| Light/Dark theme support | ✅ Complete |
| Unit tests — Login Service | ✅ Complete |
| Unit tests — Customer Repository | ✅ Complete |
| Customer pagination | ✅ Complete |

---

## State Management: Riverpod

This project uses **Flutter Riverpod (v2)** for state management.

### Why Riverpod?

- **Compile-safe**: Providers are type-safe and caught at compile time, unlike Provider which can throw runtime `ProviderNotFoundException`.
- **No BuildContext required**: Providers can be read/watched anywhere without needing a widget context, making service and repository layers cleaner.
- **Testability**: Riverpod's `ProviderContainer` makes unit testing trivial — providers are isolated and overridable without needing a widget tree.
- **AsyncValue**: Built-in `AsyncValue<T>` eliminates boilerplate for loading/error/data states that you'd otherwise write manually.
- **StateNotifier pattern**: Enforces unidirectional data flow and immutable state, making bugs easier to trace and fix.

---

## Architecture

```
lib/
├── models/            # Pure data classes (CustomerModel, ReportModel, UserModel)
├── services/          # API layer (Dio + interceptors) and Storage (SecureStorage + SharedPrefs)
├── repositories/      # Business logic layer between services and providers
├── screens/           # UI screens: login, dashboard, customers, reports
├── widgets/           # Reusable UI components (StatCard, CustomerTile, LoadingOverlay)
├── providers/         # Riverpod state notifiers for auth, customers, reports
├── utils/             # Theme, router, constants, formatters, exceptions
└── main.dart          # App entry point
```

---

## API Layer

- **Base URL**: `https://api.cybermassolutions.com/v1`
- **Auth**: Bearer token injected via Dio interceptor on every request
- **Mock Mode**: A mock interceptor handles all API calls locally for development/testing
- **Error Handling**: Typed exceptions (`NetworkException`, `AuthException`, `ServerException`, etc.)

### Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/login` | Login + receive token |
| POST | `/auth/logout` | Logout |
| GET | `/customers` | Paginated customer list |
| GET | `/reports` | Monthly/yearly reports |
| GET | `/dashboard/stats` | Dashboard summary |

---

## Local Storage

| Data | Storage | Reason |
|---|---|---|
| Auth token | `flutter_secure_storage` | Encrypted, OS keychain — secure |
| User info | `shared_preferences` | Non-sensitive, fast read |

---

## Error Handling

- **No internet**: Shows `NetworkException` with retry button
- **API failures**: Typed exceptions surfaced via `AuthError` state or error UI
- **Invalid login**: Validation on form + snackbar error message
- **Empty responses**: Empty state screens with icons and messaging
- **Session expiry**: 401 interceptor clears storage and redirects to login

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Run tests
flutter test

# Build APK
flutter build apk --release
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.5.1 | State management |
| go_router | ^13.2.0 | Navigation |
| dio | ^5.4.3+1 | HTTP client |
| flutter_secure_storage | ^9.2.2 | Secure token storage |
| shared_preferences | ^2.2.3 | User preferences |
| fl_chart | ^0.68.0 | Sales charts |
| intl | ^0.19.0 | Date/currency formatting |
| equatable | ^2.0.5 | Value equality for models |
| shimmer | ^3.0.0 | Loading skeleton UI |

---

## Compliance

**Assessment compliance: 100%**

All core requirements, technical requirements, error handling, UI requirements, and bonus features are implemented.
