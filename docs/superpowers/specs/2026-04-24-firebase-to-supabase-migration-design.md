# Firebase to Supabase Migration Design

## Overview

Migrate Kvitter's backend from Firebase/Firestore to self-hosted Supabase on a Mac Mini. Repository-swap approach: replace only the repository layer, keep all BLoCs/Cubits, screens, and models intact.

**Target scale:** 1,000–10,000 concurrent users.

## Decisions

- **Strategy**: Repository swap (Approach A) — new Supabase repository implementations matching existing interfaces
- **Data migration**: Users only, clean chat history
- **Auth**: Supabase Auth (Google, Apple, Anonymous)
- **Push notifications**: Keep Firebase Cloud Functions (HTTP-triggered) + FCM
- **Crash reporting**: Keep Firebase Crashlytics
- **Hosting**: Self-hosted Supabase via Docker on Mac Mini, internet-accessible

---

## 1. Database Schema

Firestore's 6 collections become PostgreSQL tables.

### `users`

| Column | Type | Notes |
|---|---|---|
| id | UUID (PK) | Supabase Auth user ID |
| firebase_uid | text, nullable | Maps migrated users |
| email | text | |
| display_name | text | |
| gender | text | |
| birth_date | timestamptz | |
| show_age | boolean | |
| picture_data | text | Avatar URL path |
| approved_image | integer | 0=pending, 1=approved, 2=rejected |
| city | text | |
| country_code | text | |
| country | text | |
| region_name | text | |
| presence | boolean | |
| last_active | timestamptz | |
| current_room_chat_id | UUID, nullable | |
| fcm_token | text, nullable | |
| blocked_by | text[] | Array of user IDs |
| image_reports | text[] | |
| bot_reports | text[] | |
| language_reports | text[] | |
| kvitter_credits | integer | |
| is_premium_user | boolean | |
| onboarding_completed | boolean | |
| is_admin | boolean | |
| search_array | text[] | For name search |
| created | timestamptz | |

### `chats`

| Column | Type | Notes |
|---|---|---|
| id | UUID (PK) | |
| chat_name | text | |
| chat_color | text | |
| image_url | text | |
| country_code | text | |
| enabled | boolean | |
| info_key | text | Localization key |
| image_overflow | boolean | |
| image_translation_x | double precision | |
| last_message | text | |
| last_message_is_giphy | boolean | |
| last_message_by_name | text | |
| last_message_timestamp | timestamptz | |
| last_message_user_id | UUID | |

### `private_chats`

| Column | Type | Notes |
|---|---|---|
| id | UUID (PK) | |
| users | text[] | 2-element array of user IDs |
| created | timestamptz | |
| initiated_by | UUID | |
| last_message | text | |
| last_message_is_giphy | boolean | |
| last_message_by_name | text | |
| last_message_timestamp | timestamptz | |
| last_message_user_id | UUID | |
| last_message_read_by | text[] | |
| send_push_to_user_id | UUID, nullable | |
| other_user_id | UUID | |
| other_user_name | text | |
| other_user_gender | text | |
| other_user_picture_data | text | |
| chat_name | text | |
| initiated_by_user_name | text | |
| initiated_by_user_gender | text | |
| initiated_by_picture_data | text | |

### `messages`

Unified table (no subcollections). Replaces both `chats/{id}/messages` and `privateChats/{id}/messages`.

| Column | Type | Notes |
|---|---|---|
| id | UUID (PK) | |
| chat_id | UUID (FK) | References chats or private_chats |
| is_private | boolean | Distinguishes chat type |
| text | text | |
| chat_type | text | message/joined/left/giphy/date/image |
| created_by_id | UUID | |
| created_by_name | text | |
| created_by_gender | text | |
| created_by_country_code | text | |
| created_by_image_url | text | |
| approved_image | integer | |
| created | timestamptz | |
| birth_date | timestamptz | |
| show_age | boolean | |
| image_reports | text[] | |
| reply_id | UUID, nullable | |
| reply_text | text | |
| reply_chat_type | text | |
| reply_created_by_id | UUID | |
| reply_created_by_name | text | |
| reply_created_by_gender | text | |
| reply_created_by_country_code | text | |
| reply_created_by_image_url | text | |
| reply_approved_image | integer | |
| reply_created | timestamptz | |
| reply_birth_date | timestamptz | |
| reply_show_age | boolean | |
| reply_image_reports | text[] | |

