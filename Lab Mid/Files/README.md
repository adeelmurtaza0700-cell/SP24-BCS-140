# TaskFlow

TaskFlow is a Flutter and SQLite task management application built for the Mobile Application Development mid-term project, Spring 2026.

## Features

- Today Task view for tasks due on the current day
- Upcoming active task visibility on the main screen
- Completed Task view
- Repeated Task view for daily and weekly recurring tasks
- Add, edit, delete, and complete tasks
- Task categories, priorities, due dates, and reminder times
- Subtasks with progress tracking
- Theme mode and accent color customization
- Notification sound selection
- Local notifications for upcoming tasks
- Export to CSV, PDF, and email
- SQLite persistence

## Tech Stack

- Flutter
- SQLite via `sqflite`
- Local notifications via `flutter_local_notifications`
- PDF and CSV export via `pdf` and `csv`
- Settings persistence via `shared_preferences`

## Project Structure

- `lib/controllers/` state and business logic
- `lib/models/` task and settings models
- `lib/screens/` primary app views
- `lib/services/` database, notifications, exports, and settings
- `lib/widgets/` reusable UI components

## How To Run

1. Install Flutter SDK.
2. Run `flutter pub get`.
3. Start the app with `flutter run`.

## Build APK

1. Run `flutter build apk`.
2. The generated APK will be available under `build/app/outputs/flutter-apk/`.

## Submission Checklist

- Source code in this repository
- Generated APK file
- Video demonstration of the app
- GitHub repository link

## Requirement Coverage

- SQLite database integration: implemented in `lib/services/database_service.dart`
- Today, Completed, and Repeated views: implemented in `lib/screens/`
- Task add, edit, delete, and complete flows: implemented across controller and screen layers
- Progress tracking with subtasks: implemented in `lib/models/task_item.dart` and `lib/widgets/task_card.dart`
- Customization: implemented in `lib/screens/settings_screen.dart`
- CSV, PDF, and email export: implemented in `lib/services/export_service.dart`
- Repeat task automation: implemented in `lib/controllers/task_controller.dart`
- Local notifications: implemented in `lib/services/notification_service.dart`

## Testing

- Static analysis: `flutter analyze`
- Widget and unit tests: `flutter test`
