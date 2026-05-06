# Supabase to Serverpod Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Supabase repository layer with Serverpod, creating a self-hosted Dart server for all database, auth, realtime, storage, and push notification operations.

**Architecture:** Monorepo with Serverpod server (`kvitter_server/`), generated client (`kvitter_client/`), and auth UI integration (`kvitter_flutter/`) alongside the existing Flutter app (`chat/`). Repository swap pattern — the Flutter-side models, BLoCs, and screens remain unchanged; only the repository layer is rewritten to call Serverpod endpoints via the generated client.

**Tech Stack:** Serverpod 2.x, serverpod_auth (Google + Apple OAuth), PostgreSQL, Dart, Flutter

**Key context:**
- The Flutter app lives in `chat/` — this is the working directory
- The Serverpod projects live in sibling directories: `../kvitter_server/`, `../kvitter_client/`, `../kvitter_flutter/`
- Serverpod uses `int` auto-incrementing IDs; Flutter models use `String` IDs — the repository converts between them
- Flutter `ChatUser.lastActive` is `int` (millisecondsSinceEpoch); Serverpod stores `DateTime` — convert in repository
- Anonymous auth is dropped — remove "Continue as Guest" from login screen
- Firebase Cloud Function (`functions/index.js`) is deleted — push notifications sent directly from server

---

## File Structure

### New files (Server — `../kvitter_server/`)

| File | Responsibility |
|---|---|
| `lib/src/models/chat_user.yaml` | ChatUser table definition |
| `lib/src/models/room_chat.yaml` | RoomChat table definition |
| `lib/src/models/private_chat.yaml` | PrivateChat table definition |
| `lib/src/models/chat_message.yaml` | ChatMessage table definition |
| `lib/src/models/report.yaml` | Report table definition |
| `lib/src/models/user_feedback.yaml` | UserFeedback table definition |
| `lib/src/endpoints/user_endpoint.dart` | User CRUD operations |
| `lib/src/endpoints/moderation_endpoint.dart` | Block, unblock, report operations |
| `lib/src/endpoints/chat_endpoint.dart` | Room chat queries + message CRUD + pagination |
| `lib/src/endpoints/private_chat_endpoint.dart` | Private chat create, leave, read receipts |
| `lib/src/endpoints/utility_endpoint.dart` | Credits, feedback, storage operations |
| `lib/src/endpoints/messaging_endpoint.dart` | WebSocket streaming for messages, presence, private chats |
| `lib/src/util/fcm_helper.dart` | Send push notifications via FCM HTTP v1 API |

### New files (Flutter — `chat/lib/`)

| File | Responsibility |
|---|---|
| `repository/serverpod_repository.dart` | Main data repository — calls Serverpod endpoints |
| `repository/serverpod_auth_repository.dart` | Auth — wraps serverpod_auth session manager |
| `repository/serverpod_storage_repository.dart` | File storage — uploads via Serverpod endpoints |
| `serverpod_config.dart` | Server host/port configuration |

### Deleted files

| File | Reason |
|---|---|
| `lib/repository/supabase_repository.dart` | Replaced by serverpod_repository.dart |
| `lib/repository/supabase_auth_repository.dart` | Replaced by serverpod_auth_repository.dart |
| `lib/repository/supabase_storage_repository.dart` | Replaced by serverpod_storage_repository.dart |
| `lib/repository/supabase_presence_repository.dart` | Presence handled by messaging_endpoint.dart |
| `lib/supabase_config.dart` | Replaced by serverpod_config.dart |
| `supabase/schema.sql` | Replaced by Serverpod YAML models |
| `functions/index.js` | FCM sent from Serverpod server directly |
| `scripts/migrate_users.dart` | No data to migrate |

### Modified files (Flutter — `chat/lib/`)

| File | Change |
|---|---|
| `pubspec.yaml` | Remove supabase_flutter, add serverpod + kvitter_client |
| `utils/auth_util.dart` | Get user ID from Serverpod session |
| `repository/fcm_repository.dart` | Depend on ServerpodRepository |
| `repository/subscription_repository.dart` | Depend on ServerpodRepository |
| `main.dart` | Initialize Serverpod client, swap all providers |
| `screens/login/login_screen.dart` | Remove "Continue as Guest" button |
| `screens/login/bloc/login_bloc.dart` | Remove anonymous auth handler, swap to ServerpodAuthRepository |
| `screens/login/bloc/login_event.dart` | Remove LoginGuestClickedEvent |
| `screens/splash/bloc/splash_bloc.dart` | Check Serverpod session instead of Supabase auth |
| `screens/account/bloc/account_bloc.dart` | Swap SupabaseRepository + SupabaseAuthRepository |
| `screens/account/account_screen.dart` | Swap provider reads |
| `screens/message_holder/message_holder_screen.dart` | Remove SupabasePresenceRepository, swap provider reads |
| `screens/message_holder/bloc/message_holder_bloc.dart` | Swap SupabaseRepository |
| `screens/messages/messages_screen.dart` | Swap provider reads |
| `screens/messages/bloc/messages_bloc.dart` | Swap SupabaseRepository + SupabaseStorageRepository |
| 30+ additional BLoC/screen files | Mechanical import swaps (SupabaseRepository → ServerpodRepository) |

---

### Task 1: Scaffold Serverpod project

**Files:**
- Create: `../kvitter_server/` (entire project scaffold)
- Create: `../kvitter_client/` (entire project scaffold)
- Create: `../kvitter_flutter/` (entire project scaffold)

- [ ] **Step 1: Install Serverpod CLI**

```bash
dart pub global activate serverpod_cli
```

Expected: `Activated serverpod_cli` (or already activated)

- [ ] **Step 2: Create the Serverpod project**

Run from the parent directory (one level above `chat/`):

```bash
cd /Users/lbofhn/Documents/Kvitter
serverpod create --template server kvitter
```

This creates three directories: `kvitter_server/`, `kvitter_client/`, `kvitter_flutter/`.

Expected: Project scaffold created with default example endpoint.

- [ ] **Step 3: Verify the project compiles**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
dart pub get
```

Expected: Dependencies resolved successfully.

- [ ] **Step 4: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/ kvitter_flutter/
git commit -m "feat: scaffold Serverpod project structure"
```

---

### Task 2: Define server model YAML files

**Files:**
- Create: `../kvitter_server/lib/src/models/chat_user.yaml`
- Create: `../kvitter_server/lib/src/models/room_chat.yaml`
- Create: `../kvitter_server/lib/src/models/private_chat.yaml`
- Create: `../kvitter_server/lib/src/models/chat_message.yaml`
- Create: `../kvitter_server/lib/src/models/report.yaml`
- Create: `../kvitter_server/lib/src/models/user_feedback.yaml`
- Delete: `../kvitter_server/lib/src/models/example.yaml` (default scaffold file, if present)

- [ ] **Step 1: Delete the example model**

Remove any default example model that `serverpod create` generated:

```bash
rm -f /Users/lbofhn/Documents/Kvitter/kvitter_server/lib/src/models/example.yaml
```

- [ ] **Step 2: Create chat_user.yaml**

Create `../kvitter_server/lib/src/models/chat_user.yaml`:

```yaml
class: ChatUser
table: chat_users
fields:
  userInfoId: int
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

- [ ] **Step 3: Create room_chat.yaml**

Create `../kvitter_server/lib/src/models/room_chat.yaml`:

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

- [ ] **Step 4: Create private_chat.yaml**

Create `../kvitter_server/lib/src/models/private_chat.yaml`:

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

- [ ] **Step 5: Create chat_message.yaml**

Create `../kvitter_server/lib/src/models/chat_message.yaml`:

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

- [ ] **Step 6: Create report.yaml**

Create `../kvitter_server/lib/src/models/report.yaml`:

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

- [ ] **Step 7: Create user_feedback.yaml**

Create `../kvitter_server/lib/src/models/user_feedback.yaml`:

```yaml
class: UserFeedback
table: user_feedbacks
fields:
  feedback: String
  createdById: int
  createdByName: String
  createdByCountryCode: String
  createdByCountryName: String
  created: DateTime
```

Note: named `UserFeedback` to avoid collision with Dart's built-in `Feedback` widget class.

- [ ] **Step 8: Generate code**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate
```

Expected: Generated files appear in `lib/src/generated/` and `../kvitter_client/lib/src/protocol/`.

- [ ] **Step 9: Verify server compiles**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
dart analyze
```

Expected: No errors.

- [ ] **Step 10: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/
git commit -m "feat: define Serverpod model YAML files and generate code"
```

---

### Task 3: Add serverpod_auth module

**Files:**
- Modify: `../kvitter_server/pubspec.yaml`
- Modify: `../kvitter_server/lib/server.dart` (or `lib/src/server.dart` — wherever the `Serverpod` instance is created)
- Modify: `../kvitter_flutter/pubspec.yaml`

- [ ] **Step 1: Add serverpod_auth_server to server pubspec**

In `../kvitter_server/pubspec.yaml`, add to dependencies:

```yaml
dependencies:
  serverpod_auth_server: ^2.0.0
```

Run:
```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
dart pub get
```

- [ ] **Step 2: Register the auth module in the server**

Find the file where `Serverpod` is instantiated (typically `lib/server.dart` or similar). Add the auth module:

```dart
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

// In the server setup, add:
auth.AuthConfig.set(auth.AuthConfig(
  sendValidationEmail: null,
  sendPasswordResetEmail: null,
));
```

And register the module in the Serverpod constructor's `authenticationHandler`:

```dart
var pod = Serverpod(
  args,
  Protocol(),
  Endpoints(),
  authenticationHandler: auth.ServerAuthenticationHandler(),
);
```

- [ ] **Step 3: Add auth packages to kvitter_flutter**

In `../kvitter_flutter/pubspec.yaml`, add:

