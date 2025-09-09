# ThinkEasy Mini

A Flutter application for managing posts with authentication, built using Material 3 design principles.

## Requirements

- **Flutter**: 3.32.8 or higher
- **Dart**: 3.8.1 or higher
- **Platform**: Android, iOS, Web, Windows, macOS, Linux

## Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the Application
```bash
flutter run
```

## Environment Configuration

- **Base URL**: `https://frontend-test-be.stage.thinkeasy.cz`
- **API Base Path**: `/api`
- **Authentication**: JWT-based with automatic token refresh

## Features

### 🔐 Authentication
- **Login**: Email/password authentication
- **Token Management**: Automatic access token refresh
- **Session Persistence**: Secure token storage using SharedPreferences
- **Logout**: Clean session termination

### 📝 Posts Management
- **List Posts**: View all posts with pagination support
- **User Posts**: Filter posts by specific user
- **Create Post**: Add new posts with title and content
- **Search**: Real-time search through post titles and content
- **Delete Posts**: Remove posts (admin functionality)

### 🎨 User Experience
- **Material 3 Design**: Modern, consistent UI following Material Design 3
- **Loading States**: Skeleton loaders while fetching data
- **Empty States**: Helpful empty state messages with actionable buttons
- **Error Handling**: User-friendly error messages with retry options
- **Pull-to-Refresh**: Refresh posts by pulling down
- **Responsive Design**: Works across all supported platforms

### 🔄 State Management
- **BLoC Pattern**: Clean architecture with BLoC for state management
- **Repository Pattern**: Separation of concerns with data repositories
- **Dependency Injection**: GetIt for service location
- **Error Handling**: Comprehensive error handling with custom exceptions

## Testing

Run the test suite:
```bash
flutter test
```

### Test Coverage
- **Unit Tests**: BLoC logic, repositories, and utilities
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flows
- **Network Tests**: API interceptor and error handling

## Project Structure

```
lib/
├── app.dart                 # Main application entry point
├── main.dart               # Application initialization
├── core/                   # Core functionality
│   ├── api/               # API client configuration
│   ├── config/            # App constants and configuration
│   ├── di/                # Dependency injection setup
│   ├── error/             # Error handling and custom exceptions
│   ├── network/           # Network layer (Dio, interceptors)
│   ├── router/            # Navigation and routing
│   ├── storage/           # Local storage (tokens, preferences)
│   └── utils/             # Utility functions
└── features/              # Feature-based modules
    ├── auth/              # Authentication feature
    │   ├── data/          # Data layer (models, repositories)
    │   └── presentation/  # UI layer (pages, widgets, BLoC)
    └── posts/             # Posts feature
        ├── data/          # Data layer (models, repositories)
        └── presentation/  # UI layer (pages, widgets, BLoC)
```

## Dependencies

### Core Dependencies
- **flutter_bloc**: State management
- **dio**: HTTP client
- **get_it**: Dependency injection
- **go_router**: Navigation
- **shared_preferences**: Local storage
- **fluttertoast**: Toast notifications

### Development Dependencies
- **build_runner**: Code generation
- **freezed**: Immutable data classes
- **json_serializable**: JSON serialization
- **mocktail**: Testing mocks
- **bloc_test**: BLoC testing utilities

## API Endpoints

- `POST /api/auth/login` - User authentication
- `POST /api/auth/refresh` - Token refresh
- `GET /api/posts` - List all posts
- `GET /api/posts?userId={id}` - List user posts
- `POST /api/posts` - Create new post
- `DELETE /api/posts/{id}` - Delete post

## Development

### Code Generation
The project uses code generation for:
- **Freezed**: Immutable data classes with copyWith, equality, and toString
- **JSON Serializable**: Automatic JSON serialization/deserialization

Run code generation after making changes to models:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Architecture
- **Clean Architecture**: Separation of concerns with clear boundaries
- **Feature-based**: Organized by features rather than technical layers
- **SOLID Principles**: Maintainable and testable code structure

## Contributing

1. Follow the existing code style and architecture patterns
2. Write tests for new features
3. Ensure all tests pass before submitting
4. Use meaningful commit messages
5. Update documentation for new features

## License

This project is part of the ThinkEasy platform and is proprietary software.