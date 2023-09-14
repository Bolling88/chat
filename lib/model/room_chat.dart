import 'package:chat/model/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/time_util.dart';
import 'chat.dart';

class RoomChat extends Chat implements Comparable<RoomChat> {
  final String countryCode;
  final String chatName;
  final int chatColor;
  final String imageUrl;
  final int imageOverflow;
  final int imageTranslationX;

  final List<ChatUser> userInfos = [];
  final String usersText = "";

  RoomChat({
    required this.countryCode,
    required this.chatName,
    required this.chatColor,
    required this.imageUrl,
    required this.imageOverflow,
    required this.imageTranslationX,
    required String id,
    required List<String> users,
    required String lastMessage,
    required String lastMessageByName,
    required Timestamp lastMessageTimestamp,
    required String lastMessageUserId,
    required bool lastMessageReadByUser,
  }) : super(
          id: id,
          users: users,
          lastMessage: lastMessage,
          lastMessageByName: lastMessageByName,
          lastMessageTimestamp: lastMessageTimestamp,
          lastMessageUserId: lastMessageUserId,
          lastMessageReadByUser: lastMessageReadByUser,
        );

  RoomChat.fromJson(String id, Map<String, dynamic> json)
      : countryCode = json['countryCode'] ?? 'en',
        chatName = json['chatName'] ?? "",
        chatColor = json['chatColor'] ?? 0xFF30c7c2,
        imageUrl = json['imageUrl'] ?? "",
        imageOverflow = json['imageOverflow'] ?? 80,
        imageTranslationX = json['imageTranslationX'] ?? 0,
        super(
          id: id,
          users: json['users']?.cast<String>() ?? [],
          lastMessage: json['lastMessage'] ?? "",
          lastMessageByName: json['lastMessageByName'] ?? "",
          lastMessageTimestamp: json['lastMessageTimestamp'] ?? Timestamp.now(),
          lastMessageUserId: json['lastMessageUserId'] ?? "",
          lastMessageReadByUser: false,
        ); // Call the superclass constructor;

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromTimeStamp(lastMessageTimestamp);
  }

  @override
  int compareTo(RoomChat other) {
    return lastMessageTimestamp.compareTo(other.lastMessageTimestamp);
  }

  @override
  RoomChat copyWith({
    String? countryCode,
    String? chatName,
    int? chatColor,
    String? imageUrl,
    int? imageOverflow,
    int? imageTranslationX,
    String? id,
    List<String>? users,
    String? lastMessage,
    String? lastMessageByName,
    Timestamp? lastMessageTimestamp,
    String? lastMessageUserId,
    bool? lastMessageReadByUser,
  }) {
    return RoomChat(
      countryCode: countryCode ?? this.countryCode,
      chatName: chatName ?? this.chatName,
      chatColor: chatColor ?? this.chatColor,
      imageUrl: imageUrl ?? this.imageUrl,
      imageOverflow: imageOverflow ?? this.imageOverflow,
      imageTranslationX: imageTranslationX ?? this.imageTranslationX,
      id: id ?? this.id,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
      lastMessageReadByUser:
          lastMessageReadByUser ?? this.lastMessageReadByUser,
    );
  }

  @override
  List<Object> get props => [
        id,
        countryCode,
        lastMessage,
        lastMessageByName,
        lastMessageTimestamp,
        lastMessageUserId,
        users,
        userInfos,
        lastMessageReadByUser,
        chatName,
        chatColor,
        usersText,
        imageUrl,
        imageOverflow,
        imageTranslationX
      ];

  @override
  String getChatName(String userId) {
    return chatName;
  }
}