**Indexes:**
- `(chat_id, created DESC)` — message pagination
- `(created_by_id)` — user's messages lookup
- `(is_private, chat_id)` — filter by chat type

### `reports`

| Column | Type | Notes |
|---|---|---|
| id | UUID (PK) | |
| message_id | UUID | |
| message_text | text | |
| message_created | timestamptz | |
| message_created_by | UUID | |
| message_created_by_gender | text | |
| message_created_by_country_code | text | |
| message_created_by_image_url | text | |
| message_created_by_display_name | text | |
| reported_by | UUID | |
| reported_at | timestamptz | |

### `feedback`

| Column | Type | Notes |
|---|---|---|
| id | UUID (PK) | |
| feedback | text | |
| created_by_id | UUID | |
| created_by_name | text | |
| created_by_country_code | text | |
| created_by_country_name | text | |
| created | timestamptz | |

### Row Level Security (RLS)

- **users**: Read all rows (needed to display names/avatars in chat). Update own row only. Sensitive fields (email, fcm_token, blocked_by) exposed only to own user via a database view or selective column policy.
- **chats**: Read all enabled chats by authenticated users. Insert/update by admins only.
- **private_chats**: Read/write only if `auth.uid()::text = ANY(users)`.
- **messages**: Public chat messages readable by all authenticated users. Private chat messages readable only if user is a participant in the referenced private_chat. Insert by authenticated users.
- **reports**: Insert by authenticated users. Read by admins only.
- **feedback**: Insert by authenticated users. Read by admins only.

---

## 2. Realtime & Presence

### Message Streams

Supabase Realtime over WebSockets. One connection per client, multiplexed.

Each chat screen subscribes to message changes filtered by `chat_id`. Messages ordered by `created DESC`, limited to 20 for initial load, with cursor-based pagination for history.

### Presence (Online Users)

Supabase Realtime Presence replaces both Firebase Realtime Database and the `onUserStatusChange` Cloud Function.

- Client joins a Presence channel on app open, tracks `{user_id, online_at}`
- A PostgreSQL trigger updates `users.presence` and `users.last_active` when presence state changes
- Handles disconnect automatically (WebSocket close = offline)

### Private Chats Stream

Subscribe to `private_chats` changes filtered by `users @> ARRAY[userId]` (array contains).

### Performance at Scale (1K–10K concurrent)

- Channel-based subscriptions (one channel per chat room, not broad table listeners)
- PostgreSQL `max_connections` tuned appropriately
- PgBouncer connection pooling (built into Supabase self-hosted)

---

## 3. Authentication

### Providers

- **Google OAuth**: Configured in Supabase dashboard. Flutter uses `supabase_flutter` SDK.
- **Apple OAuth**: Same pattern. Required for App Store compliance.
- **Anonymous Auth**: `supabase.auth.signInAnonymously()` — built-in.

### User Migration

1. Export Firebase Auth users (UIDs + emails) via Firebase Admin SDK
2. Create matching accounts in Supabase Auth via admin API
3. Store `firebase_uid` in users table for reference
4. Users sign in again via Google/Apple (matched by email)

### Session Management

- Supabase handles JWT tokens and refresh automatically
- `supabase.auth.onAuthStateChange` replaces `FirebaseAuth.instance.authStateChanges()`
- User ID via `supabase.auth.currentUser?.id`

---

## 4. File Storage

### Buckets

- **`avatars`** — profile images, stored as `{userId}.png`. Public. Users can only upload/delete their own.
- **`chat-images`** — message images, stored as `{randomName}.png`. Public. Authenticated users can upload. Only admins can delete.

### Constraints

- Max file size: 2MB per image
- Stored on Mac Mini disk (Docker volume)

### API Mapping

