# Supabase to Serverpod Migration Design

## Overview

Migrate Kvitter's backend from Supabase (never deployed) to self-hosted Serverpod on a Mac Mini. Repository-swap approach: replace only the repository layer, keep all BLoCs/Cubits, screens, and models intact. The Supabase code was written but never went live, so there is no data to migrate.

**Target scale:** 1,000–10,000 concurrent users.

## Decisions

- **Strategy**: Repository swap — new Serverpod repository implementations matching existing method signatures
- **Project structure**: Monorepo — server, client, and Flutter app in one repo
- **Auth**: `serverpod_auth` module (Google + Apple OAuth). Anonymous auth dropped.
- **Realtime**: Serverpod streaming (WebSockets) for messages, private chats, and presence
- **File storage**: Serverpod built-in storage on local disk
- **Push notifications**: FCM called directly from Serverpod server code (Firebase Cloud Function eliminated)
- **Crash reporting**: Keep Firebase Crashlytics
- **Hosting**: Self-hosted Serverpod on Mac Mini

---

## 1. Project Structure

```
kvitter/
├── chat/                          # Existing Flutter app
│   ├── lib/
│   │   ├── repository/            # Rewritten to call Serverpod client
│   │   ├── model/                 # Kept as-is (Flutter-side models)
│   │   ├── screens/               # Unchanged
│   │   └── ...
│   └── pubspec.yaml
│
├── kvitter_server/                # Serverpod server
│   ├── lib/src/
│   │   ├── endpoints/             # API endpoints
│   │   └── generated/             # Auto-generated
│   ├── lib/src/models/            # YAML model definitions
│   ├── config/                    # Server config (database, passwords)
│   └── pubspec.yaml
│
├── kvitter_client/                # Generated API client
│   ├── lib/src/
│   │   └── protocol/             # Generated Dart classes
│   └── pubspec.yaml
│
└── kvitter_flutter/               # Serverpod auth UI widgets
    └── pubspec.yaml
```

The Flutter app (`chat/`) adds `kvitter_client` as a path dependency. The repository layer calls methods on the generated client instead of raw database queries.

---

## 2. Database Schema (Serverpod Models)

Serverpod defines tables via YAML files. These generate both the PostgreSQL schema and typed Dart classes.

### `chat_user.yaml`

```yaml
class: ChatUser
table: chat_users
fields:
  userInfoId: int, relation(parent=serverpod_auth:UserInfo)
  email: String
  displayName: String
  gender: int
  birthDate: DateTime?
  showAge: bool
  pictureData: String
  approvedImage: int
  city: String
  countryCode: String
  country: String
  regionName: String
  presence: bool
  lastActive: DateTime
  currentRoomChatId: int?
  fcmToken: String
  blockedBy: List<String>
  imageReports: List<String>
  botReports: List<String>
  languageReports: List<String>
  kvitterCredits: int
  isPremiumUser: bool
  onboardingCompleted: bool
  isAdmin: bool
  searchArray: List<String>
indexes:
  chat_user_last_active_idx:
    fields: lastActive
  chat_user_approved_image_idx:
    fields: approvedImage
  chat_user_display_name_idx:
    fields: displayName
  chat_user_user_info_idx:
    fields: userInfoId
    unique: true
```

### `room_chat.yaml`

```yaml
class: RoomChat
table: room_chats
fields:
  chatName: String
  chatColor: int
  imageUrl: String
  countryCode: String
  enabled: bool
  infoKey: String
  imageOverflow: int
  imageTranslationX: int
  lastMessage: String
  lastMessageIsGiphy: bool
  lastMessageByName: String
  lastMessageTimestamp: DateTime
  lastMessageUserId: int?
indexes:
  room_chat_country_enabled_idx:
    fields: countryCode, enabled
```

### `private_chat.yaml`

```yaml
class: PrivateChat
table: private_chats
fields:
  users: List<String>
  created: DateTime
  initiatedBy: int
  initiatedByUserName: String
  initiatedByUserGender: int
  initiatedByPictureData: String
  chatName: String
  otherUserId: int
  otherUserName: String
  otherUserGender: int
  otherUserPictureData: String
  lastMessage: String
  lastMessageIsGiphy: bool
  lastMessageByName: String
  lastMessageTimestamp: DateTime
  lastMessageUserId: int?
  lastMessageReadBy: List<String>
  sendPushToUserId: int?
```

### `chat_message.yaml`