```yaml
dependencies:
  serverpod_auth_shared_flutter: ^2.0.0
  serverpod_auth_google_flutter: ^2.0.0
  serverpod_auth_apple_flutter: ^2.0.0
```

Run:
```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_flutter
dart pub get
```

- [ ] **Step 4: Regenerate code**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate
```

- [ ] **Step 5: Verify**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
dart analyze
```

Expected: No errors.

- [ ] **Step 6: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/ kvitter_flutter/
git commit -m "feat: add serverpod_auth module for Google and Apple OAuth"
```

---

### Task 4: Write User endpoint

**Files:**
- Create: `../kvitter_server/lib/src/endpoints/user_endpoint.dart`
- Delete: `../kvitter_server/lib/src/endpoints/example_endpoint.dart` (default scaffold file, if present)

- [ ] **Step 1: Delete example endpoint**

```bash
rm -f /Users/lbofhn/Documents/Kvitter/kvitter_server/lib/src/endpoints/example_endpoint.dart
```

- [ ] **Step 2: Create user_endpoint.dart**

Create `../kvitter_server/lib/src/endpoints/user_endpoint.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class UserEndpoint extends Endpoint {
  Future<ChatUser?> getUser(Session session, {int? userId}) async {
    final uid = userId ?? await session.auth.authenticatedUserId;
    if (uid == null) return null;
    return await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(uid),
    );
  }

  Future<ChatUser> ensureUserExists(Session session, String email) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) throw Exception('Not authenticated');

    var existing = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (existing != null) return existing;

    var user = ChatUser(
      userInfoId: authUserId,
      email: email,
      displayName: '',
      gender: -1,
      showAge: true,
      pictureData: '',
      approvedImage: 0,
      city: '',
      countryCode: '',
      country: '',
      regionName: '',
      presence: false,
      lastActive: DateTime.now(),
      fcmToken: '',
      blockedBy: [],
      imageReports: [],
      botReports: [],
      languageReports: [],
      kvitterCredits: 0,
      isPremiumUser: false,
      onboardingCompleted: false,
      isAdmin: false,
      searchArray: [],
    );
    return await ChatUser.db.insertRow(session, user);
  }

  Future<void> updateGender(Session session, int gender) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.gender = gender;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateBirthday(Session session, DateTime birthDate) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.birthDate = birthDate;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateShowAge(Session session, bool showAge) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.showAge = showAge;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateDisplayName(
      Session session, String name, List<String> searchArray) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.displayName = name;
    user.searchArray = searchArray;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateProfileImage(
      Session session, String imageUrl, bool hasNudity) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.pictureData = imageUrl;
    user.approvedImage = hasNudity ? 0 : 2;
    user.imageReports = [];
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<bool> isNameAvailable(Session session, String displayName) async {
    var existing = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.displayName.equals(displayName),
    );
    return existing == null;
  }

  Future<void> updateLocation(Session session, String city, String countryCode,
      String country, String regionName) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.city = city;
    user.countryCode = countryCode;
    user.country = country;
    user.regionName = regionName;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> setActive(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.presence = true;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> setCurrentChatRoom(Session session, int chatId) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.currentRoomChatId = chatId == 0 ? null : chatId;
    user.presence = true;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> saveFcmToken(Session session, String token) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.fcmToken = token;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> logout(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.presence = false;
    user.fcmToken = '';
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> deleteAccount(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    await ChatUser.db.deleteRow(session, user);
  }

  Future<void> setPremium(Session session, bool isPremium) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.isPremiumUser = isPremium;
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> deletePhoto(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.pictureData = '';
    user.approvedImage = 0;
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> updateImageNotReviewedStatus(Session session) async {
    var user = await _getAuthenticatedUser(session);
    if (user == null) return;
    user.approvedImage = 0;
    await ChatUser.db.updateRow(session, user);
  }

  Future<ChatUser?> _getAuthenticatedUser(Session session) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return null;
    return await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
  }
}
```

- [ ] **Step 3: Regenerate and verify**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate && dart analyze
```

Expected: No errors.

- [ ] **Step 4: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/
git commit -m "feat: add User endpoint with all user CRUD operations"
```

---

### Task 5: Write Moderation endpoint

**Files:**
- Create: `../kvitter_server/lib/src/endpoints/moderation_endpoint.dart`

- [ ] **Step 1: Create moderation_endpoint.dart**

Create `../kvitter_server/lib/src/endpoints/moderation_endpoint.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class ModerationEndpoint extends Endpoint {
  Future<void> blockUser(Session session, int targetUserId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(session, targetUserId);
    if (target == null) return;

    if (!target.blockedBy.contains(myUser.id.toString())) {
      target.blockedBy = [...target.blockedBy, myUser.id.toString()];
      await ChatUser.db.updateRow(session, target);
    }
  }

  Future<void> unblockUser(Session session, int targetUserId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(session, targetUserId);
    if (target == null) return;

    target.blockedBy = target.blockedBy
        .where((id) => id != myUser.id.toString())
        .toList();
    await ChatUser.db.updateRow(session, target);
  }

  Future<void> reportMessage(Session session, int messageId, String messageText,
      DateTime messageCreated, int messageCreatedBy, int messageCreatedByGender,
      String messageCreatedByCountryCode, String messageCreatedByImageUrl,
      String messageCreatedByDisplayName) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    await Report.db.insertRow(session, Report(
      messageId: messageId,
      messageText: messageText,
      messageCreated: messageCreated,
      messageCreatedBy: messageCreatedBy,
      messageCreatedByGender: messageCreatedByGender,
      messageCreatedByCountryCode: messageCreatedByCountryCode,
      messageCreatedByImageUrl: messageCreatedByImageUrl,
      messageCreatedByDisplayName: messageCreatedByDisplayName,
      reportedBy: myUser.id!,
      reportedAt: DateTime.now(),
    ));
  }

  Future<void> reportInappropriateImage(
      Session session, int reportedUserId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(session, reportedUserId);
    if (target == null) return;

    if (!target.imageReports.contains(myUser.id.toString())) {
      target.imageReports = [...target.imageReports, myUser.id.toString()];
    }
    target.approvedImage = 0;
    await ChatUser.db.updateRow(session, target);
  }

  Future<void> reportBot(Session session, int reportedUserId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(session, reportedUserId);
    if (target == null) return;

    if (!target.botReports.contains(myUser.id.toString())) {
      target.botReports = [...target.botReports, myUser.id.toString()];
      await ChatUser.db.updateRow(session, target);
    }
  }

  Future<void> reportHatefulLanguage(
      Session session, int reportedUserId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var target = await ChatUser.db.findById(session, reportedUserId);
    if (target == null) return;

    if (!target.languageReports.contains(myUser.id.toString())) {
      target.languageReports = [
        ...target.languageReports,
        myUser.id.toString()
      ];
      await ChatUser.db.updateRow(session, target);
    }
  }

  Future<void> approveImage(Session session, int userId) async {
    var user = await ChatUser.db.findById(session, userId);
    if (user == null) return;
    user.approvedImage = 2;
    user.imageReports = [];
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> rejectImage(Session session, int userId) async {
    var user = await ChatUser.db.findById(session, userId);
    if (user == null) return;
    user.approvedImage = 1;
    await ChatUser.db.updateRow(session, user);
  }

  Future<List<ChatUser>> getUnapprovedImages(Session session) async {
    return await ChatUser.db.find(
      session,
      where: (t) => t.approvedImage.equals(0) & t.pictureData.notEquals(''),
    );
  }
}
```

- [ ] **Step 2: Regenerate and verify**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate && dart analyze
```

- [ ] **Step 3: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/
git commit -m "feat: add Moderation endpoint for block, report, and image review"
```

---

### Task 6: Write Chat and Message endpoints

**Files:**
- Create: `../kvitter_server/lib/src/endpoints/chat_endpoint.dart`

- [ ] **Step 1: Create chat_endpoint.dart**

Create `../kvitter_server/lib/src/endpoints/chat_endpoint.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../util/fcm_helper.dart';

class ChatEndpoint extends Endpoint {
  Future<RoomChat?> getChat(Session session, int chatId) async {
    return await RoomChat.db.findById(session, chatId);
  }

  Future<List<RoomChat>> getOpenChats(
      Session session, String countryCode, bool isDebug) async {
    if (isDebug) {
      return await RoomChat.db.find(session);
    }
    return await RoomChat.db.find(
      session,
      where: (t) =>
          t.enabled.equals(true) &
          (t.countryCode.equals('all') | t.countryCode.equals(countryCode)),
    );
  }

  Future<List<ChatMessage>> getInitialMessages(
      Session session, int chatId, bool isPrivate) async {
    return await ChatMessage.db.find(
      session,
      where: (t) => t.chatId.equals(chatId) & t.isPrivate.equals(isPrivate),
      orderBy: (t) => t.created,
      orderDescending: true,
      limit: 20,
    );
  }

  Future<List<ChatMessage>> getMoreMessages(
      Session session, int chatId, bool isPrivate, DateTime before) async {
    return await ChatMessage.db.find(
      session,
      where: (t) =>
          t.chatId.equals(chatId) &
          t.isPrivate.equals(isPrivate) &
          t.created.isSmallerThan(before),
      orderBy: (t) => t.created,
      orderDescending: true,
      limit: 20,
    );
  }

  Future<ChatMessage> postMessage(Session session, ChatMessage message) async {
    var inserted = await ChatMessage.db.insertRow(session, message);

    if (message.isPrivate) {
      var privateChat = await PrivateChat.db.findById(session, message.chatId);
      if (privateChat != null) {
        privateChat.lastMessage = message.text;
        privateChat.lastMessageIsGiphy = message.chatType == 3;
        privateChat.lastMessageByName = message.createdByName;
        privateChat.lastMessageTimestamp = DateTime.now();
        privateChat.lastMessageUserId = message.createdById;
        privateChat.lastMessageReadBy = [message.createdById.toString()];
        await PrivateChat.db.updateRow(session, privateChat);

        if (privateChat.sendPushToUserId != null) {
          var recipient = await ChatUser.db.findById(
              session, privateChat.sendPushToUserId!);
          if (recipient != null && recipient.fcmToken.isNotEmpty) {
            await FcmHelper.sendPush(
              session: session,
              fcmToken: recipient.fcmToken,
              title: message.createdByName,
              body: message.text,
            );
          }
        }
      }
    }

    return inserted;
  }

  Future<void> postFeedback(Session session, String feedback,
      String createdByName, String countryCode, String countryName) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    await UserFeedback.db.insertRow(session, UserFeedback(
      feedback: feedback,
      createdById: myUser.id!,
      createdByName: createdByName,
      createdByCountryCode: countryCode,
      createdByCountryName: countryName,
      created: DateTime.now(),
    ));
  }

  Future<void> reduceCredits(Session session, int userId, int amount) async {
    var user = await ChatUser.db.findById(session, userId);
    if (user == null) return;
    user.kvitterCredits = user.kvitterCredits - amount;
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> increaseCredits(Session session, int userId, int amount) async {
    var user = await ChatUser.db.findById(session, userId);
    if (user == null) return;
    user.kvitterCredits = user.kvitterCredits + amount;
    await ChatUser.db.updateRow(session, user);
  }
}
```

- [ ] **Step 2: Regenerate and verify**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate && dart analyze
```

Note: This will show an error for `FcmHelper` since it doesn't exist yet. That's fine — it's created in Task 8.

- [ ] **Step 3: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/
git commit -m "feat: add Chat endpoint with messages, feedback, and credits"
```

---

### Task 7: Write Private Chat endpoint

**Files:**
- Create: `../kvitter_server/lib/src/endpoints/private_chat_endpoint.dart`

- [ ] **Step 1: Create private_chat_endpoint.dart**

Create `../kvitter_server/lib/src/endpoints/private_chat_endpoint.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class PrivateChatEndpoint extends Endpoint {
  Future<PrivateChat?> createPrivateChat(Session session, int otherUserId,
      String initialMessage, String myName, int myGender, String myPictureData,
      String otherName, int otherGender, String otherPictureData) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return null;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return null;

    var trimmed = initialMessage.trim();
    if (trimmed.isEmpty || trimmed.length > 1000) return null;

    var chat = PrivateChat(
      users: [myUser.id.toString(), otherUserId.toString()],
      created: DateTime.now(),
      initiatedBy: myUser.id!,
      initiatedByUserName: myName,
      initiatedByUserGender: myGender,
      initiatedByPictureData: myPictureData,
      chatName: '$otherName $myName',
      otherUserId: otherUserId,
      otherUserName: otherName,
      otherUserGender: otherGender,
      otherUserPictureData: otherPictureData,
      lastMessage: '',
      lastMessageIsGiphy: false,
      lastMessageByName: '',
      lastMessageTimestamp: DateTime.now(),
      lastMessageReadBy: [myUser.id.toString()],
      sendPushToUserId: otherUserId,
    );

    var inserted = await PrivateChat.db.insertRow(session, chat);
    return inserted;
  }

  Future<bool> isPrivateChatAvailable(
      Session session, int otherUserId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return false;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return false;

    var chats = await PrivateChat.db.find(session);
    var existing = chats.where((c) =>
        c.users.contains(myUser.id.toString()) &&
        c.users.contains(otherUserId.toString()));
    return existing.isEmpty;
  }

  Future<void> leavePrivateChat(Session session, int chatId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var chat = await PrivateChat.db.findById(session, chatId);
    if (chat == null) return;

    chat.users = chat.users
        .where((id) => id != myUser.id.toString())
        .toList();

    if (chat.users.length < 2) {
      await ChatMessage.db.deleteWhere(
        session,
        where: (t) => t.chatId.equals(chatId),
      );
      await PrivateChat.db.deleteRow(session, chat);
    } else {
      await PrivateChat.db.updateRow(session, chat);
    }
  }

  Future<void> setLastMessageRead(Session session, int chatId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var chat = await PrivateChat.db.findById(session, chatId);
    if (chat == null) return;

    if (!chat.lastMessageReadBy.contains(myUser.id.toString())) {
      chat.lastMessageReadBy = [
        ...chat.lastMessageReadBy,
        myUser.id.toString()
      ];
      await PrivateChat.db.updateRow(session, chat);
    }
  }

  Future<void> leaveAllPrivateChats(Session session) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    var allChats = await PrivateChat.db.find(session);
    var myChats = allChats
        .where((c) => c.users.contains(myUser.id.toString()))
        .toList();

    for (var chat in myChats) {
      chat.users = chat.users
          .where((id) => id != myUser.id.toString())
          .toList();

      if (chat.users.length < 2) {
        await ChatMessage.db.deleteWhere(
          session,
          where: (t) => t.chatId.equals(chat.id!),
        );
        await PrivateChat.db.deleteRow(session, chat);
      } else {
        await PrivateChat.db.updateRow(session, chat);
      }
    }
  }

  Future<List<PrivateChat>> getPrivateChats(Session session) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return [];

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return [];

    var allChats = await PrivateChat.db.find(session);
    return allChats
        .where((c) => c.users.contains(myUser.id.toString()))
        .toList();
  }

  Future<PrivateChat?> getPrivateChatWithUser(
      Session session, int otherUserId) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return null;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return null;

    var allChats = await PrivateChat.db.find(session);
    return allChats
        .where((c) =>
            c.users.contains(myUser.id.toString()) &&
            c.users.contains(otherUserId.toString()))
        .firstOrNull;
  }
}
```

- [ ] **Step 2: Regenerate and verify**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate && dart analyze
```

