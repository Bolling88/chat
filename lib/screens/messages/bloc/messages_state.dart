import 'package:chat/model/chat_user.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../model/message_item.dart';

abstract class MessagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessagesLoadingState extends MessagesState {}

class MessagesEmptyState extends MessagesState {}

class MessagesErrorState extends MessagesState {}

class MessagesBaseState extends MessagesState {
  final List<MessageItem> messages;
  final ChatUser myUser;
  final String currentMessage;
  final BannerAd? bannerAd;

  MessagesBaseState(
      this.messages, this.myUser, this.currentMessage, this.bannerAd);

  MessagesBaseState copyWith(
      {List<MessageItem>? messages,
      String? userId,
      ChatUser? myUser,
      String? currentMessage,
      BannerAd? bannerAd}) {
    return MessagesBaseState(messages ?? this.messages, myUser ?? this.myUser,
        currentMessage ?? this.currentMessage, bannerAd ?? this.bannerAd);
  }

  @override
  List<Object?> get props => [messages, myUser, currentMessage, bannerAd];
}
