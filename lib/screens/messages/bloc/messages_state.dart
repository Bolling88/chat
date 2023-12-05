import 'package:chat/model/chat_user.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../model/message.dart';
import '../../../model/message_item.dart';
import '../../../model/private_chat.dart';

abstract class MessagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessagesLoadingState extends MessagesState {}

class MessagesEmptyState extends MessagesState {}

class MessagesErrorState extends MessagesState {}

class MessagesBaseState extends MessagesState {
  final List<Message> messages;
  final ChatUser myUser;
  final String currentMessage;
  final BannerAd? bannerAd;
  final PrivateChat? privateChat;

  MessagesBaseState(this.messages, this.myUser, this.currentMessage,
      this.bannerAd, this.privateChat);

  MessagesBaseState copyWith(
      {List<Message>? messages,
      String? userId,
      ChatUser? myUser,
      String? currentMessage,
      BannerAd? bannerAd,
      PrivateChat? privateChat}) {
    return MessagesBaseState(
        messages ?? this.messages,
        myUser ?? this.myUser,
        currentMessage ?? this.currentMessage,
        bannerAd ?? this.bannerAd,
        privateChat ?? this.privateChat);
  }

  @override
  List<Object?> get props =>
      [messages, myUser, currentMessage, bannerAd, privateChat];
}