- [ ] **Step 3: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/
git commit -m "feat: add Private Chat endpoint with create, leave, and read receipts"
```

---

### Task 8: Write FCM push helper and Storage endpoint

**Files:**
- Create: `../kvitter_server/lib/src/util/fcm_helper.dart`
- Create: `../kvitter_server/lib/src/endpoints/storage_endpoint.dart`

- [ ] **Step 1: Create fcm_helper.dart**

Create `../kvitter_server/lib/src/util/fcm_helper.dart`:

```dart
import 'dart:convert';
import 'package:serverpod/serverpod.dart';

class FcmHelper {
  static Future<void> sendPush({
    required Session session,
    required String fcmToken,
    required String title,
    required String body,
  }) async {
    try {
      final serviceAccountKey = session.passwords['fcmServiceAccountKey'];
      if (serviceAccountKey == null) {
        session.log('FCM service account key not configured', level: LogLevel.warning);
        return;
      }

      final response = await session.serverpod.httpClient.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serviceAccountKey',
        },
        body: jsonEncode({
          'to': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
        }),
      );

      if (response.statusCode != 200) {
        session.log('FCM push failed: ${response.statusCode}', level: LogLevel.warning);
      }
    } catch (e) {
      session.log('FCM push error: $e', level: LogLevel.error);
    }
  }
}
```

Note: The FCM server key goes in `config/passwords.yaml` as `fcmServiceAccountKey`. The implementer should check the exact Serverpod HTTP client API — if `session.serverpod.httpClient` is not available, use `dart:io`'s `HttpClient` or the `http` package instead.

- [ ] **Step 2: Create storage_endpoint.dart**

Create `../kvitter_server/lib/src/endpoints/storage_endpoint.dart`:

```dart
import 'dart:math';
import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class StorageEndpoint extends Endpoint {
  static const _maxFileSize = 2 * 1024 * 1024; // 2MB
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final _rnd = Random();

  static String _randomString(int length) => String.fromCharCodes(
      Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<String?> uploadAvatar(Session session, ByteData imageData) async {
    if (imageData.lengthInBytes > _maxFileSize) return null;

    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return null;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return null;

    var path = 'avatars/${myUser.id}.png';
    await session.storage.storeFile(
      storageId: 'public',
      path: path,
      byteData: imageData,
    );
    return session.storage.getPublicUrl(storageId: 'public', path: path);
  }

  Future<String?> uploadChatImage(Session session, ByteData imageData) async {
    if (imageData.lengthInBytes > _maxFileSize) return null;

    var path = 'chat-images/${_randomString(20)}.png';
    await session.storage.storeFile(
      storageId: 'public',
      path: path,
      byteData: imageData,
    );
    return session.storage.getPublicUrl(storageId: 'public', path: path);
  }

  Future<void> deleteAvatar(Session session) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (myUser == null) return;

    await session.storage.deleteFile(
      storageId: 'public',
      path: 'avatars/${myUser.id}.png',
    );
  }

  Future<void> deleteUserAvatar(Session session, int userId) async {
    await session.storage.deleteFile(
      storageId: 'public',
      path: 'avatars/$userId.png',
    );
  }

  String getAvatarUrl(Session session, int userId) {
    return session.storage.getPublicUrl(
      storageId: 'public',
      path: 'avatars/$userId.png',
    );
  }
}
```

- [ ] **Step 3: Regenerate and verify**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate && dart analyze
```

