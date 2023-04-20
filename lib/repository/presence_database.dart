import 'package:chat/repository/firestore_repository.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/log.dart';

class PresenceDatabase {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  updateUserPresence() async {
    Map<String, dynamic> presenceStatusTrue = {
      'presence': true,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    await databaseReference
        .child(getUserId())
        .update(presenceStatusTrue)
        .whenComplete(() => Log.d('Updated your presence.'))
        .catchError((e) => Log.e(e));

    Map<String, dynamic> presenceStatusFalse = {
      'presence': false,
      'last_seen': DateTime.now().millisecondsSinceEpoch,
    };

    databaseReference.child(getUserId()).onDisconnect().update(presenceStatusFalse);
  }
}