| Firebase | Supabase |
|---|---|
| `putFile(path)` | `storage.from('bucket').upload(path, file)` |
| `putData(bytes)` | `storage.from('bucket').uploadBinary(path, bytes)` |
| `getDownloadURL()` | `storage.from('bucket').getPublicUrl(path)` |
| `delete(path)` | `storage.from('bucket').remove([path])` |

Messages store relative paths, not full URLs. URLs constructed from Supabase host at render time.

---

## 5. Cloud Functions & FCM

### Kept on Firebase

- Firebase Cloud Messaging (FCM) — free push delivery
- One HTTP-triggered Cloud Function for sending pushes

### Push Notification Flow

1. New private message inserted into `messages` table (is_private=true)
2. PostgreSQL trigger fires a webhook to the Firebase Cloud Function (HTTP endpoint)
3. Cloud Function receives message data, looks up recipient's FCM token from Supabase via REST API
4. Cloud Function sends push via `admin.messaging().send()`

### Removed from Firebase

- **`onUserStatusChange`** — replaced by Supabase Presence
- **`deletePrivateChatOnLastLeft`** — replaced by PostgreSQL trigger (when users array < 2, delete the row)

---

## 6. Packages Removed & Added

### Removed from pubspec.yaml

| Package | Replaced By |
|---|---|
| cloud_firestore | supabase_flutter |
| firebase_auth | supabase_flutter (Supabase Auth) |
| firebase_storage | supabase_flutter (Supabase Storage) |
| firebase_database | supabase_flutter (Realtime Presence) |
| firebase_app_check | Supabase RLS |
| firebase_performance | Removed (unused) |
| firebase_analytics | Removed (broken) |
| cloud_functions | Removed (unused in Flutter) |
| google_sign_in | Supabase handles OAuth natively |
| sign_in_with_apple | Supabase handles OAuth natively |

### Kept

| Package | Reason |
|---|---|
| firebase_core | Required for Crashlytics and FCM |
| firebase_crashlytics | Free, no good self-hosted alternative |
| firebase_messaging | FCM is free, Supabase has no push service |

### Added

| Package | Purpose |
|---|---|
| supabase_flutter | Supabase client SDK (auth, database, storage, realtime) |

---

## 7. Files Changed

### Deleted

- `lib/firebase_options.dart` — replaced by Supabase config
- `lib/repository/presence_database.dart` — replaced by Supabase Presence

### Rewritten (Repository Swap)

- `lib/repository/firestore_repository.dart` → `lib/repository/supabase_repository.dart`
- `lib/repository/login_repository.dart` → `lib/repository/supabase_auth_repository.dart`
- `lib/repository/storage_repository.dart` → `lib/repository/supabase_storage_repository.dart`

### Modified

- `lib/main.dart` — initialize Supabase, keep Firebase init for Crashlytics/FCM only
- `lib/repository/fcm_repository.dart` — save FCM token to Supabase instead of Firestore
- All BLoC/Cubit files — update repository imports (no logic changes)
- `pubspec.yaml` — swap dependencies

### New

- `lib/repository/supabase_repository.dart` — database operations
- `lib/repository/supabase_auth_repository.dart` — authentication
- `lib/repository/supabase_storage_repository.dart` — file storage
- `lib/repository/supabase_presence_repository.dart` — online status tracking
- `lib/supabase_options.dart` — Supabase URL and anon key config

### Cloud Functions

- `functions/index.js` — rewritten: remove Firestore triggers, add HTTP endpoint for push notifications

---

## 8. Mac Mini Setup

### Docker Compose

Self-hosted Supabase runs via `docker compose` with these services:
- PostgreSQL (database)
- GoTrue (auth)
- Realtime (WebSocket subscriptions)
- Storage API (file storage)
- Kong (API gateway)
- PostgREST (REST API)
- PgBouncer (connection pooling)

### Configuration

- PostgreSQL `max_connections`: 200 (sufficient for 10K concurrent via PgBouncer)
- Storage volume mounted to local disk
- SSL via existing internet-accessible setup
- Regular PostgreSQL backups (pg_dump cron job)
