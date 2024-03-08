import 'package:chat/repository/firestore_repository.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/log.dart';

class PresenceDatabase {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  PresenceDatabase();

  updateUserPresence() async {
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    await databaseReference
        .child(getUserId())
        .update(presenceStatusTrue)
        .whenComplete(_logSuccess)
        .catchError((error) {
      Log.e('$error Updated your presence.');
    });

    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    databaseReference
        .child(getUserId())
        .onDisconnect()
        .update(presenceStatusFalse);
  }

  void _logSuccess() {
    Log.d('Updated your presence.');
  }
}
