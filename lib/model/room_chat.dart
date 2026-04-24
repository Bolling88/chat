import 'package:chat/model/chat_user.dart';
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
      : countryCode = json['country_code'] ?? 'en',
        chatName = json['chat_name'] ?? "",
        chatColor = json['chat_color'] ?? 0xFF30c7c2,
        imageUrl = json['image_url'] ?? "",
        imageOverflow = json['image_overflow'] ?? 80,
        imageTranslationX = json['image_translation_x'] ?? 0,
        infoKey = json['info_key'] ?? '',
        lastMessageReadByUser = false,
        enabled = json['enabled'] ?? true,
        super(
          id: id,
          lastMessage: json['last_message'] ?? "",
          lastMessageIsGiphy: json['last_message_is_giphy'] ?? false,
          lastMessageByName: json['last_message_by_name'] ?? "",
          lastMessageTimestamp: parseDateTime(json['last_message_timestamp']),
          lastMessageUserId: json['last_message_user_id'] ?? "",
        );

  String getLastMessageReadableDate() {
    return getLastMessageTimeFromDateTime(lastMessageTimestamp);
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
    DateTime? lastMessageTimestamp,
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
        id, countryCode, lastMessage, lastMessageIsGiphy,
        lastMessageByName, lastMessageTimestamp, lastMessageUserId,
        lastMessageReadByUser, enabled, chatName, chatColor,
        imageUrl, imageOverflow, imageTranslationX, infoKey
      ];

  @override
  String getChatName(String userId) => chatName;

  @override
  Color getChatColor(String userId, BuildContext context) => Color(chatColor);

  @override
  String? getChatImage(String userId) => null;

  @override
  String getOtherUserId(String userId) => '';

  @override
  bool isPrivateChat() => false;

  String getInfoText(BuildContext context) {
    if (infoKey.isEmpty) {
      return FlutterI18n.translate(context, 'info_country');
    }
    return FlutterI18n.translate(context, infoKey);
  }
}
