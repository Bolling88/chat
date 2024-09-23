import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../utils/time_util.dart';
import 'chat.dart';

class RoomChat extends Chat implements Comparable<RoomChat> {
  final String countryCode;
  final String chatName;
  final int chatColor;
  final String imageUrl;
  final int imageOverflow;
  final int imageTranslationX;
  final bool lastMessageReadByUser;
  final bool enabled;
  final String infoKey;

  const RoomChat({
    required this.countryCode,
    required this.chatName,
    required this.chatColor,
    required this.imageUrl,
    required this.imageOverflow,
    required this.imageTranslationX,
    required this.lastMessageReadByUser,
    required this.enabled,
    required this.infoKey,
    required super.id,
    required super.lastMessage,
    required super.lastMessageIsGiphy,
    required super.lastMessageByName,
    required super.lastMessageTimestamp,
    required super.lastMessageUserId,
  });

  RoomChat.fromJson(String id, Map<String, dynamic> json)
      : countryCode = json['countryCode'] ?? 'en',
        chatName = json['chatName'] ?? "",
        chatColor = json['chatColor'] ?? 0xFF30c7c2,
        imageUrl = json['imageUrl'] ?? "",
        imageOverflow = json['imageOverflow'] ?? 80,
        imageTranslationX = json['imageTranslationX'] ?? 0,
        infoKey = json['infoKey'] ?? '',
        lastMessageReadByUser = false,
        enabled = json['enabled'] ?? true,
        super(
          id: id,
          lastMessage: json['lastMessage'] ?? "",
          lastMessageIsGiphy: json['lastMessageIsGiphy'] ?? false,
          lastMessageByName: json['lastMessageByName'] ?? "",
          lastMessageTimestamp: json['lastMessageTimestamp'] ?? Timestamp.now(),
          lastMessageUserId: json['lastMessageUserId'] ?? "",
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
    bool? lastMessageIsGiphy,
    String? lastMessageByName,
    Timestamp? lastMessageTimestamp,
    String? lastMessageUserId,
    bool? lastMessageReadByUser,
    bool? enabled,
    String? infoKey,
  }) {
    return RoomChat(
      countryCode: countryCode ?? this.countryCode,
      chatName: chatName ?? this.chatName,
      chatColor: chatColor ?? this.chatColor,
      imageUrl: imageUrl ?? this.imageUrl,
      imageOverflow: imageOverflow ?? this.imageOverflow,
      imageTranslationX: imageTranslationX ?? this.imageTranslationX,
      id: id ?? this.id,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageIsGiphy: lastMessageIsGiphy ?? this.lastMessageIsGiphy,
      lastMessageByName: lastMessageByName ?? this.lastMessageByName,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      lastMessageUserId: lastMessageUserId ?? this.lastMessageUserId,
      infoKey: infoKey ?? this.infoKey,
      lastMessageReadByUser:
          lastMessageReadByUser ?? this.lastMessageReadByUser,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object> get props => [
        id,
        countryCode,
        lastMessage,
        lastMessageIsGiphy,
        lastMessageByName,
        lastMessageTimestamp,
        lastMessageUserId,
        lastMessageReadByUser,
        enabled,
        chatName,
        chatColor,
        imageUrl,
        imageOverflow,
        imageTranslationX,
        infoKey
      ];

  @override
  String getChatName(String userId) {
    return chatName;
  }

  @override
  Color getChatColor(String userId, BuildContext context) {
    return Color(chatColor);
  }

  @override
  String? getChatImage(String userId) {
    return null;
  }

  @override
  String getOtherUserId(String userId) {
    return '';
  }

  @override
  bool isPrivateChat() {
    return false;
  }

  String getInfoText(BuildContext context) {
    if (infoKey.isEmpty) {
      return FlutterI18n.translate(context, 'info_country');
    }
    return FlutterI18n.translate(context, infoKey);
  }
}
