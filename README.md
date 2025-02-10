# OBBilyoner - iOS Betting Application

A modern iOS betting application built with Swift, showcasing real-time odds, event management, and basket functionality.

## Features

- **Event Management**
  - List and search sports events
  - View detailed odds for each event
  - Predefined events section with odds display
  - Real-time odds updates

- **Basket Operations**
  - Add/remove events to basket
  - Update bet selections
  - Calculate total odds and potential winnings
  - Quick bet amount selection

- **User Interface**
  - Modern, intuitive design
  - Tab-based navigation
  - Responsive layout with SnapKit
  - Custom animations and transitions

## Technical Stack

- **Architecture**: MVVM with RxSwift
- **Minimum Xcode Version**: iOS 16.0+
- **Minimum iOS Version**: iOS 15.6+
- **Dependencies**:
  - RxSwift/RxCocoa - Reactive programming
  - SnapKit - Programmatic UI constraints
  - Alamofire - Network requests

## Setup Instructions

1. Clone the repository
2. Open `OBBilyoner.xcodeproj` in Xcode 16.0 or later
3. Configure the API credentials in `OBConfig.xcconfig`:
   ```
   API_KEY=your_api_key
   BASE_URL=your_base_url
   ```
4. Build and run the project

## Architecture

The project follows the MVVM (Model-View-ViewModel) architecture pattern with the following components:

- **ViewModels**: Handle business logic and data transformation
- **Views**: Handle UI presentation and user interaction
- **Models**: Represent data structures
- **Services**: Handle network requests and data persistence

## Key Components

### BasketViewModel

Manages the betting basket functionality:
- Tracks selected events
- Calculates odds and potential winnings
- Handles bet amount updates

### EventsViewModel

Handles the events listing and searching:
- Fetches events from API
- Manages event filtering and searching
- Updates UI state

### Analytics

The project includes analytics tracking for user actions:
- Bet selections
- Basket operations
- Event interactions

## UI Implementation

The project uses a mixed approach for UI implementation:
- **Programmatic UI**: Events, event detail and basket using SnapKit for constraints
- **XIB Files**: Selected event views and cells
- **Custom Components**: Reusable UI elements

## Best Practices

- **Configuration**: API keys and URLs stored in xcconfig files
- **Reactive Programming**: RxSwift for reactive data flow
- **Code Organization**: Clear separation of concerns
- **Error Handling**: Comprehensive API error handling
- **Dependency Management**: Singleton pattern for shared services

## Future Improvements

- Authentication implementation
- Offline mode support
- Additional betting markets
- Unit tests coverage
- UI tests implementation

## Requirements

- Xcode 16.0+
- iOS 15.6+
- Swift 5.0+

## License

This project is available under the MIT license. See the LICENSE file for more info.
