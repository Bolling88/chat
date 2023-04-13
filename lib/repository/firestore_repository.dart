import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/chat_user.dart';
import '../utils/log.dart';

enum Gender {
  female(0),
  male(1),
  nonBinary(2);

  const Gender(this.value);

  final num value;
}

class FirestoreRepository {
  FirestoreRepository();

  String getUserId() => FirebaseAuth.instance.currentUser!.uid;

  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<ChatUser?> getUser({String? userId}) async {
    return users
        .doc((userId != null) ? userId : FirebaseAuth.instance.currentUser?.uid)
        .get()
        .then((value) => value.exists
            ? ChatUser.fromJson(value.id, value.data() as Map<String, dynamic>)
            : null)
        .catchError((error) {
      Log.e("Failed to add user: $error");
      return null;
    });
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

  Future<void> updateUserGender(Gender gender) async {
    return users
        .doc(getUserId())
        .set({'gender': gender.value}, SetOptions(merge: true))
        .then((value) => Log.d("User gender updated"))
        .catchError((error) => Log.e("Failed to update user gender: $error"));
  }

  Future<void> updateUserDisplayName(String fullName, List<String> searchArray) async {
    return users
        .doc(getUserId())
        .set({
          'displayName': fullName,
          'searchArray': searchArray,
        }, SetOptions(merge: true))
        .then((value) => Log.d("User displayName updated"))
        .catchError((error) => Log.e("Failed to update user displayName: $error"));
  }

  Future<void> updateUserProfileImage(String profileImageUrl) async {
    return users
        .doc(getUserId())
        .set({'pictureData': profileImageUrl}, SetOptions(merge: true))
        .then((value) => Log.d("User profile image updated"))
        .catchError((error) => Log.e("Failed to update user image: $error"));
  }
}