```yaml
class: ChatMessage
table: messages
fields:
  chatId: int
  isPrivate: bool
  text: String
  chatType: int
  createdById: int
  createdByName: String
  createdByGender: int
  createdByCountryCode: String
  createdByImageUrl: String
  approvedImage: int
  created: DateTime
  birthDate: DateTime?
  showAge: bool
  imageReports: List<String>
  replyId: int?
  replyText: String
  replyChatType: int
  replyCreatedById: int?
  replyCreatedByName: String
  replyCreatedByGender: int
  replyCreatedByCountryCode: String
  replyCreatedByImageUrl: String
  replyApprovedImage: int
  replyCreated: DateTime?
  replyBirthDate: DateTime?
  replyShowAge: bool
  replyImageReports: List<String>
indexes:
  message_chat_created_idx:
    fields: chatId, created
  message_created_by_idx:
    fields: createdById
```

### `report.yaml`

```yaml
class: Report
table: reports
fields:
  messageId: int
  messageText: String
  messageCreated: DateTime
  messageCreatedBy: int
  messageCreatedByGender: int
  messageCreatedByCountryCode: String
  messageCreatedByImageUrl: String
  messageCreatedByDisplayName: String
  reportedBy: int
  reportedAt: DateTime
```

### `feedback.yaml`

```yaml
class: Feedback
table: feedbacks
fields:
  feedback: String
  createdById: int
  createdByName: String
  createdByCountryCode: String
  createdByCountryName: String
  created: DateTime
```

### ID Type

Serverpod uses auto-incrementing `int` IDs. The Flutter-side models use `String` IDs. The repository layer converts between them (`id.toString()` / `int.parse(id)`).

---

## 3. Authentication

### Provider: `serverpod_auth`

The `serverpod_auth` module manages sessions, user records, and OAuth flows.

### Supported Sign-In Methods

- **Google OAuth**: Native sign-in via `serverpod_auth_google_flutter`
- **Apple OAuth**: Native sign-in via `serverpod_auth_apple_flutter`
- **Anonymous**: Dropped — users must sign in with Google or Apple

### Flow

1. User taps "Sign in with Google/Apple" in the Flutter app
2. `serverpod_auth` Flutter package handles the OAuth flow natively
3. On success, Serverpod creates a session + `UserInfo` record
4. A server endpoint creates/updates the corresponding `ChatUser` row linked by `userInfoId`
5. The Flutter client is authenticated — all subsequent endpoint calls include the session

### Session Management

- Serverpod handles session tokens and refresh automatically
- `sessionManager.isSignedIn` replaces auth state checks
- `sessionManager.signedInUser` provides the current user info
- Session persists across app restarts

### Flutter-Side Auth

```dart
class ServerpodAuthRepository {
  final Client _client;
  final SessionManager _sessionManager;

  Future<bool> signInWithGoogle() async {
    var result = await _sessionManager.signInWithGoogle();
    if (result != null) await _ensureChatUserExists();
    return result != null;
  }

  Future<bool> signInWithApple() async {
    var result = await _sessionManager.signInWithApple();
    if (result != null) await _ensureChatUserExists();
    return result != null;
  }

  Future<void> signOut() async {
    await _sessionManager.signOut();
  }

  bool get isSignedIn => _sessionManager.isSignedIn;
  // Wrap sessionManager.addListener callback in a StreamController
  Stream<bool> get onAuthStateChange { ... }
}
```

---

## 4. Server Endpoints

### User Endpoints

```dart
class UserEndpoint extends Endpoint {
  Future<ChatUser?> getUser(Session session, {int? userId}) async { ... }
  Future<void> setInitialUserData(Session session, String email) async { ... }
  Future<void> updateGender(Session session, int gender) async { ... }
  Future<void> updateBirthday(Session session, DateTime birthDate) async { ... }
  Future<void> updateShowAge(Session session, bool showAge) async { ... }
  Future<void> updateDisplayName(Session session, String name, List<String> searchArray) async { ... }
  Future<void> updateProfileImage(Session session, String imageUrl, bool hasNudity) async { ... }
  Future<bool> isNameAvailable(Session session, String displayName) async { ... }
  Future<void> updateLocation(Session session, String city, String countryCode, String country, String regionName) async { ... }
  Future<void> setActive(Session session) async { ... }
  Future<void> setCurrentChatRoom(Session session, int chatId) async { ... }
  Future<void> saveFcmToken(Session session, String token) async { ... }
  Future<void> logout(Session session) async { ... }
  Future<void> deleteAccount(Session session) async { ... }
  Future<void> setPremium(Session session, bool isPremium) async { ... }
}
```

### Block/Report Endpoints

```dart
class ModerationEndpoint extends Endpoint {
  Future<void> blockUser(Session session, int targetUserId) async { ... }
  Future<void> unblockUser(Session session, int targetUserId) async { ... }
  Future<void> reportMessage(Session session, int messageId) async { ... }
  Future<void> reportInappropriateImage(Session session, int reportedUserId) async { ... }
  Future<void> reportBot(Session session, int reportedUserId) async { ... }
  Future<void> reportHatefulLanguage(Session session, int reportedUserId) async { ... }
  Future<void> approveImage(Session session, int userId) async { ... }
  Future<void> rejectImage(Session session, int userId) async { ... }
}
```

