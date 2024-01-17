import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat_user.dart';
import '../repository/firestore_repository.dart';

class OnlineUsersProcessor {
  Isolate? _isolate;
  SendPort? _sendPort;
  final ReceivePort _receivePort = ReceivePort();

  Future<void> start() async {
    _isolate = await Isolate.spawn(processUsers, _receivePort.sendPort);
    _sendPort = await _receivePort.first as SendPort;
  }

  Future<List<ChatUser>> process(List<QueryDocumentSnapshot> events,
      String userId, String userCountryCode, Duration onlineDuration) async {
    // Convert Firestore data to a serializable format
    var serializableEvents = events.map((e) {
      Map<String, dynamic> data = e.data() as Map<String, dynamic>;

      // Convert Timestamp to milliseconds since epoch
      if (data.containsKey('lastActive') && data['lastActive'] is Timestamp) {
        data['lastActive'] =
            (data['lastActive'] as Timestamp).millisecondsSinceEpoch;
      }

      return {'id': e.id, 'data': data};
    }).toList();

    ReceivePort responsePort = ReceivePort();

    // Include userId and onlineDuration in the message
    _sendPort!.send([
      serializableEvents,
      userId,
      userCountryCode,
      onlineDuration,
      responsePort.sendPort
    ]);

    var result = await responsePort.first as List;
    return result as List<ChatUser>;
  }

  static void sortOnlineUsers(List<ChatUser> filteredUsers, String countryCode) {
    filteredUsers.sort((a, b) {
      // Check if the user is from the same country as yours
      bool isSameCountryAsMineA = a.countryCode == countryCode;
      bool isSameCountryAsMineB = b.countryCode == countryCode;

      // Handle empty country codes by moving them to the end
      if (a.countryCode.isEmpty) {
        return 1;
      } else if (b.countryCode.isEmpty) {
        return -1;
      }

      // If both users are from the same country as yours, sort by lastActive in descending order
      if (isSameCountryAsMineA && isSameCountryAsMineB) {
        return b.lastActive.compareTo(a.lastActive);
      }

      // Sort users from the same country as yours first
      if (isSameCountryAsMineA) {
        return -1;
      } else if (isSameCountryAsMineB) {
        return 1;
      }

      // If the users are not from the same country, sort by countryCode and then lastActive
      int countryCodeComparison = a.countryCode.compareTo(b.countryCode);
      if (countryCodeComparison != 0) {
        return countryCodeComparison;
      } else {
        return b.lastActive.compareTo(a.lastActive);
      }
    });
  }

  static void processUsers(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      var data = message[0] as List<Map>;
      var userId = message[1] as String;
      var userCountryCode = message[2] as String;
      var onlineDuration = message[3] as Duration;
      SendPort replyPort = message[4];

      var users = data
          .map(
              (e) => {'id': e['id'], 'data': e['data'] as Map<String, dynamic>})
          .toList();
      var filteredUsers = users
          .where((element) => element['id'] != userId)
          .where((element) =>
              DateTime.fromMillisecondsSinceEpoch(element['data']['lastActive'])
                  .isAfter(DateTime.now().subtract(onlineDuration)))
          .toList();

      var chatUsers = filteredUsers.map((userData) {
        return ChatUser.fromJson(userData['id'], userData['data']);
      }).toList();

      sortOnlineUsers(chatUsers, userCountryCode);

      replyPort.send(chatUsers);
    });
  }

  void stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}
