import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/chat_user.dart';
import 'online_users_processor.dart';

class WebOnlineUsersProcessor extends OnlineUserProcessor{
  @override
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

    // Directly call the processing method
    var chatUsers = processUsers(
      serializableEvents,
      userId,
      userCountryCode,
      onlineDuration,
    );

    return chatUsers;
  }

  static List<ChatUser> processUsers(
      List<Map> data,
      String userId,
      String userCountryCode,
      Duration onlineDuration,
      ) {
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

    return chatUsers;
  }

  @override
  Future<void> start() {
   return Future.value();
  }

  @override
  void stop() {
    //Do nothing
  }
}
