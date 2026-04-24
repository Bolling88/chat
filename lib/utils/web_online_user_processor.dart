import '../model/chat_user.dart';
import 'online_users_processor.dart';

class WebOnlineUsersProcessor extends OnlineUserProcessor {
  @override
  Future<List<ChatUser>> process(List<Map<String, dynamic>> users,
      String userId, String userCountryCode, Duration onlineDuration) async {
    var filteredUsers = users
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

    return chatUsers;
  }

  @override
  Future<void> start() => Future.value();

  @override
  void stop() {}
}