- [ ] **Step 4: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/
git commit -m "feat: add FCM push helper and Storage endpoint"
```

---

### Task 9: Write Messaging endpoint (streaming + presence)

**Files:**
- Create: `../kvitter_server/lib/src/endpoints/messaging_endpoint.dart`

This is the most complex server task. The messaging endpoint handles WebSocket streaming for:
1. Chat messages (per room)
2. Private chat updates (per user)
3. Online users / presence

- [ ] **Step 1: Create messaging_endpoint.dart**

Create `../kvitter_server/lib/src/endpoints/messaging_endpoint.dart`:

```dart
import 'dart:async';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class MessagingEndpoint extends Endpoint {
  static final Map<String, Set<StreamingSession>> _chatSubscribers = {};
  static final Map<int, StreamingSession> _onlineUsers = {};

  @override
  Future<void> streamOpened(StreamingSession session) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var user = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (user == null) return;

    user.presence = true;
    user.lastActive = DateTime.now();
    await ChatUser.db.updateRow(session, user);

    _onlineUsers[user.id!] = session;
  }

  @override
  Future<void> streamClosed(StreamingSession session) async {
    final authUserId = await session.auth.authenticatedUserId;
    if (authUserId == null) return;

    var user = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.userInfoId.equals(authUserId),
    );
    if (user != null) {
      user.presence = false;
      user.lastActive = DateTime.now();
      await ChatUser.db.updateRow(session, user);
      _onlineUsers.remove(user.id);
    }

    for (var subscribers in _chatSubscribers.values) {
      subscribers.remove(session);
    }
  }

  @override
  Future<void> handleStreamMessage(
      StreamingSession session, SerializableModel message) async {
    // Handle typed messages from clients
    // The client sends serializable messages to subscribe to channels
    // and the server broadcasts updates back
  }

  // Called from ChatEndpoint.postMessage via server-internal messaging
  static Future<void> broadcastMessage(
      Session session, int chatId, ChatMessage message) async {
    var channelName = 'chat_$chatId';
    var subscribers = _chatSubscribers[channelName];
    if (subscribers == null) return;

    for (var sub in subscribers) {
      sendStreamMessage(sub, message);
    }
  }

  static Future<void> broadcastPrivateChatUpdate(
      Session session, PrivateChat chat) async {
    for (var userIdStr in chat.users) {
      var userId = int.tryParse(userIdStr);
      if (userId != null && _onlineUsers.containsKey(userId)) {
        sendStreamMessage(_onlineUsers[userId]!, chat);
      }
    }
  }

  Future<List<ChatUser>> getOnlineUsers(Session session) async {
    var onlineUserIds = _onlineUsers.keys.toList();
    if (onlineUserIds.isEmpty) return [];
    return await ChatUser.db.find(
      session,
      where: (t) => t.id.inSet(onlineUserIds.toSet()),
    );
  }
}
```

Note: This is a starting implementation. The exact streaming API may need adjustment based on the Serverpod version. The implementer should consult Serverpod's streaming documentation for the precise patterns. The key concept is correct: WebSocket sessions track connected users, and the server pushes updates to subscribers.

- [ ] **Step 2: Regenerate and verify**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
serverpod generate && dart analyze
```

- [ ] **Step 3: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/ kvitter_client/
git commit -m "feat: add Messaging endpoint with WebSocket streaming and presence"
```

---

### Task 10: Update Flutter pubspec.yaml and create config

**Files:**
- Modify: `chat/pubspec.yaml`
- Create: `chat/lib/serverpod_config.dart`
- Delete: `chat/lib/supabase_config.dart`

- [ ] **Step 1: Update pubspec.yaml**

In `chat/pubspec.yaml`, remove `supabase_flutter` and add Serverpod packages.

Remove from dependencies:
```yaml
  supabase_flutter: ^2.8.0
```

Add to dependencies:
```yaml
  serverpod_flutter: ^2.0.0
  serverpod_auth_shared_flutter: ^2.0.0
  serverpod_auth_google_flutter: ^2.0.0
  serverpod_auth_apple_flutter: ^2.0.0
  kvitter_client:
    path: ../kvitter_client
```

- [ ] **Step 2: Run pub get**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
flutter pub get
```

- [ ] **Step 3: Create serverpod_config.dart**

Create `chat/lib/serverpod_config.dart`:

```dart
class ServerpodConfig {
  static const String host = 'YOUR_MAC_MINI_DOMAIN';
  static const int port = 8080;
  static const bool isSecure = true;
}
```

- [ ] **Step 4: Delete supabase_config.dart**

```bash
rm /Users/lbofhn/Documents/Kvitter/chat/lib/supabase_config.dart
```

- [ ] **Step 5: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add pubspec.yaml pubspec.lock lib/serverpod_config.dart
git rm lib/supabase_config.dart
git commit -m "feat: swap supabase_flutter for Serverpod packages in pubspec"
```

---

### Task 11: Create serverpod_auth_repository.dart and update auth_util.dart

**Files:**
- Create: `chat/lib/repository/serverpod_auth_repository.dart`
- Modify: `chat/lib/utils/auth_util.dart`
- Delete: `chat/lib/repository/supabase_auth_repository.dart`

- [ ] **Step 1: Create serverpod_auth_repository.dart**

Create `chat/lib/repository/serverpod_auth_repository.dart`:

```dart
import 'dart:async';

import 'package:kvitter_client/kvitter_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
import 'package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart';
import 'package:serverpod_auth_apple_flutter/serverpod_auth_apple_flutter.dart';
import '../utils/log.dart';

class ServerpodAuthRepository {
  final Client _client;
  final SessionManager _sessionManager;
  final _authStateController = StreamController<bool>.broadcast();

  ServerpodAuthRepository(this._client, this._sessionManager) {
    _sessionManager.addListener(() {
      _authStateController.add(_sessionManager.isSignedIn);
    });
  }

