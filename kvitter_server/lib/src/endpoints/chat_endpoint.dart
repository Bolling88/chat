import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class ChatEndpoint extends Endpoint {
  Future<RoomChat?> getChat(Session session, String chatId) async {
    return await RoomChat.db.findById(session, UuidValue.fromString(chatId));
  }

  Future<List<RoomChat>> getOpenChats(
    Session session,
    String countryCode,
    bool isDebug,
  ) async {
    if (isDebug) {
      return await RoomChat.db.find(session);
    }
    return await RoomChat.db.find(
      session,
      where: (t) =>
          t.enabled.equals(true) &
          (t.countryCode.equals('all') | t.countryCode.equals(countryCode)),
    );
  }

  Future<List<ChatMessage>> getInitialMessages(
    Session session,
    String chatId,
    bool isPrivate,
  ) async {
    return await ChatMessage.db.find(
      session,
      where: (t) => t.chatId.equals(chatId) & t.isPrivate.equals(isPrivate),
      orderBy: (t) => t.created,
      orderDescending: true,
      limit: 20,
    );
  }

  Future<List<ChatMessage>> getMoreMessages(
    Session session,
    String chatId,
    bool isPrivate,
    DateTime before,
  ) async {
    return await ChatMessage.db.find(
      session,
      where: (t) =>
          t.chatId.equals(chatId) &
          t.isPrivate.equals(isPrivate) &
          (t.created < before),
      orderBy: (t) => t.created,
      orderDescending: true,
      limit: 20,
    );
  }

  Future<ChatMessage> postMessage(Session session, ChatMessage message) async {
    var inserted = await ChatMessage.db.insertRow(session, message);

    if (message.isPrivate) {
      var privateChat = await PrivateChat.db.findById(
        session,
        UuidValue.fromString(message.chatId),
      );
      if (privateChat != null) {
        privateChat.lastMessage = message.text;
        privateChat.lastMessageIsGiphy = message.chatType == 3;
        privateChat.lastMessageByName = message.createdByName;
        privateChat.lastMessageTimestamp = DateTime.now();
        privateChat.lastMessageUserId = message.createdById;
        privateChat.lastMessageReadBy = [message.createdById];
        await PrivateChat.db.updateRow(session, privateChat);
      }
    }

    return inserted;
  }

  Future<void> postFeedback(
    Session session,
    String feedback,
    String createdByName,
    String countryCode,
    String countryName,
  ) async {
    final authId = session.authenticated?.userIdentifier;
    if (authId == null) return;

    var myUser = await ChatUser.db.findFirstRow(
      session,
      where: (t) => t.authUserIdentifier.equals(authId),
    );
    if (myUser == null) return;

    await UserFeedback.db.insertRow(
      session,
      UserFeedback(
        feedback: feedback,
        createdById: myUser.id.toString(),
        createdByName: createdByName,
        createdByCountryCode: countryCode,
        createdByCountryName: countryName,
        created: DateTime.now(),
      ),
    );
  }

  Future<void> reduceCredits(
    Session session,
    String userId,
    int amount,
  ) async {
    var user = await ChatUser.db.findById(
      session,
      UuidValue.fromString(userId),
    );
    if (user == null) return;
    user.kvitterCredits = user.kvitterCredits - amount;
    await ChatUser.db.updateRow(session, user);
  }

  Future<void> increaseCredits(
    Session session,
    String userId,
    int amount,
  ) async {
    var user = await ChatUser.db.findById(
      session,
      UuidValue.fromString(userId),
    );
    if (user == null) return;
    user.kvitterCredits = user.kvitterCredits + amount;
    await ChatUser.db.updateRow(session, user);
  }
}
