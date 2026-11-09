# ToDo

ToDo is a native iOS task manager for organizing personal work into tasks and subtasks. The interface designed to work well with Apple accessibility features.

## Features

- Create tasks with a title, due date, and optional reminder.
- Break tasks down into subtasks with independent deadlines and reminders.
- Mark tasks and subtasks as complete or incomplete.
- Delete tasks and automatically cancel their pending notifications.
- Schedule local notifications for task and subtask deadlines.
- Receive task proposals through remote notifications.
- Accept or decline incoming tasks directly from a notification and review their status in the Inbox.
- Store private tasks separately and unlock them with Face ID.
- Save login credentials and private task names securely in Keychain.
- Persist tasks, subtasks, and inbox items locally with Realm or Core Data.
- Support VoiceOver, Dynamic Type, Dark Mode, high-contrast colors, large touch targets, and Reduce Motion.

## Tech Stack

| Area | Technology |
| --- | --- |
| Language | Swift 5 |
| UI | UIKit, Storyboards, Auto Layout |
| Architecture | App coordinator, service and repository layers, protocol-based persistence |
| Persistence  | Core Data/Realm|
| Secure storage | Keychain Services |
| Authentication | LocalAuthentication |
| Notifications | UserNotifications, APNs |
| Accessibility | VoiceOver, Dynamic Type, semantic colors, Reduce Motion support |
| Testing | XCTest and XCUITest accessibility audits |

## Project Structure

```text
ToDo/
├── App/             # Application lifecycle, storyboard, and app coordinator
├── Models/          # Domain models
├── Notifications/   # Local and remote notification handling
├── Persistence/     # Realm and Core Data persistence services
├── Security/        # Keychain, credentials, and biometric authentication
└── View/            # UIKit view controllers and reusable table view cells

ToDoUITests/         # Accessibility and Dynamic Type UI tests
docs/accessibility/  # Accessibility audit screenshots
```

`PersistenceServiceProvider` currently selects `RealmService` as the app's active persistence implementation. A `CoreDataService` implementation is also included behind the same `PersistenceService` protocol.