  Future<UserInfo?> signInWithGoogle() async {
    try {
      var result = await signInWithGoogleFlutter(
        caller: _client.modules.auth,
        serverUrl: _client.host,
      );
      return result;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<UserInfo?> signInWithApple() async {
    try {
      var result = await signInWithAppleFlutter(
        caller: _client.modules.auth,
      );
      return result;
    } catch (e, s) {
      Log.e(e, stackTrace: s);
      return null;
    }
  }

  Future<void> signOut() async {
    await _sessionManager.signOut();
  }

  bool get isSignedIn => _sessionManager.isSignedIn;

  UserInfo? get currentUser => _sessionManager.signedInUser;

  Stream<bool> get onAuthStateChange => _authStateController.stream;

  void dispose() {
    _authStateController.close();
  }
}
```

- [ ] **Step 2: Update auth_util.dart**

Replace the contents of `chat/lib/utils/auth_util.dart`:

```dart
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';

late SessionManager sessionManager;

String getUserId() => sessionManager.signedInUser!.id.toString();

int getAuthUserId() => sessionManager.signedInUser!.id!;
```

The `sessionManager` global is set during app initialization in `main.dart` (Task 14).

- [ ] **Step 3: Delete supabase_auth_repository.dart**

```bash
rm /Users/lbofhn/Documents/Kvitter/chat/lib/repository/supabase_auth_repository.dart
```

- [ ] **Step 4: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add lib/repository/serverpod_auth_repository.dart lib/utils/auth_util.dart
git rm lib/repository/supabase_auth_repository.dart
git commit -m "feat: add ServerpodAuthRepository and update auth_util for Serverpod session"
```

---

### Task 12: Create serverpod_repository.dart

**Files:**
- Create: `chat/lib/repository/serverpod_repository.dart`
- Delete: `chat/lib/repository/supabase_repository.dart`
- Delete: `chat/lib/repository/supabase_presence_repository.dart`

This is the largest Flutter-side task. The new repository wraps all Serverpod endpoint calls and converts between Serverpod's generated model types and the Flutter-side model types.

- [ ] **Step 1: Create serverpod_repository.dart**

Create `chat/lib/repository/serverpod_repository.dart`:

```dart
import 'dart:async';

import 'package:chat/model/message.dart';
import 'package:chat/model/private_chat.dart' as app;
import 'package:chat/model/room_chat.dart' as app;
import 'package:chat/utils/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:kvitter_client/kvitter_client.dart';

import '../model/chat_user.dart' as app;
import '../model/user_location.dart';
import '../utils/auth_util.dart';
import '../utils/log.dart';
import '../utils/online_users_processor.dart';

class ServerpodRepository {
  final Client _client;
  final OnlineUserProcessor _processor;

  ServerpodRepository(this._client, this._processor);

  // =============================================
  // USER OPERATIONS
  // =============================================

  Future<app.ChatUser?> getUser({String? userId}) async {
    try {
      final uid = userId != null ? int.tryParse(userId) : null;
      final serverUser = await _client.user.getUser(userId: uid);
      if (serverUser == null) return null;
      return _toAppUser(serverUser);
    } catch (e) {
      Log.e("Failed to fetch user: $e");
      return null;
    }
  }

  Future<void> setInitialUserData(String email, String unusedId) async {
    try {
      await _client.user.ensureUserExists(email);
    } catch (e) {
      Log.e("Failed to add user: $e");
    }
  }

  Future<void> updateUserGender(Gender gender) async {
    try {
      await _client.user.updateGender(gender.value);
    } catch (e) {
      Log.e("Failed to update user gender: $e");
    }
  }

  Future<void> updateUserBirthday(DateTime birthDate) async {
    try {
      await _client.user.updateBirthday(birthDate);
    } catch (e) {
      Log.e("Failed to update user birthdate: $e");
    }
  }

  Future<void> updateUserShowAge(bool showAge) async {
    try {
      await _client.user.updateShowAge(showAge);
    } catch (e) {
      Log.e("Failed to update user show age: $e");
    }
  }

  Future<void> updateUserDisplayName(String fullName, List<String> searchArray) async {
    try {
      await _client.user.updateDisplayName(fullName, searchArray);
    } catch (e) {
      Log.e("Failed to update user displayName: $e");
    }
  }

  Future<void> updateUserProfileImage({
    required String profileImageUrl,
    required app.ChatUser user,
    required bool hasNudity,
  }) async {
    try {
      await _client.user.updateProfileImage(profileImageUrl, hasNudity);
    } catch (e) {
      Log.e("Failed to update user image: $e");
    }
  }

  Future<bool> getIsNameAvailable(String displayName) async {
    try {
      return await _client.user.isNameAvailable(displayName);
    } catch (e) {
      Log.e("Failed to check name: $e");
      return false;
    }
  }

  Future<void> updateUserOnLogout() async {
    await _client.user.logout();
  }

  void updateUserLocation(UserLocation userLocation) {
    _client.user.updateLocation(
      userLocation.city,
      userLocation.countryCode,
      userLocation.countryName,
      userLocation.state,
    );
  }

  void setUserAsActive() {
    _client.user.setActive();
  }

  void updateCurrentUsersCurrentChatRoom({required String chatId}) {
    final id = int.tryParse(chatId) ?? 0;
    _client.user.setCurrentChatRoom(id);
  }

  void saveFcmTokenOnUser(String fcmToken) {
    _client.user.saveFcmToken(fcmToken);
  }

  void updateImageNotReviewedStatus() {
    _client.user.updateImageNotReviewedStatus();
  }

  Future<void> deleteUserPhoto() async {
    await _client.user.deletePhoto();
  }

  Future<void> deleteUserAndFiles() async {
    try {
      await _client.user.deleteAccount();
    } catch (e) {
      Log.e("Error deleting user: $e");
    }
  }

  Future<void> setUserAsPremium(bool isPremiumUser) async {
    await _client.user.setPremium(isPremiumUser);
  }

  // =============================================
  // BLOCK / REPORT OPERATIONS
  // =============================================

  Future<void> blockUser(String id) async {
    await _client.moderation.blockUser(int.parse(id));
  }

  Future<void> unblockUser(String id) async {
    await _client.moderation.unblockUser(int.parse(id));
  }

  void reportMessage(Message message) async {
    await _client.moderation.reportMessage(
      int.parse(message.id),
      message.text,
      message.created,
      int.parse(message.createdById),
      message.createdByGender,
      message.createdByCountryCode,
      message.createdByImageUrl,
      message.createdByName,
    );
  }

  Future<void> postInappropriateImageReport(String reportedUserId) async {
    await _client.moderation.reportInappropriateImage(int.parse(reportedUserId));
  }

  Future<void> postBotReport(String reportedUserId) async {
    await _client.moderation.reportBot(int.parse(reportedUserId));
  }

  Future<void> postHatefulLanguageReport(String reportedUserId) async {
    await _client.moderation.reportHatefulLanguage(int.parse(reportedUserId));
  }

  // =============================================
  // ADMIN / MODERATION
  // =============================================

  Future<void> approveImage(String id) async {
    await _client.moderation.approveImage(int.parse(id));
  }

  Future<void> rejectImage(String id) async {
    await _client.moderation.rejectImage(int.parse(id));
  }

  // =============================================
  // CREDITS
  // =============================================

  Future<void> reduceUserCredits(String id, int i) async {
    await _client.chat.reduceCredits(int.parse(id), i);
  }

  Future<void> increaseUserCredits(String id, int i) async {
    await _client.chat.increaseCredits(int.parse(id), i);
  }

  // =============================================
  // FEEDBACK
  // =============================================

  void postFeedback(String feedback, app.ChatUser user) {
    _client.chat.postFeedback(
      feedback,
      user.displayName,
      user.countryCode,
      user.country,
    );
  }

  // =============================================
  // CHAT OPERATIONS
  // =============================================

  Future<app.RoomChat?> getChat(String chatId, bool isPrivateChat) async {
    try {
      if (isPrivateChat) {
        return null; // Private chats handled separately
      }
      final serverChat = await _client.chat.getChat(int.parse(chatId));
      if (serverChat == null) return null;
      return _toAppRoomChat(serverChat);
    } catch (e) {
      Log.e("Failed to get chat: $e");
      return null;
    }
  }

  // =============================================
  // MESSAGE OPERATIONS
  // =============================================

  Future<List<Message>> getInitialMessages(String chatId, bool isPrivateChat) async {
    final messages = await _client.chat.getInitialMessages(
      int.parse(chatId), isPrivateChat);
    return messages.map(_toAppMessage).toList();
  }

  Future<List<Message>> getMoreMessages(
      String chatId, bool isPrivateChat, DateTime before) async {
    final messages = await _client.chat.getMoreMessages(
      int.parse(chatId), isPrivateChat, before);
    return messages.map(_toAppMessage).toList();
  }

  Future<void> postMessage({
    required String chatId,
    required app.ChatUser user,
    required String message,
    required ChatType chatType,
    required bool isPrivateChat,
    bool isGiphy = false,
    String? sendPushToUserId,
    Message? replyMessage,
  }) async {
    var serverMessage = ChatMessage(
      chatId: int.parse(chatId),
      isPrivate: isPrivateChat,
      text: message,
      chatType: chatType.value.toInt(),
      createdById: int.parse(user.id),
      createdByName: user.displayName,
      createdByGender: user.gender,
      createdByCountryCode: user.countryCode,
      createdByImageUrl: user.pictureData,
      approvedImage: user.approvedImage,
      created: DateTime.now(),
      birthDate: user.birthDate,
      showAge: user.showAge,
      imageReports: user.imageReports,
      replyId: replyMessage != null ? int.tryParse(replyMessage.id) : null,
      replyText: replyMessage?.text ?? '',
      replyChatType: replyMessage?.chatType.value.toInt() ?? 0,
      replyCreatedById: replyMessage != null ? int.tryParse(replyMessage.createdById) : null,
      replyCreatedByName: replyMessage?.createdByName ?? '',
      replyCreatedByGender: replyMessage?.createdByGender ?? 0,
      replyCreatedByCountryCode: replyMessage?.createdByCountryCode ?? '',
      replyCreatedByImageUrl: replyMessage?.createdByImageUrl ?? '',
      replyApprovedImage: replyMessage?.approvedImage ?? 3,
      replyCreated: replyMessage?.created,
      replyBirthDate: replyMessage?.birthDate,
      replyShowAge: replyMessage?.showAge ?? true,
      replyImageReports: replyMessage?.imageReports ?? [],
    );

    await _client.chat.postMessage(serverMessage);
  }

  // =============================================
  // PRIVATE CHAT OPERATIONS
  // =============================================

  Future<app.PrivateChat?> createPrivateChat({
    required app.ChatUser myUser,
    required app.ChatUser otherUser,
    required String initialMessage,
  }) async {
    try {
      final serverChat = await _client.privateChat.createPrivateChat(
        int.parse(otherUser.id),
        initialMessage,
        myUser.displayName,
        myUser.gender,
        myUser.pictureData,
        otherUser.displayName,
        otherUser.gender,
        otherUser.pictureData,
      );
      if (serverChat == null) return null;
      return _toAppPrivateChat(serverChat);
    } catch (e) {
      Log.e(e);
      return null;
    }
  }

  Future<bool> isPrivateChatAvailable(String userId) async {
    try {
      return await _client.privateChat.isPrivateChatAvailable(int.parse(userId));
    } catch (e) {
      Log.e("Failed to get chat: $e");
      return false;
    }
  }

  Future<void> leavePrivateChat(app.PrivateChat selectedChat) async {
    try {
      await _client.privateChat.leavePrivateChat(int.parse(selectedChat.id));
    } catch (e) {
      Log.e("Failed to leave private chat: $e");
    }
  }

  Future<app.PrivateChat?> getPrivateChat(String userId) async {
    try {
      final serverChat = await _client.privateChat.getPrivateChatWithUser(int.parse(userId));
      if (serverChat == null) return null;
      return _toAppPrivateChat(serverChat);
    } catch (e) {
      Log.e("Failed to fetch private chat: $e");
      return null;
    }
  }

  Future<void> setLastMessageRead({required String chatId}) async {
    try {
      await _client.privateChat.setLastMessageRead(int.parse(chatId));
    } catch (e) {
      Log.e(e);
    }
  }

  Future<void> leaveAllPrivateChats() async {
    await _client.privateChat.leaveAllPrivateChats();
  }

  // =============================================
  // STREAM OPERATIONS (REALTIME)
  // =============================================

  Stream<List<Message>> streamMessages(String chatId, bool isPrivateChat, int limit) {
    // Poll-based stream until Serverpod streaming is wired up
    final controller = StreamController<List<Message>>.broadcast();
    Timer? timer;

    void fetch() async {
      try {
        final messages = await _client.chat.getInitialMessages(
          int.parse(chatId), isPrivateChat);
        if (!controller.isClosed) {
          controller.add(messages.map(_toAppMessage).toList());
        }
      } catch (e) {
        Log.e("Failed to stream messages: $e");
      }
    }

    fetch();
    timer = Timer.periodic(const Duration(seconds: 2), (_) => fetch());

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Stream<app.ChatUser?> streamUser() {
    final controller = StreamController<app.ChatUser?>.broadcast();
    Timer? timer;

    void fetch() async {
      try {
        final serverUser = await _client.user.getUser();
        if (!controller.isClosed) {
          controller.add(serverUser != null ? _toAppUser(serverUser) : null);
        }
      } catch (e) {
        Log.e("Failed to stream user: $e");
      }
    }

    fetch();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => fetch());

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Stream<app.ChatUser?> streamUserById(String userId) {
    final controller = StreamController<app.ChatUser?>.broadcast();
    Timer? timer;

    void fetch() async {
      try {
        final serverUser = await _client.user.getUser(userId: int.parse(userId));
        if (!controller.isClosed) {
          controller.add(serverUser != null ? _toAppUser(serverUser) : null);
        }
      } catch (e) {
        Log.e("Failed to stream user: $e");
      }
    }

    fetch();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => fetch());

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Stream<List<app.ChatUser>> streamUnapprovedImages() {
    final controller = StreamController<List<app.ChatUser>>.broadcast();
    Timer? timer;

    void fetch() async {
      try {
        final users = await _client.moderation.getUnapprovedImages();
        if (!controller.isClosed) {
          controller.add(users.map(_toAppUser).toList());
        }
      } catch (e) {
        Log.e("Failed to stream unapproved images: $e");
      }
    }

    fetch();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  Stream<List<app.RoomChat>> streamOpenChats(app.ChatUser user) {
    final controller = StreamController<List<app.RoomChat>>.broadcast();
    Timer? timer;

    void fetch() async {
      try {
        final chats = await _client.chat.getOpenChats(
          user.countryCode, kDebugMode);
        if (!controller.isClosed) {
          controller.add(chats.map(_toAppRoomChat).toList());
        }
      } catch (e) {
        Log.e("Failed to stream open chats: $e");
      }
    }

    fetch();
    timer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());

    controller.onCancel = () {
      timer?.cancel();
    };

    return controller.stream;
  }

  final StreamController<List<app.PrivateChat>> _privateChatsStreamController =
      StreamController<List<app.PrivateChat>>.broadcast();
  Timer? _privateChatsTimer;

  Stream<List<app.PrivateChat>> getPrivateChatsStream() =>
      _privateChatsStreamController.stream;

  void startPrivateChatsStream(String userId) {
    _privateChatsTimer?.cancel();

    void fetch() async {
      try {
        final chats = await _client.privateChat.getPrivateChats();
        if (!_privateChatsStreamController.isClosed) {
          _privateChatsStreamController.add(
              chats.map(_toAppPrivateChat).toList());
        }
      } catch (e) {
        Log.e("Failed to get private chats: $e");
      }
    }

    fetch();
    _privateChatsTimer = Timer.periodic(const Duration(seconds: 2), (_) => fetch());
  }

  void closePrivateChatStream() {
    _privateChatsTimer?.cancel();
    _privateChatsStreamController.close();
  }

  final StreamController<List<app.ChatUser>> _onlineUsersStreamController =
      StreamController<List<app.ChatUser>>.broadcast();
  Timer? _onlineUsersTimer;

  Stream<List<app.ChatUser>> get onlineUsersStream =>
      _onlineUsersStreamController.stream;

  Future<void> startOnlineUsersStream(String countryCode) async {
    _onlineUsersTimer?.cancel();
    _onlineUsersStreamController.sink.add([]);
    await _processor.start();

    void fetch() async {
      try {
        final users = await _client.messaging.getOnlineUsers();
        final appUsers = users.map(_toAppUser).toList();
        final processedUsers = await _processor.process(
          appUsers.map((u) => {'id': u.id, 'data': _userToMap(u)}).toList(),
          getUserId(),
          countryCode,
          onlineDuration,
        );
        if (!_onlineUsersStreamController.isClosed) {
          _onlineUsersStreamController.add(processedUsers);
        }
      } catch (e) {
        Log.e("Failed to get online users: $e");
      }
    }

    fetch();
    _onlineUsersTimer = Timer.periodic(const Duration(seconds: 5), (_) => fetch());
  }

  void closeOnlineUsersStream() {
    _onlineUsersTimer?.cancel();
    _onlineUsersStreamController.close();
    _processor.stop();
  }

  void closeAllStreams() {
    _privateChatsTimer?.cancel();
    _onlineUsersTimer?.cancel();
    _privateChatsStreamController.close();
    _onlineUsersStreamController.close();
  }

  // =============================================
  // MODEL CONVERTERS
  // =============================================

  app.ChatUser _toAppUser(ChatUser u) {
    return app.ChatUser(
      id: u.id.toString(),
      displayName: u.displayName,
      gender: u.gender,
      pictureData: u.pictureData,
      approvedImage: u.approvedImage,
      onboardingCompleted: u.onboardingCompleted,
      isAdmin: u.isAdmin,
      created: u.lastActive,
      lastActive: u.lastActive.millisecondsSinceEpoch,
      city: u.city,
      countryCode: u.countryCode,
      country: u.country,
      regionName: u.regionName,
      presence: u.presence,
      showAge: u.showAge,
      currentRoomChatId: u.currentRoomChatId?.toString() ?? '',
      fcmToken: u.fcmToken,
      birthDate: u.birthDate,
      blockedBy: u.blockedBy,
      imageReports: u.imageReports,
      botReports: u.botReports,
      languageReports: u.languageReports,
      kvitterCredits: u.kvitterCredits,
      isPremiumUser: u.isPremiumUser,
    );
  }

  app.RoomChat _toAppRoomChat(RoomChat c) {
    return app.RoomChat(
      id: c.id.toString(),
      chatName: c.chatName,
      chatColor: c.chatColor,
      imageUrl: c.imageUrl,
      countryCode: c.countryCode,
      enabled: c.enabled,
      infoKey: c.infoKey,
      imageOverflow: c.imageOverflow,
      imageTranslationX: c.imageTranslationX,
      lastMessage: c.lastMessage,
      lastMessageIsGiphy: c.lastMessageIsGiphy,
      lastMessageByName: c.lastMessageByName,
      lastMessageTimestamp: c.lastMessageTimestamp,
      lastMessageUserId: c.lastMessageUserId?.toString() ?? '',
      lastMessageReadByUser: false,
    );
  }

  app.PrivateChat _toAppPrivateChat(PrivateChat c) {
    return app.PrivateChat(
      id: c.id.toString(),
      users: c.users,
      created: c.created,
      initiatedBy: c.initiatedBy.toString(),
      initiatedByUserName: c.initiatedByUserName,
      initiatedByUserGender: c.initiatedByUserGender,
      initiatedByPictureData: c.initiatedByPictureData,
      otherUserId: c.otherUserId.toString(),
      otherUserName: c.otherUserName,
      otherUserGender: c.otherUserGender,
      otherUserPictureData: c.otherUserPictureData,
      lastMessage: c.lastMessage,
      lastMessageIsGiphy: c.lastMessageIsGiphy,
      lastMessageByName: c.lastMessageByName,
      lastMessageTimestamp: c.lastMessageTimestamp,
      lastMessageUserId: c.lastMessageUserId?.toString() ?? '',
      lastMessageReadBy: c.lastMessageReadBy,
    );
  }

  Message _toAppMessage(ChatMessage m) {
    return Message(
      id: m.id.toString(),
      text: m.text,
      createdById: m.createdById.toString(),
      createdByName: m.createdByName,
      createdByGender: m.createdByGender,
      createdByCountryCode: m.createdByCountryCode,
      createdByImageUrl: m.createdByImageUrl,
      chatType: ChatType.values[m.chatType],
      approvedImage: m.approvedImage,
      created: m.created,
      birthDate: m.birthDate,
      showAge: m.showAge,
      marked: false,
      imageReports: m.imageReports,
      replyId: m.replyId?.toString() ?? '',
      replyText: m.replyText,
      replyCreatedById: m.replyCreatedById?.toString() ?? '',
      replyCreatedByName: m.replyCreatedByName,
      replyCreatedByGender: m.replyCreatedByGender,
      replyCreatedByCountryCode: m.replyCreatedByCountryCode,
      replyCreatedByImageUrl: m.replyCreatedByImageUrl,
      replyChatType: ChatType.values[m.replyChatType],
      replyApprovedImage: m.replyApprovedImage,
      replyCreated: m.replyCreated,
      replyBirthDate: m.replyBirthDate,
      replyShowAge: m.replyShowAge,
      replyImageReports: m.replyImageReports,
    );
  }

  Map<String, dynamic> _userToMap(app.ChatUser u) {
    return {
      'display_name': u.displayName,
      'gender': u.gender,
      'picture_data': u.pictureData,
      'approved_image': u.approvedImage,
      'country_code': u.countryCode,
      'country': u.country,
      'city': u.city,
      'region_name': u.regionName,
      'presence': u.presence,
      'show_age': u.showAge,
      'birth_date': u.birthDate?.toIso8601String(),
      'last_active': u.created.toIso8601String(),
      'blocked_by': u.blockedBy,
      'image_reports': u.imageReports,
      'bot_reports': u.botReports,
      'language_reports': u.languageReports,
      'kvitter_credits': u.kvitterCredits,
      'is_premium_user': u.isPremiumUser,
      'onboarding_completed': u.onboardingCompleted,
      'is_admin': u.isAdmin,
      'fcm_token': u.fcmToken,
      'current_room_chat_id': u.currentRoomChatId,
    };
  }
}
```

Note: The streaming methods use a polling approach (Timer.periodic) as a simple starting implementation. Once the Serverpod WebSocket streaming is fully wired up (Task 9's server-side messaging endpoint), these can be upgraded to true WebSocket streams. The polling approach works correctly and ensures the app functions immediately.

- [ ] **Step 2: Delete Supabase repository files**

```bash
rm /Users/lbofhn/Documents/Kvitter/chat/lib/repository/supabase_repository.dart
rm /Users/lbofhn/Documents/Kvitter/chat/lib/repository/supabase_presence_repository.dart
```

- [ ] **Step 3: Verify the file compiles**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
dart analyze lib/repository/serverpod_repository.dart
```

Note: This will likely show errors for missing imports from `kvitter_client` since the generated code might use different names. The implementer should check the generated `kvitter_client` protocol and adjust the import names and method calls accordingly.

- [ ] **Step 4: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add lib/repository/serverpod_repository.dart
git rm lib/repository/supabase_repository.dart lib/repository/supabase_presence_repository.dart
git commit -m "feat: add ServerpodRepository replacing Supabase data layer"
```

---

### Task 13: Create serverpod_storage_repository.dart

**Files:**
- Create: `chat/lib/repository/serverpod_storage_repository.dart`
- Delete: `chat/lib/repository/supabase_storage_repository.dart`

- [ ] **Step 1: Create serverpod_storage_repository.dart**

Create `chat/lib/repository/serverpod_storage_repository.dart`:

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:kvitter_client/kvitter_client.dart';
import 'package:universal_io/io.dart';

import '../utils/auth_util.dart';
import '../utils/log.dart';

class ServerpodStorageRepository {
  final Client _client;

  ServerpodStorageRepository(this._client);

  Future<String?> uploadProfileImage(String filePath, String base64Image) async {
    try {
      ByteData imageData;
      if (kIsWeb) {
        imageData = ByteData.sublistView(base64.decode(base64Image));
      } else {
        final bytes = await File(filePath).readAsBytes();
        imageData = ByteData.sublistView(bytes);
      }
      return await _client.storage.uploadAvatar(imageData);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<String?> uploadMessageImage(String filePath, String base64Image) async {
    try {
      ByteData imageData;
      if (kIsWeb) {
        imageData = ByteData.sublistView(base64.decode(base64Image));
      } else {
        final bytes = await File(filePath).readAsBytes();
        imageData = ByteData.sublistView(bytes);
      }
      return await _client.storage.uploadChatImage(imageData);
    } catch (e) {
      Log.e(e.toString());
      return null;
    }
  }

  Future<void> deleteImage(String publicUrl) async {
    try {
      await _client.storage.deleteAvatar();
    } catch (e) {
      Log.e(e.toString());
    }
  }

  Future<void> deleteUserAvatar(String userId) async {
    try {
      await _client.storage.deleteUserAvatar(int.parse(userId));
    } catch (e) {
      Log.e('Error deleting avatar: $e');
    }
  }

  String getUserImageUrl(String userId) {
    // This returns the public URL pattern for the user's avatar
    // The actual URL depends on the server's storage config
    return '${_client.host}/storage/avatars/$userId.png';
  }
}
```

- [ ] **Step 2: Delete supabase_storage_repository.dart**

```bash
rm /Users/lbofhn/Documents/Kvitter/chat/lib/repository/supabase_storage_repository.dart
```

- [ ] **Step 3: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add lib/repository/serverpod_storage_repository.dart
git rm lib/repository/supabase_storage_repository.dart
git commit -m "feat: add ServerpodStorageRepository for file uploads"
```

---

### Task 14: Update main.dart

**Files:**
- Modify: `chat/lib/main.dart`

- [ ] **Step 1: Rewrite main.dart initialization and providers**

Replace the Supabase imports and initialization with Serverpod. Key changes:

1. Replace imports: `supabase_*` → `serverpod_*`
2. Remove `Supabase.initialize()` from `main()`
3. Create Serverpod `Client` and `SessionManager` in `main()`
4. Set the global `sessionManager` from `auth_util.dart`
5. Replace all Provider types

The updated `main()` function:

```dart
import 'package:chat/repository/serverpod_repository.dart';
import 'package:chat/repository/serverpod_auth_repository.dart';
import 'package:chat/repository/serverpod_storage_repository.dart';
import 'package:chat/serverpod_config.dart';
import 'package:kvitter_client/kvitter_client.dart';
import 'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart';
// ... keep all other existing imports, remove supabase imports
```

In `main()`, replace `Supabase.initialize(...)` with:

```dart
final client = Client(
  '${ServerpodConfig.isSecure ? 'https' : 'http'}://${ServerpodConfig.host}:${ServerpodConfig.port}/',
  authenticationKeyManager: FlutterAuthenticationKeyManager(),
)..connectivityMonitor = FlutterConnectivityMonitor();

sessionManager = SessionManager(caller: client.modules.auth);
await sessionManager.initialize();
```

In the `KvitterApp` class, change the constructor to accept `Client` and `SessionManager`, then use them to create the repositories:

```dart
final ServerpodRepository serverpodRepository =
    ServerpodRepository(client, onlineUsersProcessor);
final ServerpodAuthRepository serverpodAuthRepository =
    ServerpodAuthRepository(client, sessionManager);
final ServerpodStorageRepository serverpodStorageRepository =
    ServerpodStorageRepository(client);
final FcmRepository fcmRepository =
    FcmRepository(serverpodRepository);
final SubscriptionRepository subscriptionRepository =
    SubscriptionRepository(serverpodRepository);
```

Replace the MultiProvider providers:

```dart
Provider<ServerpodRepository>.value(value: serverpodRepository),
Provider<ServerpodAuthRepository>.value(value: serverpodAuthRepository),
Provider<ServerpodStorageRepository>.value(value: serverpodStorageRepository),
// Remove Provider<SupabasePresenceRepository> entirely
```

Remove the `import 'package:supabase_flutter/supabase_flutter.dart';` line.
Remove the `import 'package:chat/supabase_config.dart';` line.

- [ ] **Step 2: Verify the app compiles**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
flutter analyze
```

Note: This will show errors in BLoC/screen files that still reference `SupabaseRepository`. That's expected — they're fixed in Tasks 15-16.

- [ ] **Step 3: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add lib/main.dart
git commit -m "feat: initialize Serverpod client and swap providers in main.dart"
```

---

### Task 15: Update login screen and remove anonymous auth

**Files:**
- Modify: `chat/lib/screens/login/login_screen.dart`
- Modify: `chat/lib/screens/login/bloc/login_bloc.dart`
- Modify: `chat/lib/screens/login/bloc/login_event.dart`

- [ ] **Step 1: Update login_event.dart**

Remove `LoginGuestClickedEvent` and `LoginFacebookClickedEvent` (also unused) and `FacebookLoggedInEvent` from `chat/lib/screens/login/bloc/login_event.dart`:

```dart
import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginGoogleClickedEvent extends LoginEvent {}

class LoginAppleClickedEvent extends LoginEvent {}

class LoginFailedEvent extends LoginEvent {}
```

- [ ] **Step 2: Update login_bloc.dart**

Rewrite `chat/lib/screens/login/bloc/login_bloc.dart` to use `ServerpodAuthRepository` and `ServerpodRepository`, removing the guest handler:

```dart
import 'package:chat/repository/serverpod_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../repository/serverpod_repository.dart';
import '../../../utils/log.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ServerpodAuthRepository _authRepository;
  final ServerpodRepository _serverpodRepository;

  LoginBloc(this._authRepository, this._serverpodRepository)
      : super(LoginBaseState()) {
    on<LoginGoogleClickedEvent>(_onGoogleClicked);
    on<LoginAppleClickedEvent>(_onAppleClicked);
  }

  Future<void> _onGoogleClicked(
      LoginGoogleClickedEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState());
      final userInfo = await _authRepository.signInWithGoogle();
      if (userInfo == null) {
        emit(LoginErrorState());
      } else {
        await _serverpodRepository.setInitialUserData(
            userInfo.email ?? '', '');
        final chatUser = await _serverpodRepository.getUser();
        emit(await checkIfOnboardingIsDone(chatUser));
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      emit(LoginErrorState());
    }
  }

  Future<void> _onAppleClicked(
      LoginAppleClickedEvent event, Emitter<LoginState> emit) async {
    try {
      emit(LoginLoadingState());
      final userInfo = await _authRepository.signInWithApple();
      if (userInfo == null) {
        emit(LoginErrorState());
      } else {
        await _serverpodRepository.setInitialUserData(
            userInfo.email ?? '', '');
        final chatUser = await _serverpodRepository.getUser();
        emit(await checkIfOnboardingIsDone(chatUser));
      }
    } on Exception catch (exception, stacktrace) {
      Log.e(exception, stackTrace: stacktrace);
      emit(LoginErrorState());
    }
  }

  Future<LoginState> checkIfOnboardingIsDone(final ChatUser? chatUser) async {
    if (chatUser == null || chatUser.displayName.isEmpty) {
      return const LoginSuccessState(OnboardingNavigation.name);
    } else if (chatUser.pictureData.isEmpty) {
      return const LoginSuccessState(OnboardingNavigation.picture);
    } else if (chatUser.gender == -1) {
      return const LoginSuccessState(OnboardingNavigation.gender);
    } else {
      return const LoginSuccessState(OnboardingNavigation.done);
    }
  }
}
```

- [ ] **Step 3: Update login_screen.dart**

In `chat/lib/screens/login/login_screen.dart`:

1. Replace imports:
   - `supabase_auth_repository.dart` → `serverpod_auth_repository.dart`
   - `supabase_repository.dart` → `serverpod_repository.dart`

2. Update provider reads in `LoginScreen.build()`:
   ```dart
   LoginBloc(context.read<ServerpodAuthRepository>(), context.read<ServerpodRepository>()),
   ```

3. Remove the "Continue as Guest" button (the `ElevatedButton.icon` with `LoginGuestClickedEvent` at line 126-135).

- [ ] **Step 4: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add lib/screens/login/
git commit -m "feat: update login screen for Serverpod auth, remove anonymous sign-in"
```

---

### Task 16: Update all BLoC and screen imports

**Files:**
- Modify: 30+ BLoC/screen files (see list below)
- Modify: `chat/lib/repository/fcm_repository.dart`
- Modify: `chat/lib/repository/subscription_repository.dart`

This is a mechanical find-and-replace task across all files that reference Supabase repository types.

**Files to modify** (every file from the grep output in context):

Screens that use `SupabaseRepository`:
- `screens/splash/splash_screen.dart` — `context.read<SupabaseRepository>()` → `context.read<ServerpodRepository>()`
- `screens/splash/bloc/splash_bloc.dart` — type + import + replace `Supabase.instance.client.auth.currentUser != null` with `sessionManager.isSignedIn`
- `screens/message_holder/message_holder_screen.dart` — swap `SupabaseRepository`, `SupabasePresenceRepository`
- `screens/message_holder/bloc/message_holder_bloc.dart` — swap `SupabaseRepository`
- `screens/messages/messages_screen.dart` — swap `SupabaseRepository`, `SupabaseStorageRepository`
- `screens/messages/bloc/messages_bloc.dart` — swap `SupabaseRepository`, `SupabaseStorageRepository`
- `screens/chat/chat_screen.dart` — swap `SupabaseRepository`
- `screens/chat/bloc/chat_bloc.dart` — swap `SupabaseRepository`
- `screens/options/options_screen.dart` — swap `SupabaseRepository`
- `screens/options/bloc/options_bloc.dart` — swap `SupabaseRepository`
- `screens/onboarding_name/onboarding_name_screen.dart` — swap `SupabaseRepository`
- `screens/onboarding_name/bloc/onboarding_name_bloc.dart` — swap `SupabaseRepository`
- `screens/onboarding_gender/onboarding_gender_screen.dart` — swap `SupabaseRepository`
- `screens/onboarding_gender/bloc/onboarding_gender_bloc.dart` — swap `SupabaseRepository`
- `screens/onboarding_age/onboarding_age_screen.dart` — swap `SupabaseRepository`
- `screens/onboarding_age/bloc/onboarding_age_bloc.dart` — swap `SupabaseRepository`
- `screens/onboarding_photo/onboarding_photo_screen.dart` — swap `SupabaseRepository`, `SupabaseStorageRepository`
- `screens/onboarding_photo/bloc/onboarding_photo_bloc.dart` — swap `SupabaseRepository`, `SupabaseStorageRepository`
- `screens/feedback/feedback_screen.dart` — swap `SupabaseRepository`
- `screens/feedback/bloc/feedback_bloc.dart` — swap `SupabaseRepository`
- `screens/visit/visit_screen.dart` — swap `SupabaseRepository`
- `screens/visit/bloc/visit_bloc.dart` — swap `SupabaseRepository`
- `screens/profile/profile_screen.dart` — swap `SupabaseRepository`
- `screens/profile/bloc/profile_bloc.dart` — swap `SupabaseRepository`
- `screens/report/report_screen.dart` — swap `SupabaseRepository`
- `screens/report/bloc/report_bloc.dart` — swap `SupabaseRepository`
- `screens/review/review_screen.dart` — swap `SupabaseRepository`
- `screens/review/bloc/review_bloc.dart` — swap `SupabaseRepository`
- `screens/account/account_screen.dart` — swap `SupabaseRepository`, `SupabaseAuthRepository`
- `screens/account/bloc/account_bloc.dart` — swap `SupabaseRepository`, `SupabaseAuthRepository`
- `screens/premium/premium_screen.dart` — swap `SupabaseRepository`
- `screens/premium/bloc/premium_bloc.dart` — swap `SupabaseRepository`
- `screens/people/people_screen.dart` — swap `SupabaseRepository`
- `screens/people/bloc/people_bloc.dart` — swap `SupabaseRepository`
- `screens/credits/credits_screen.dart` — swap `SupabaseRepository`
- `screens/credits/bloc/credits_bloc.dart` — swap `SupabaseRepository`
- `screens/app_life_cycle/app_life_cycle_screen.dart` — swap `SupabaseRepository`
- `screens/app_life_cycle/bloc/app_life_cycle_bloc.dart` — swap `SupabaseRepository`

- [ ] **Step 1: Global find-and-replace across all screen files**

For each file listed above, apply these replacements:

| Find | Replace |
|---|---|
| `import 'package:chat/repository/supabase_repository.dart'` | `import 'package:chat/repository/serverpod_repository.dart'` |
| `import '../../../repository/supabase_repository.dart'` | `import '../../../repository/serverpod_repository.dart'` |
| `import 'package:chat/repository/supabase_auth_repository.dart'` | `import 'package:chat/repository/serverpod_auth_repository.dart'` |
| `import '../../../repository/supabase_auth_repository.dart'` | `import '../../../repository/serverpod_auth_repository.dart'` |
| `import 'package:chat/repository/supabase_storage_repository.dart'` | `import 'package:chat/repository/serverpod_storage_repository.dart'` |
| `import '../../../repository/supabase_storage_repository.dart'` | `import '../../../repository/serverpod_storage_repository.dart'` |
| `import 'package:chat/repository/supabase_presence_repository.dart'` | _(delete this line)_ |
| `SupabaseRepository` | `ServerpodRepository` |
| `SupabaseAuthRepository` | `ServerpodAuthRepository` |
| `SupabaseStorageRepository` | `ServerpodStorageRepository` |
| `SupabasePresenceRepository` | _(remove references)_ |
| `_supabaseRepository` | `_serverpodRepository` |
| `supabaseRepository` | `serverpodRepository` |

- [ ] **Step 2: Fix splash_bloc.dart specifically**

In `screens/splash/bloc/splash_bloc.dart`, replace:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

with:

```dart
import 'package:chat/utils/auth_util.dart';
```

And replace:

```dart
if (Supabase.instance.client.auth.currentUser != null) {
```

with:

```dart
if (sessionManager.isSignedIn) {
```

- [ ] **Step 3: Fix message_holder_screen.dart specifically**

Remove the line:
```dart
context.read<SupabasePresenceRepository>().updateUserPresence();
```

Presence is now handled automatically by the Serverpod streaming connection.

- [ ] **Step 4: Update fcm_repository.dart**

Replace `SupabaseRepository` with `ServerpodRepository`:

```dart
import 'package:chat/repository/serverpod_repository.dart';
// ...
class FcmRepository {
  final ServerpodRepository _serverpodRepository;
  // ...
  FcmRepository(this._serverpodRepository);
  // ...
  if (fcmToken != null) _serverpodRepository.saveFcmTokenOnUser(fcmToken);
  // ...
  _serverpodRepository.saveFcmTokenOnUser(fcmToken);
```

- [ ] **Step 5: Update subscription_repository.dart**

Replace `SupabaseRepository` with `ServerpodRepository`:

```dart
import 'serverpod_repository.dart';
// ...
class SubscriptionRepository {
  final ServerpodRepository _serverpodRepository;
  SubscriptionRepository(this._serverpodRepository);
  // ...
  final user = await _serverpodRepository.getUser();
```

- [ ] **Step 6: Run flutter analyze**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
flutter analyze
```

Expected: 0 errors, 0 warnings (or only warnings unrelated to this migration).

- [ ] **Step 7: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add lib/
git commit -m "refactor: update all BLoCs and screens for Serverpod repositories"
```

---

### Task 17: Delete Supabase infrastructure files and verify build

**Files:**
- Delete: `chat/supabase/schema.sql`
- Delete: `chat/functions/index.js`
- Delete: `chat/scripts/migrate_users.dart`

- [ ] **Step 1: Delete Supabase infrastructure files**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
rm -f supabase/schema.sql
rmdir supabase 2>/dev/null || true
rm -f functions/index.js
rm -f scripts/migrate_users.dart
rmdir scripts 2>/dev/null || true
```

- [ ] **Step 2: Run final flutter analyze**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
flutter analyze
```

Expected: 0 errors, 0 warnings.

- [ ] **Step 3: Run final server analyze**

```bash
cd /Users/lbofhn/Documents/Kvitter/kvitter_server
dart analyze
```

Expected: 0 errors.

- [ ] **Step 4: Verify no stale Supabase references remain**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
grep -rn "supabase" lib/ --include="*.dart" | grep -v "// " | head -20
```

Expected: No results (all Supabase references removed).

- [ ] **Step 5: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter/chat
git add -A
git commit -m "chore: remove Supabase infrastructure files (schema, functions, migration script)"
```

---

### Task 18: Server configuration and deployment readiness

**Files:**
- Modify: `../kvitter_server/config/development.yaml`
- Modify: `../kvitter_server/config/production.yaml`
- Modify: `../kvitter_server/config/passwords.yaml`

- [ ] **Step 1: Update development.yaml**

Ensure `../kvitter_server/config/development.yaml` has correct local settings:

```yaml
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

insightsServer:
  port: 8081
  publicHost: localhost
  publicPort: 8081
  publicScheme: http

webServer:
  port: 8082
  publicHost: localhost
  publicPort: 8082
  publicScheme: http

database:
  host: localhost
  port: 5432
  name: kvitter
  user: postgres

storage:
  public:
    type: local
    path: ./public
    publicHost: http://localhost:8082/storage
```

- [ ] **Step 2: Update production.yaml**

Update `../kvitter_server/config/production.yaml`:

```yaml
apiServer:
  port: 8080
  publicHost: YOUR_MAC_MINI_DOMAIN
  publicPort: 443
  publicScheme: https

insightsServer:
  port: 8081
  publicHost: YOUR_MAC_MINI_DOMAIN
  publicPort: 8081
  publicScheme: https

webServer:
  port: 8082
  publicHost: YOUR_MAC_MINI_DOMAIN
  publicPort: 8082
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

- [ ] **Step 3: Update passwords.yaml**

Update `../kvitter_server/config/passwords.yaml`:

```yaml
development:
  database: YOUR_DEV_DB_PASSWORD
  serviceSecret: YOUR_DEV_SERVICE_SECRET
  fcmServiceAccountKey: YOUR_FCM_SERVER_KEY

production:
  database: YOUR_PROD_DB_PASSWORD
  serviceSecret: YOUR_PROD_SERVICE_SECRET
  fcmServiceAccountKey: YOUR_FCM_SERVER_KEY
```

- [ ] **Step 4: Add passwords.yaml to .gitignore**

Ensure `passwords.yaml` is in `.gitignore` for the server project:

```bash
echo "config/passwords.yaml" >> /Users/lbofhn/Documents/Kvitter/kvitter_server/.gitignore
```

- [ ] **Step 5: Commit**

```bash
cd /Users/lbofhn/Documents/Kvitter
git add kvitter_server/config/ kvitter_server/.gitignore
git commit -m "feat: configure Serverpod server for development and production"
```

---

## Post-Migration Deployment Steps

After all tasks are complete:

1. **Install PostgreSQL** on Mac Mini
2. **Create the database**: `createdb kvitter`
3. **Run migrations**: `cd kvitter_server && dart bin/main.dart --apply-migrations`
4. **Start the server**: `dart bin/main.dart --mode production`
5. **Set up SSL** via Cloudflare Tunnel, nginx, or Caddy
6. **Update `serverpod_config.dart`** with real domain
7. **Configure Google OAuth** in Serverpod auth settings
8. **Configure Apple OAuth** in Serverpod auth settings
9. **Seed chat rooms** via SQL: `INSERT INTO room_chats (...) VALUES (...)`
10. **Deploy the Cloud Function** is no longer needed — FCM is sent from server
