import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class PrivateChatEndpoint extends Endpoint {
  Future<PrivateChat?> createPrivateChat(Session session, String otherUserId,
      String initialMessage, String myName, int myGender, String myPictureData,
      String otherName, int otherGender, String otherPictureData) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return null;

    var myUser = await ChatUser.db.findFirstRow(
      session, where: (t) => t.authUserIdentifier.equals(authId));
    if (myUser == null) return null;

    var trimmed = initialMessage.trim();
    if (trimmed.isEmpty || trimmed.length > 1000) return null;

    var chat = PrivateChat(
      users: [myUser.id.toString(), otherUserId],
      created: DateTime.now(),
      initiatedBy: myUser.id.toString(),
      initiatedByUserName: myName,
      initiatedByUserGender: myGender,
      initiatedByPictureData: myPictureData,
      chatName: '$otherName $myName',
      otherUserId: otherUserId,
      otherUserName: otherName,
      otherUserGender: otherGender,
      otherUserPictureData: otherPictureData,
      lastMessage: '',
      lastMessageIsGiphy: false,
      lastMessageByName: '',
      lastMessageTimestamp: DateTime.now(),
      lastMessageReadBy: [myUser.id.toString()],
      sendPushToUserId: otherUserId,
    );

    return await PrivateChat.db.insertRow(session, chat);
  }

  Future<bool> isPrivateChatAvailable(Session session, String otherUserId) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return false;

    var myUser = await ChatUser.db.findFirstRow(
      session, where: (t) => t.authUserIdentifier.equals(authId));
    if (myUser == null) return false;

    var allChats = await PrivateChat.db.find(session);
    var existing = allChats.where((c) =>
        c.users.contains(myUser.id.toString()) &&
        c.users.contains(otherUserId));
    return existing.isEmpty;
  }

  Future<void> leavePrivateChat(Session session, String chatId) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session, where: (t) => t.authUserIdentifier.equals(authId));
    if (myUser == null) return;

    var chat = await PrivateChat.db.findById(session, UuidValue.fromString(chatId));
    if (chat == null) return;

    chat.users = chat.users.where((id) => id != myUser.id.toString()).toList();

    if (chat.users.length < 2) {
      await ChatMessage.db.deleteWhere(
        session, where: (t) => t.chatId.equals(chatId));
      await PrivateChat.db.deleteRow(session, chat);
    } else {
      await PrivateChat.db.updateRow(session, chat);
    }
  }

  Future<void> setLastMessageRead(Session session, String chatId) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session, where: (t) => t.authUserIdentifier.equals(authId));
    if (myUser == null) return;

    var chat = await PrivateChat.db.findById(session, UuidValue.fromString(chatId));
    if (chat == null) return;

    if (!chat.lastMessageReadBy.contains(myUser.id.toString())) {
      chat.lastMessageReadBy = [...chat.lastMessageReadBy, myUser.id.toString()];
      await PrivateChat.db.updateRow(session, chat);
    }
  }

  Future<void> leaveAllPrivateChats(Session session) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session, where: (t) => t.authUserIdentifier.equals(authId));
    if (myUser == null) return;

    var allChats = await PrivateChat.db.find(session);
    var myChats = allChats.where((c) => c.users.contains(myUser.id.toString())).toList();

    for (var chat in myChats) {
      chat.users = chat.users.where((id) => id != myUser.id.toString()).toList();
      if (chat.users.length < 2) {
        await ChatMessage.db.deleteWhere(
          session, where: (t) => t.chatId.equals(chat.id.toString()));
        await PrivateChat.db.deleteRow(session, chat);
      } else {
        await PrivateChat.db.updateRow(session, chat);
      }
    }
  }

  Future<List<PrivateChat>> getPrivateChats(Session session) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return [];

    var myUser = await ChatUser.db.findFirstRow(
      session, where: (t) => t.authUserIdentifier.equals(authId));
    if (myUser == null) return [];

    var allChats = await PrivateChat.db.find(session);
    return allChats.where((c) => c.users.contains(myUser.id.toString())).toList();
  }

  Future<PrivateChat?> getPrivateChatWithUser(Session session, String otherUserId) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return null;

    var myUser = await ChatUser.db.findFirstRow(
      session, where: (t) => t.authUserIdentifier.equals(authId));
    if (myUser == null) return null;

    var allChats = await PrivateChat.db.find(session);
    return allChats
        .where((c) =>
            c.users.contains(myUser.id.toString()) &&
            c.users.contains(otherUserId))
        .firstOrNull;
  }
}
