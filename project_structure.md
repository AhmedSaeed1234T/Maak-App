# Ma3ak App - Project Structure Documentation

## Overview
Ma3ak App is a Flutter-based mobile application that connects service providers with customers in Egypt. The app supports multiple provider types including contractors, workers, engineers, companies, marketplaces, assistants, and building demolishers (sculptors).

## Directory Structure

### `/lib` - Main Application Code

#### `/lib/controllers`
Backend API controllers for managing data and business logic:
- **ChatController.dart** - Manages real-time chat functionality
- **NotificationController.dart** - Handles push notifications and notification management
- **PresenceController.dart** - Tracks online/offline status of users
- **ProfileController.dart** - Manages user profile data and updates
- **SearchController.dart** - Handles search and filtering of service providers

#### `/lib/helpers`
Utility classes and helper functions:
- **ContextFunctions.dart** - Context-related utility functions
- **CustomSnackBar.dart** - Custom snackbar implementations
- **enums.dart** - Application-wide enumerations (ProviderType, etc.)
- **FirebaseUtilities.dart** - Firebase integration utilities
- **NetworkStatus.dart** - Network connectivity monitoring
- **ServiceLocator.dart** - Dependency injection setup
- **subscriptionChecker.dart** - Subscription status validation
- **TokenService.dart** - JWT token management and authentication

#### `/lib/models`
Data models and DTOs:
- **RegisterClass.dart** - User registration data model
- **SearchResultDto.dart** - Service provider search results
- **ServiceProviderDto.dart** - Service provider details
- **UserProfile.dart** - User profile information

#### `/lib/screens`
Application screens and UI components:

**Main Screens:**
- **dashboard_screen.dart** - Main dashboard with provider listings (refactored with components)
- **select_account_type_screen.dart** - Account type selection during registration
- **worker_details_screen.dart** - Detailed view of service provider profiles
- **chat_screen.dart** - Real-time chat interface
- **settings_screen.dart** - User settings and profile management
- **filters_screen.dart** - Advanced search and filtering
- **debug_token_screen.dart** - Development/debugging utilities

**Registration Screens:**
- **worker_register_screen.dart** - Worker registration form
- **sculptor_register_screen.dart** - Building demolisher registration form

**Profile Screens** (`/lib/screens/profile`):
- **profile_company_screen.dart** - Company profile editing
- **company_profile_screen.dart** - Company profile viewing

#### `/lib/services`
Service layer for data management:
- **UserListCache.dart** - Caching service for provider listings

#### `/lib/widgets`
Reusable UI components:

**Location Widgets:**
- **location_fields.dart** - Location selection components (governorate, city, district)

**Dashboard Components** (`/lib/widgets/dashboard`):
- **dashboard_header.dart** - Dashboard welcome header
- **search_and_categories.dart** - Search field and category tabs
- **provider_card.dart** - Service provider card component
- **empty_state_widget.dart** - Empty state displays

### `/assets`
Application assets including images, icons, and other static resources

### `/android`
Android-specific configuration and build files

### `/build`
Build output directory (generated)

## Key Features

### 1. Service Provider Management
- Multiple provider types (contractors, workers, engineers, companies, markets, assistants, building demolishers)
- Provider search and filtering
- Online/offline status tracking
- Profile management with images and detailed information

### 2. Real-Time Communication
- SignalR-based chat system
- Push notifications via Firebase
- Presence tracking (online/offline indicators)

### 3. User Authentication & Authorization
- JWT token-based authentication
- Secure token storage
- Subscription management and validation

### 4. Offline Support
- Local caching of provider data
- Offline mode with cached data display
- Network connectivity monitoring

### 5. Location Services
- Hierarchical location selection (governorate → city → district)
- Location-based search
- Service area management

## Architecture Patterns

### State Management
- StatefulWidget-based state management
- ValueListenableBuilder for reactive updates (presence tracking)

### Dependency Injection
- Service locator pattern via `ServiceLocator.dart`
- Centralized dependency management

### Data Flow
1. **Controllers** handle API communication
2. **Services** manage data caching and persistence
3. **Screens** display UI and handle user interactions
4. **Widgets** provide reusable UI components

### Code Organization
- **Separation of Concerns**: Controllers, services, and UI are clearly separated
- **Component-Based UI**: Dashboard refactored into reusable components
- **Model-Based Data**: DTOs for type-safe data handling

## Recent Refactoring

### Dashboard Screen Refactoring
The dashboard screen was refactored from a monolithic 1202-line file into modular components:

1. **DashboardHeader** - Welcome message and connection status
2. **SearchAndCategories** - Search functionality and provider type tabs
3. **ProviderCard** - Individual provider display cards
4. **EmptyStateWidget** - Various empty/error state displays

This refactoring improved:
- Code maintainability
- Component reusability
- File organization
- Testing capabilities

## Terminology Updates

### Provider Types (Arabic)
- **المقاولين** - Contractors
- **العمال** - Workers
- **المهندسين** - Engineers
- **الشركات** - Companies
- **الأسواق** - Markets (formerly المتاجر)
- **المساعدين** - Assistants
- **هدام** - Building Demolisher (formerly نحات - Sculptor)

## Development Notes

### Running the App
```bash
flutter run --debug
```

### Build Configuration
- Android configuration in `/android`
- Assets defined in `pubspec.yaml`

### Key Dependencies
- **connectivity_plus** - Network monitoring
- **firebase_core** & **firebase_messaging** - Push notifications
- **cached_network_image** - Image caching
- **flutter_secure_storage** - Secure token storage
- **hive** - Local data persistence

## Future Enhancements
- Additional UI component extraction
- Enhanced offline capabilities
- Performance optimizations
- Automated testing implementation
