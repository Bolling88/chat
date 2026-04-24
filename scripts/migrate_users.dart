// Run with: dart run scripts/migrate_users.dart
//
// Prerequisites:
// 1. Export Firebase Auth users to a JSON file using Firebase Admin SDK:
//    firebase auth:export users.json --format=json
// 2. Set environment variables:
//    SUPABASE_URL=https://your-mac-mini-domain
//    SUPABASE_SERVICE_KEY=your-service-role-key

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final supabaseUrl = Platform.environment['SUPABASE_URL']!;
  final serviceKey = Platform.environment['SUPABASE_SERVICE_KEY']!;

  final usersFile = File('users.json');
  if (!usersFile.existsSync()) {
    print('users.json not found. Export from Firebase first.');
    exit(1);
  }

  final usersData = jsonDecode(usersFile.readAsStringSync());
  final users = usersData['users'] as List;

  print('Migrating ${users.length} users...');

  for (final user in users) {
    final email = user['email'] as String?;
    final uid = user['localId'] as String;

    if (email == null || email.isEmpty) {
      print('Skipping anonymous user: $uid');
      continue;
    }

    try {
      // Create user in Supabase Auth via admin API
      final response = await http.post(
        Uri.parse('$supabaseUrl/auth/v1/admin/users'),
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'email_confirm': true,
          'user_metadata': {'firebase_uid': uid},
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newUser = jsonDecode(response.body);
        final newId = newUser['id'];

        // Create users table row with firebase_uid mapping
        await http.post(
          Uri.parse('$supabaseUrl/rest/v1/users'),
          headers: {
            'apikey': serviceKey,
            'Authorization': 'Bearer $serviceKey',
            'Content-Type': 'application/json',
            'Prefer': 'return=minimal',
          },
          body: jsonEncode({
            'id': newId,
            'firebase_uid': uid,
            'email': email,
          }),
        );

        print('Migrated: $email ($uid -> $newId)');
      } else {
        print('Failed to create user $email: ${response.body}');
      }
    } catch (e) {
      print('Error migrating $email: $e');
    }
  }

  print('Migration complete.');
}