### Chat Endpoints

```dart
class ChatEndpoint extends Endpoint {
  Future<RoomChat?> getChat(Session session, int chatId) async { ... }
  Future<List<RoomChat>> getOpenChats(Session session, String countryCode) async { ... }
  Future<void> postFeedback(Session session, String feedback) async { ... }
}
```

### Message Endpoints

```dart
class MessageEndpoint extends Endpoint {
  Future<List<ChatMessage>> getInitialMessages(Session session, int chatId, bool isPrivate) async { ... }
  Future<List<ChatMessage>> getMoreMessages(Session session, int chatId, bool isPrivate, DateTime before) async { ... }
  Future<void> postMessage(Session session, ChatMessage message) async { ... }
}
```

### Private Chat Endpoints

```dart
class PrivateChatEndpoint extends Endpoint {
  Future<PrivateChat?> createPrivateChat(Session session, int otherUserId, String initialMessage) async { ... }
  Future<bool> isPrivateChatAvailable(Session session, int otherUserId) async { ... }
  Future<void> leavePrivateChat(Session session, int chatId) async { ... }
  Future<void> setLastMessageRead(Session session, int chatId) async { ... }
  Future<void> leaveAllPrivateChats(Session session) async { ... }
}
```

### Credit Endpoints

```dart
class CreditEndpoint extends Endpoint {
  Future<void> reduceCredits(Session session, int userId, int amount) async { ... }
  Future<void> increaseCredits(Session session, int userId, int amount) async { ... }
}
```

---

## 5. Realtime & Streaming

### Message Streaming

Serverpod streaming via WebSockets. Clients connect to a chat room channel and receive typed `ChatMessage` objects.

Server-side: a streaming endpoint manages connected clients per chat room. When a message is posted via `MessageEndpoint.postMessage()`, the server broadcasts it to all clients subscribed to that room's channel.

Flutter-side: the repository opens a streaming connection when entering a chat room and exposes a `Stream<List<ChatMessage>>`. The stream emits the full message list (initial load + live updates).

### Private Chats Streaming

Each authenticated user subscribes to a personal channel (`private_{userId}`). When a private chat is created, updated, or a new message arrives, the server pushes the updated `PrivateChat` object.

### Presence (Online Users)

The server tracks connected WebSocket sessions. When a client opens a streaming connection, they are "online." When the WebSocket closes (app backgrounded, killed, network lost), the server's `streamClosed` callback fires and marks the user offline immediately.

This replaces the Supabase approach of polling `last_active` timestamps with a 3-hour window. Presence is now precise and instant.

```dart
class PresenceEndpoint extends Endpoint {
  @override
  Future<void> streamOpened(StreamingSession session) async {
    // Mark user online, add to connected set
  }

  @override
  Future<void> streamClosed(StreamingSession session) async {
    // Mark user offline immediately
  }
}
```

Online users for a given country are pushed to subscribers periodically or on connect/disconnect events.

---

## 6. File Storage

### Configuration

Serverpod's built-in storage with local disk on the Mac Mini. Configured in `config/production.yaml`:

```yaml
storage:
  public:
    type: local
    path: ./public
    publicHost: https://YOUR_MAC_MINI_DOMAIN/storage
```

### Storage Endpoints

```dart
class StorageEndpoint extends Endpoint {
  Future<String?> uploadAvatar(Session session, ByteData imageData) async {
    var userId = await session.auth.authenticatedUserId;
    var path = 'avatars/$userId.png';
    await session.storage.storeFile(storageId: 'public', path: path, byteData: imageData);
    return session.storage.getPublicUrl(storageId: 'public', path: path);
  }

  Future<String?> uploadChatImage(Session session, ByteData imageData) async {
    var fileName = generateRandomString(20);
    var path = 'chat-images/$fileName.png';
    await session.storage.storeFile(storageId: 'public', path: path, byteData: imageData);
    return session.storage.getPublicUrl(storageId: 'public', path: path);
  }

  Future<void> deleteAvatar(Session session) async {
    var userId = await session.auth.authenticatedUserId;
    await session.storage.deleteFile(storageId: 'public', path: 'avatars/$userId.png');
  }

  Future<void> deleteImage(Session session, String path) async {
    // Admin-only check
    await session.storage.deleteFile(storageId: 'public', path: path);
  }
}
```

### Constraints

- Max file size: 2MB per image (enforced in endpoint code)
- Files stored on Mac Mini disk
- Public URLs served through Serverpod's HTTP server

---

## 7. Push Notifications

### Direct FCM from Server

