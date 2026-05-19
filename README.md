# Aether: High-Concurrency MMORPG Nervous System

A robust, scalable "nervous system" for a global MMORPG, built with Flutter and Firebase. This application is engineered to handle massive concurrent player interactions (such as thousands of players joining a raid simultaneously or chatting globally) without UI jank, data corruption, or exorbitant Firebase billing costs.

## Features

- **Global Pulse (World Boss Timer):** A highly optimized, real-time 100ms ticking countdown. Calculates time locally to eliminate recurring Firebase read costs.
- **Atomic Geo-Raids:** Handles extreme concurrency ("Thundering Herd" problem). If 50 players attempt to claim the final 15 slots in the exact same millisecond, the system guarantees exactly 15 succeed using Firestore Transactions and strict Security Rules.
- **Engagement Chat:** A real-time, global communication link optimized for O(1) read costs per new message, regardless of chat history length.
- **Frictionless Authentication:** Utilizes Firebase Anonymous Authentication to instantly grant users session persistence without login walls.

## The Firebase Bill (Cost & Sharding)

To prevent a massive 'Read' cost bill when 10,000 players are chatting, we query the `global_chat` collection using `.orderBy('timestamp').limitToLast(50)`. By limiting the initial fetch to the 50 most recent messages, we cap the baseline load cost, while subsequent real-time `snapshots()` only charge 1 document read per new incoming message rather than re-reading the entire history. Furthermore, because the chat is a high-velocity, append-only stream, we handle UI state locally by diffing incoming snapshots to prevent redundant layout rebuilds.

## Architecture

The application strictly adheres to **Clean Architecture** principles and **SOLID** design:
- **Presentation Layer:** `flutter_bloc` (Cubit) for highly performant, predictable state management.
- **Domain Layer:** Pure Dart entities and use cases (e.g., `AetherUser`, `JoinRaidUseCase`).
- **Data Layer:** Repository implementations and data sources handling Firebase serialization.
- **Dependency Injection:** Centralized using `get_it` for lazy loading and singleton management (e.g., ensuring `RaidService` only maintains one active snapshot listener).

### Project Structure

```text
lib/
├── core/                   # Cross-cutting concerns
│   ├── di/                 # Dependency Injection (GetIt)
│   ├── error/              # Failure models
│   ├── theme/              # App theme & Color palette
│   └── utils/              # App-wide constants
├── features/
│   └── aether/             # Main feature module
│       ├── data/           # Data Layer (Models, Repositories, Data Sources)
│       ├── domain/         # Domain Layer (Entities, Use Cases, Repository Interfaces)
│       └── presentation/   # Presentation Layer (Cubits, Widgets, Pages)
├── services/               # External services
│   └── raid_service.dart   # Firestore Transaction logic for Concurrency
└── main.dart               # Entry point
```


## Setup Instructions

### 1. Flutter Setup
Ensure you have the Flutter SDK installed.
```bash
flutter pub get
flutter run
```

### 2. Firebase Console Configuration
To run this application, your Firebase project must be configured as follows:

**Authentication:**
- Enable **Anonymous** Sign-in provider.

**Firestore Collections:**
- `events/dragon_raid`: Document containing `max_slots` (15), `slots_filled` (0), and `participants` (empty array).
- `world_boss/active_event`: Document containing `end_time` (future Timestamp) and `total_duration_seconds` (e.g., 1800).
- `global_chat`: (Auto-generates upon first message sent).

**Security Rules:**
Deploy the strict security rules to enforce the 15-player cap at the database level and prevent chat spoofing.

## Testing

The project includes an aggressive concurrency test to verify the transaction integrity.
```bash
flutter test test/raid_concurrency_test.dart
```
This simulates 50 simultaneous join requests and asserts that exactly 15 succeed.

## Screens


## 📱 Screenshots
<div align="center">
  <table border="0">
    <tr>
      <td width="48%" align="center" valign="top">
          <img src= "https://github.com/user-attachments/assets/a7ab7488-9217-48a4-bb37-49a86ed1c87d" width="100%" />
        </a>
        <br><br>
        <a href="https://github.com/oOSatyamOo/GitHub-Language-Stats">
          <img src="https://github.com/user-attachments/assets/d59afb6b-e463-4e0a-bfbd-82c389b72d94"  width="100%" />
        </a>
      </td>
       <td width="48%" align="center" valign="top">
          <img src="https://github.com/user-attachments/assets/4933ec90-96ec-420a-a27d-a05df336e3e6" width="100%" />
        </a>
        <br><br>
        <a href="https://github.com/oOSatyamOo/GitHub-Language-Stats">
          <img src="https://github.com/user-attachments/assets/34301b20-597d-44a8-9148-d50776b7928d" width="100%" />
        </a>
      </td>
    </tr>
  </table>
</div>

