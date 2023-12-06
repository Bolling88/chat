import 'dart:async';

import 'package:chat/model/chat_user.dart';
import 'package:chat/model/private_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universal_io/io.dart';
import '../../../model/chat.dart';
import '../../../model/message.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/audio.dart';
import '../../../utils/log.dart';
import 'messages_event.dart';
import 'messages_state.dart';
import 'package:collection/collection.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final Chat chat;
  final bool isPrivateChat;
  final FirestoreRepository _firestoreRepository;
  final secondsInFiveMinutes = 300;

  BannerAd? _anchoredAdaptiveAd;

  StreamSubscription<QuerySnapshot>? messagesStream;
  StreamSubscription<QuerySnapshot>? userStream;
  StreamSubscription<QuerySnapshot>? privateChatsStream;

  late ChatUser _user;

  MessagesBloc(this.chat, this._firestoreRepository,
      {required this.isPrivateChat})
      : super(MessagesLoadingState()) {
    add(MessagesInitialEvent());
  }

  @override
  Future<void> close() {
    messagesStream?.cancel();
    userStream?.cancel();
    privateChatsStream?.cancel();
    return super.close();
  }

  @override
  Stream<MessagesState> mapEventToState(MessagesEvent event) async* {
    Log.d(event.toString());
    final currentState = state;
    if (event is MessagesInitialEvent) {
      _user = (await _firestoreRepository.getUser())!;
      setUpMessagesListener(chat.id);
      setUpUserListener();
      if (isPrivateChat) {
        setUpPrivateChatStream();
      }
    } else if (event is MessagesSendEvent) {
      if (currentState is MessagesBaseState) {
        if (currentState.currentMessage.isNotEmpty) {
          await _firestoreRepository.postMessage(
            chatId: chat.id,
            user: currentState.myUser,
            chatType: ChatType.message,
            message: currentState.currentMessage,
            isPrivateChat: isPrivateChat,
            sendPushToUserId: (chat is PrivateChat
                ? (chat as PrivateChat)
                    .users
                    .where((element) => element != getUserId())
                    .firstOrNull
                : null),
          );
          yield currentState.copyWith(currentMessage: "");
        }
      }
    } else if (event is MessagesChangedEvent) {
      if (currentState is MessagesBaseState) {
        yield currentState.copyWith(currentMessage: event.message);
      }
    } else if (event is MessagesUpdatedEvent) {
      Log.d("Got more messages event");
      if (currentState is MessagesBaseState) {
        Log.d("New message id: ${event.messages.first.id}");

        //Before we can update with the new messages, we need to check which old messages were marked or translated, and make sure if an updated message has the same id, it should also be marked or translated
        final updatedMessages = event.messages.map((e) {
          final oldMessage = currentState.messages
              .firstWhereOrNull((element) => element.id == e.id);
          if (oldMessage != null) {
            return e.copyWith(
                marked: oldMessage.marked, translation: oldMessage.translation);
          } else {
            return e;
          }
        }).toList();

        yield currentState.copyWith(messages: updatedMessages);
        if (currentState.messages.first.id != event.messages.first.id) {
          playMessageSound();
        }
      } else {
        final currentChat = chat;
        yield MessagesBaseState(event.messages, _user, '', _anchoredAdaptiveAd,
            (currentChat is PrivateChat) ? currentChat : null);
      }
    } else if (event is MessagesUserUpdatedEvent) {
      if (currentState is MessagesBaseState) {
        yield currentState.copyWith(myUser: event.user);
      }
    } else if (event is MessagesGiphyPickedEvent) {
      Log.d("Got giphy event");
      if (currentState is MessagesBaseState) {
        final String giphyUrl = event.gif.images?.downsized?.url ?? "";
        await _firestoreRepository.postMessage(
            chatId: chat.id,
            user: currentState.myUser,
            chatType: ChatType.giphy,
            message: giphyUrl,
            isPrivateChat: isPrivateChat,
            sendPushToUserId: (chat is PrivateChat
                ? (chat as PrivateChat)
                    .users
                    .where((element) => element != getUserId())
                    .firstOrNull
                : null),
            isGiphy: true);
        yield currentState.copyWith(currentMessage: "");
      }
    } else if (event is MessagesReportMessageEvent) {
      _firestoreRepository.reportMessage(event.message);
    } else if (event is MessagesBannerAdLoadedEvent) {
      if (currentState is MessagesBaseState) {
        yield currentState.copyWith(bannerAd: _anchoredAdaptiveAd);
      }
    } else if (event is MessagesPrivateChatsUpdatedEvent) {
      if (currentState is MessagesBaseState) {
        yield currentState.copyWith(privateChat: event.privateChats);
      }
    } else if (event is MessagesTranslateEvent) {
      if (currentState is MessagesBaseState) {
        //Replace the message model in the state with the message model in the event and update the state
        final updatedMessages = currentState.messages
            .map((e) => e.id == event.message.id ? event.message : e)
            .toList();
        yield currentState.copyWith(messages: updatedMessages);
      }
    } else if (event is MessagesMarkedEvent) {
      if (currentState is MessagesBaseState) {
        //Find the message in the current state messages and update the marked value
        final updatedMessages = currentState.messages
            .map((e) =>
                e.id == event.message.id ? e.copyWith(marked: event.marked) : e)
            .toList();
        yield currentState.copyWith(messages: updatedMessages);
      }
    } else {
      yield MessagesErrorState();
      Log.e("Error in messages");
    }
  }

  void setUpMessagesListener(String chatId) async {
    Log.d('Setting up message stream');
    messagesStream = _firestoreRepository
        .streamMessages(chatId, isPrivateChat, 20)
        .listen((data) {
      Log.d("Got messages");
      final messages = data.docs
          .map((e) => Message.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();
      if (messages.isNotEmpty) add(MessagesUpdatedEvent(messages));
    });
  }

  void setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository.streamUser().listen((event) async {
      final user = ChatUser.fromJson(
          event.docs.first.id, event.docs.first.data() as Map<String, dynamic>);
      add(MessagesUserUpdatedEvent(user));
    });
  }

  void setUpPrivateChatStream() async {
    Log.d('Setting up private chats stream');
    privateChatsStream =
        _firestoreRepository.getPrivateChatsStream().listen((event) async {
      Log.d("Got private chats");
      final PrivateChat? updatedChat = event.docs
          .map((e) =>
              PrivateChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .firstWhereOrNull((element) => element.id == chat.id);
      if (updatedChat != null) {
        add(MessagesPrivateChatsUpdatedEvent(updatedChat));
      }
    });
  }

  Future<void> loadAd(int adWidth) async {
    if (_anchoredAdaptiveAd != null) {
      return;
    }
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(adWidth);

    if (size == null) {
      Log.e('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: Platform.isAndroid
          ? kDebugMode
              ? 'ca-app-pub-3940256099942544/6300978111'
              : 'ca-app-pub-5287847424239288/6302220901'
          : kDebugMode
              ? 'ca-app-pub-3940256099942544/2934735716'
              : 'ca-app-pub-5287847424239288/4633916012',
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          Log.d('$ad loaded: ${ad.responseInfo}');
          add(MessagesBannerAdLoadedEvent());
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          Log.e('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd?.load();
  }
}
