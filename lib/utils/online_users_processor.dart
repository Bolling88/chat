import 'dart:isolate';

import '../model/chat_user.dart';

abstract class OnlineUserProcessor {
  Future<List<ChatUser>> process(List<Map<String, dynamic>> users,
      String userId, String userCountryCode, Duration onlineDuration);

  void stop();

  Future<void> start();
}

class MobileOnlineUsersProcessor extends OnlineUserProcessor {
  Isolate? _isolate;
  SendPort? _sendPort;
  final ReceivePort _receivePort = ReceivePort();

  @override
  Future<void> start() async {
    _isolate = await Isolate.spawn(processUsers, _receivePort.sendPort);
    _sendPort = await _receivePort.first as SendPort;
  }

  @override
  Future<List<ChatUser>> process(List<Map<String, dynamic>> users,
      String userId, String userCountryCode, Duration onlineDuration) async {
    ReceivePort responsePort = ReceivePort();

    _sendPort!.send([
      users,
      userId,
      userCountryCode,
      onlineDuration,
      responsePort.sendPort
    ]);

    var result = await responsePort.first as List;
    return result as List<ChatUser>;
  }

  static void processUsers(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      var data = message[0] as List<Map<String, dynamic>>;
      var userId = message[1] as String;
      var userCountryCode = message[2] as String;
      var onlineDuration = message[3] as Duration;
      SendPort replyPort = message[4];

      var filteredUsers = data
          .where((element) => element['id'] != userId)
          .where((element) {
            final lastActive = element['data']['last_active'];
            if (lastActive == null) return false;
            final dt = DateTime.parse(lastActive as String);
            return dt.isAfter(DateTime.now().subtract(onlineDuration));
          })
          .toList();

      var chatUsers = filteredUsers.map((userData) {
        return ChatUser.fromJson(
            userData['id'] as String, userData['data'] as Map<String, dynamic>);
      }).toList();

      sortOnlineUsers(chatUsers, userCountryCode);

      replyPort.send(chatUsers);
    });
  }

  @override
  void stop() {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }
}

void sortOnlineUsers(List<ChatUser> filteredUsers, String countryCode) {
  filteredUsers.sort((a, b) {
    bool isSameCountryAsMineA = a.countryCode == countryCode;
    bool isSameCountryAsMineB = b.countryCode == countryCode;

    if (a.countryCode.isEmpty) return 1;
    if (b.countryCode.isEmpty) return -1;

    if (isSameCountryAsMineA && isSameCountryAsMineB) {
      return b.lastActive.compareTo(a.lastActive);
    }
    if (isSameCountryAsMineA) return -1;
    if (isSameCountryAsMineB) return 1;

    int countryCodeComparison = a.countryCode.compareTo(b.countryCode);
    if (countryCodeComparison != 0) return countryCodeComparison;
    return b.lastActive.compareTo(a.lastActive);
  });
}
