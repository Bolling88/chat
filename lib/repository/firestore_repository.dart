import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/chat_user.dart';
import '../utils/log.dart';

class FirestoreRepository {

  FirestoreRepository();

  String getUserId() => FirebaseAuth.instance.currentUser!.uid;

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<ChatUser?> getUser({String? userId}) async {
    final querySnapshot = await users
        .doc((userId != null) ? userId : FirebaseAuth.instance.currentUser?.uid)
        .get();

    if (querySnapshot.data() == null) {
      return null;
    } else {
      Map<String, dynamic> data = querySnapshot.data as Map<String, dynamic>;
      return ChatUser.fromJson(querySnapshot.id, data);
    }
  }

  Future<void> setInitialUserData(String name, String email, String userId,
      List<String> searchArray) async {
    return users
        .doc(userId)
        .set({
          'name': name,
          'email': email,
          'searchArray': searchArray,
          'created': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        .then((value) => Log.d("User updated"))
        .catchError((error) => Log.e("Failed to add user: $error"));
  }
}