Push notifications are sent directly from Serverpod server code. No Firebase Cloud Function, no PostgreSQL triggers, no webhooks.

When a private message is posted:

```dart
Future<void> postMessage(Session session, ChatMessage message) async {
  // Save message to database
  await ChatMessage.db.insertRow(session, message);

  // If private message, send push notification
  if (message.isPrivate && sendPushToUserId != null) {
    var recipient = await ChatUser.db.findById(session, sendPushToUserId);
    if (recipient != null && recipient.fcmToken.isNotEmpty) {
      await _sendFcmPush(
        fcmToken: recipient.fcmToken,
        title: senderName,
        body: messageText,
      );
    }
  }
}
```

The `_sendFcmPush` helper makes an HTTP POST to FCM HTTP v1 API using a service account key stored in server config.

### Kept on Firebase

- **Firebase Cloud Messaging (FCM)** — free push delivery to devices
- **Firebase Crashlytics** — crash reporting
- **firebase_messaging** Flutter package — receives pushes on the client

### Removed

- `functions/index.js` — deleted entirely
- `pg_net` extension / PostgreSQL webhook triggers — not needed

---

## 8. Packages Changed

### Removed from pubspec.yaml

| Package | Reason |
|---|---|
| supabase_flutter | Replaced by Serverpod |

### Added to pubspec.yaml

| Package | Purpose |
|---|---|
| serverpod_flutter | Serverpod client SDK |
| serverpod_auth_shared_flutter | Auth session management |
| serverpod_auth_google_flutter | Google sign-in |
| serverpod_auth_apple_flutter | Apple sign-in |
| kvitter_client (path) | Generated API client |

### Kept

| Package | Reason |
|---|---|
| firebase_core | Required for Crashlytics and FCM |
| firebase_crashlytics | Free crash reporting |
| firebase_messaging | FCM client-side |

---

## 9. Files Changed

### Deleted

- `lib/repository/supabase_repository.dart`
- `lib/repository/supabase_auth_repository.dart`
- `lib/repository/supabase_storage_repository.dart`
- `lib/repository/supabase_presence_repository.dart`
- `lib/supabase_config.dart`
- `supabase/schema.sql`
- `functions/index.js`
- `scripts/migrate_users.dart`

### New (Flutter app)

- `lib/repository/serverpod_repository.dart` — database operations via endpoints
- `lib/repository/serverpod_auth_repository.dart` — auth via serverpod_auth
- `lib/repository/serverpod_storage_repository.dart` — file storage via endpoints
- `lib/serverpod_config.dart` — server host/port configuration

### New (Server project)

- `kvitter_server/` — full Serverpod server with endpoints, models, config
- `kvitter_client/` — generated client package
- `kvitter_flutter/` — auth UI integration package

### Modified

- `lib/utils/auth_util.dart` — get user ID from Serverpod session
- `lib/repository/fcm_repository.dart` — save token via ServerpodRepository
- `lib/repository/subscription_repository.dart` — same swap
- `lib/main.dart` — initialize Serverpod client, swap providers
- `pubspec.yaml` — swap dependencies
- All BLoC/Cubit files — update repository imports (no logic changes)

### Modified (Login Screen — Anonymous Auth Removal)

- `lib/screens/login/login_screen.dart` — remove "Continue as Guest" button
- `lib/screens/login/bloc/login_bloc.dart` — remove `_onGuestClicked` handler and `signInAnonymously` call
- `lib/screens/login/bloc/login_event.dart` — remove `LoginGuestClickedEvent`

### Unchanged

- All models (`ChatUser`, `Message`, `PrivateChat`, `RoomChat`)
- All other screens
- All utilities (except `auth_util.dart`)

---

## 10. Mac Mini Setup

### Prerequisites

- Dart SDK installed
- PostgreSQL installed (Serverpod requires it)
- Serverpod CLI: `dart pub global activate serverpod_cli`

### Server Configuration

`kvitter_server/config/production.yaml`:

```yaml
apiServer:
  port: 8080
  publicHost: YOUR_MAC_MINI_DOMAIN
  publicPort: 443
  publicScheme: https

database:
  host: localhost
  port: 5432
  name: kvitter
  user: postgres

storage:
  public:
    type: local
    path: ./public
    publicHost: https://YOUR_MAC_MINI_DOMAIN/storage
```

`kvitter_server/config/passwords.yaml`:

```yaml
database: YOUR_DB_PASSWORD
serviceSecret: YOUR_SERVICE_SECRET
```

### Running

```bash
cd kvitter_server
dart bin/main.dart --mode production
```

### SSL

Same as Supabase plan: Cloudflare Tunnel, nginx, or Caddy for HTTPS termination in front of the Serverpod HTTP server.

### Backups

Regular PostgreSQL `pg_dump` cron job + file system backup for stored images.
