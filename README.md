<div align="center">
  <img src="TODO" alt="App Logo TODO" width="120">

  # Quick Room

  > **TODO:** Add a short, catchy description here. (First Iteration)
  Smart room reservation app utilizing iBeacon technology for presence detection and automated room management.

  <!-- Badges -->
  <p>
    <img src="https://img.shields.io/badge/Swift-6.0-F05138.svg?style=flat&logo=swift" alt="Swift 6.0">
    <img src="https://img.shields.io/badge/iOS-17.0+-000000.svg?style=flat&logo=apple" alt="iOS">
  </p>
</div>

---

## Overview

> **TODO:** Expand this overview in future iterations.

Quick Room is a smart reservation application designed to optimize room usage by utilizing iBeacon technology to detect physical presence in a room. It ensures meeting spaces are used efficiently by monitoring occupancy, sending contextual notifications to users, and automatically managing room availability based on actual attendance.

### Previews

<div align="center">
  <img src="TODO" width="22%" alt="TODO">
  <img src="TODO" width="22%" alt="TODO">
  <img src="TODO" width="22%" alt="TODO">
  <img src="TODO" width="22%" alt="TODO">
</div>

## Key Features

> **TODO:** Refine and detail these features as development progresses.

* **Presence Detection**: Uses iBeacon to detect if the person who booked the room is actually inside.
* **Time Expiration Alerts**: Notifies the person currently inside the room when their reserved time is running out.
* **Meeting Reminders**: Alerts users to let them know if they have upcoming meetings.
* **No-Show Reminders**: Notifies users if they have booked a meeting room but have not yet entered it.
* **Auto-Release**: Automatically frees up the room after a few minutes (grace period) if the user who booked it fails to show up.

## Technical Architecture

The application follows a modular, feature-based architecture heavily inspired by Domain-Driven Design (DDD) and Service-Oriented principles to ensure a clean separation of concerns[cite: 1].

*   **UI Layer (SwiftUI)**: Organized by features (e.g., `Home`, `Main`, `Onboarding`, `Reserve`) rather than structural types. It utilizes specialized components (like `RelativePolygonShape` and `TimelineSliderView`) for a highly custom smart-room interface[cite: 1].
*   **Domain Layer**: Encapsulates the core business logic and models, safely separating strongly-typed entities such as `Room`, `Reservation`, and `TimelineTick` from network or UI implementations[cite: 1].
*   **Core Services**: Acts as the central nervous system of the app. Specific managers handle distinct responsibilities:
    *   `BeaconMonitoringService`: Interfaces with device hardware to continuously scan for iBeacons and determine room proximity[cite: 1].
    *   `AuthService` & `KeychainStore`: Manages user sessions and securely stores sensitive credentials natively on the device[cite: 1].
    *   `ReservationService`: Coordinates room booking rules, grace periods, and auto-release logic[cite: 1].
*   **Network Layer**: A dedicated API Client handles backend synchronization using Data Transfer Objects (DTOs) for robust JSON parsing. It also includes specialized modules like `PresenceReporter` to ping the backend when a user enters a room and `PushRegistrar` for remote notifications[cite: 1].
*   **Permissions Management**: Abstracted into standalone services (`LocationPermissionService`, `NotificationPermissionService`) to ensure smooth user onboarding and lifecycle handling[cite: 1].

## Tech Stack

**Core Application**
*   **Language:** Swift 6.0
*   **UI Framework:** SwiftUI (iOS 17.0+)
*   **Architecture Pattern:** Domain-Driven / Service-Oriented Architecture

**Apple Frameworks & Libraries**
*   **CoreLocation:** Used extensively for iBeacon ranging and background presence detection
*   **UserNotifications:** Triggers time expirations, no-show alerts, and meeting reminders
*   **Netowrk:** Powers the custom API client for robust and secure RESTful network communication and backend synchronization
*   **CoreHaptics:** Provides tactile feedback during key interactions, such as confirming a reservation or receiving an alert, enhancing the smart room experience

## License

> **TODO:** Add license information here.

## Authors

> **TODO:** Add author and contact details here.
