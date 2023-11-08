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
import '../../../model/message_item.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/audio.dart';
import '../../../utils/log.dart';
import '../../../utils/time_util.dart';
import 'messages_event.dart';
import 'messages_state.dart';
import 'package:collection/collection.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final Chat chat;
  final bool isPrivateChat;
  DocumentSnapshot? _lastMessageSnapshot;
  final FirestoreRepository _firestoreRepository;
  final secondsInFiveMinutes = 300;

  BannerAd? _anchoredAdaptiveAd;

  StreamSubscription<QuerySnapshot>? messagesStream;
  StreamSubscription<QuerySnapshot>? userStream;
  StreamSubscription<QuerySnapshot>? privateChatsStream;

  MessagesBloc(this.chat, this._firestoreRepository,
      {required this.isPrivateChat})
      : super(MessagesLoadingState()) {
    add(MessagesInitialEvent());
  }

  @override
  Future<void> close() {
    postLeftMessage();
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
      postJoinedMessage();
      final user = await _firestoreRepository.getUser();
      if (user != null) {
        final data = await _firestoreRepository.getInitialMessages(
            chat.id, isPrivateChat);
        if (data.docs.isNotEmpty) {
          Log.d("New documents: ${data.docs.length}");
          _lastMessageSnapshot = data.docs.last;
          final initialMessages = data.docs
              .map((e) =>
                  Message.fromJson(e.id, e.data() as Map<String, dynamic>))
              .toList();

          yield MessagesBaseState(
              getMessagesWithDates(initialMessages), user, "", null, null);
        } else {
          yield MessagesBaseState(const [], user, "", null, null);
        }
        setUpMessagesListener(chat.id);
        setUpUserListener();
        if (isPrivateChat) {
          setUpPrivateChatStream();
        }
      } else {
        Log.e("User is null in messages bloc");
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
      if (currentState is MessagesBaseState &&
          (currentState.messages.isEmpty ||
              event.messages.last.id !=
                  currentState.messages.first.message!.id)) {
        Log.d("New message id: ${event.messages.last.id}");
        final List<MessageItem> updatedList = [...currentState.messages];
        updatedList.insertAll(0, getMessagesWithDates(event.messages));
        Log.d("Total messages: ${updatedList.length}");
        yield currentState.copyWith(messages: updatedList);
        if (event.messages.last.createdById != getUserId()) {
          playMessageSound();
        }
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
        final PrivateChat? privateChat = event.privateChats
            .firstWhereOrNull((element) => element.id == chat.id);
        yield currentState.copyWith(privateChat: privateChat);
      }
    } else {
      yield MessagesErrorState();
      Log.e("Error in messages");
    }
  }

  void postJoinedMessage() {
    // _firestoreRepository.postMessage(
    //     chatId: chat.id,
    //     user: _chatUser,
    //     chatType: ChatType.joined,
    //     message: _chatUser.displayName,
    //     isPrivateChat: isPrivateChat);
  }

  void postLeftMessage() {
    // _firestoreRepository.postMessage(
    //     chatId: chat.id,
    //     user: _chatUser,
    //     chatType: ChatType.left,
    //     message: _chatUser.displayName,
    //     isPrivateChat: isPrivateChat);
  }

  void setUpMessagesListener(String chatId) async {
    Log.d('Setting up message stream');
    messagesStream = _firestoreRepository
        .streamMessages(chatId, isPrivateChat, 1)
        .listen((data) {
      Log.d("Got messages");
      //Only add last document as snapshot if this is initial fetch.
      if (_lastMessageSnapshot == null && data.docs.isNotEmpty) {
        _lastMessageSnapshot = data.docs.last;
      }
      final messages = data.docs
          .map((e) => Message.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList()
          .reversed
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
        _firestoreRepository.privateChatsStream.listen((event) async {
      Log.d("Got private chats");
      final chats = event.docs
          .map((e) =>
              PrivateChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();
      chats.sort((a, b) => a.created.compareTo(b.created));
      Log.d("Chats: ${chats.length}");
      add(MessagesPrivateChatsUpdatedEvent(chats));
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
      // TODO: replace these test ad units with your own ad unit.
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

  List<MessageItem> getMessagesWithDates(List<Message> messages) {
    final List<MessageItem> datedList = [];
    if (messages.length == 1) {
      //If this is a new message after entering the chat, don't bother with dates
      datedList.add(MessageItem(messages.last, null));
      return datedList;
    }

    if (messages.isNotEmpty) {
      for (int i = 1; i <= messages.length - 1; i++) {
        final current = messages[i];
        if (i < messages.length - 1) {
          final next = messages[i + 1];
          if (current.created.seconds - next.created.seconds >=
              secondsInFiveMinutes) {
            datedList.add(MessageItem(current, null));
            datedList.add(MessageItem(null, getMessageDate(current.created)));
          } else {
            datedList.add(MessageItem(current, null));
          }
        }
      }
      datedList.add(MessageItem(messages.last, null));
      datedList.add(MessageItem(null, getMessageDate(messages.last.created)));
    }
    return datedList;
  }

  @override
  Stream<Transition<MessagesEvent, MessagesState>> transformEvents(
      Stream<MessagesEvent> events, transitionFn) {
    return super.transformEvents(
      events.distinct(),
      transitionFn,
    );
  }
}
