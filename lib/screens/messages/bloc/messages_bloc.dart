import 'dart:async';
import 'dart:convert';

import 'package:chat/model/chat_user.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/repository/chat_clicked_repository.dart';
import 'package:chat/repository/storage_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';
import '../../../model/chat.dart';
import '../../../model/message.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/audio.dart';
import '../../../utils/constants.dart';
import '../../../utils/log.dart';
import 'messages_event.dart';
import 'messages_state.dart';
import 'package:collection/collection.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final Chat chat;
  final bool isPrivateChat;
  final FirestoreRepository _firestoreRepository;
  final ChatClickedRepository _chatClickedRepository;
  final StorageRepository _storageRepository;
  final picker = ImagePicker();

  BannerAd? _anchoredAdaptiveAd;

  StreamSubscription<QuerySnapshot>? messagesStream;
  StreamSubscription<QuerySnapshot>? userStream;
  StreamSubscription<QuerySnapshot>? privateChatsStream;
  StreamSubscription<List<ChatUser>>? onlineUsersStream;

  late ChatUser _user;

  MessagesBloc(this.chat, this._firestoreRepository,
      this._chatClickedRepository, this._storageRepository,
      {required this.isPrivateChat})
      : super(MessagesLoadingState()) {
    on<MessagesInitialEvent>(_onInitial);
    on<MessagesSendEvent>(_onSend);
    on<MessagesChangedEvent>(_onChanged);
    on<MessagesUpdatedEvent>(_onUpdated);
    on<MessagesUserUpdatedEvent>(_onUserUpdated);
    on<MessagesGiphyPickedEvent>(_onGiphyPicked);
    on<MessagesReportMessageEvent>(_onReportMessage);
    on<MessagesBannerAdLoadedEvent>(_onBannerAdLoaded);
    on<MessagesPrivateChatsUpdatedEvent>(_onPrivateChatsUpdated);
    on<MessagesTranslateEvent>(_onTranslate);
    on<MessagesMarkedEvent>(_onMarked);
    on<MessagesChatUsersInRoomUpdatedEvent>(_onChatUsersInRoomUpdated);
    on<MessagesReplyEvent>(_onReply);
    on<MessagesReplyEventClear>(_onReplyClear);
    on<MessagesGalleryClickedEvent>(_onGalleryClicked);
    on<MessagesCameraClickedEvent>(_onCameraClicked);

    add(MessagesInitialEvent());
  }

  @override
  Future<void> close() {
    messagesStream?.cancel();
    userStream?.cancel();
    privateChatsStream?.cancel();
    onlineUsersStream?.cancel();
    messagesStream = null;
    userStream = null;
    privateChatsStream = null;
    onlineUsersStream = null;
    return super.close();
  }

  void _onInitial(MessagesInitialEvent event, Emitter<MessagesState> emit) {
    _setUpUserListener();
    if (isPrivateChat) {
      _setUpPrivateChatStream();
      _setUpChatClickedListener();
    } else {
      _setUpOnlineUsersListener();
      //We don't want to set up message listeners for a private chat until we know the user is in the chat
      _setUpMessagesListener(chat.id);
    }
  }

  Future<void> _onSend(MessagesSendEvent event, Emitter<MessagesState> emit) async {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      if (currentState.currentMessage.isNotEmpty) {
        if (currentState.messages.firstOrNull?.text ==
                currentState.currentMessage &&
            currentState.messages.firstOrNull?.createdById ==
                currentState.myUser.id) {
          //We don't allow spamming the same message
          emit(MessageNoSpammingState(
              currentState.messages,
              currentState.myUser,
              '',
              currentState.bannerAd,
              currentState.privateChat,
              currentState.usersInRoom,
              null));
        } else {
          await _firestoreRepository.postMessage(
            chatId: chat.id,
            user: currentState.myUser,
            chatType: ChatType.message,
            message: currentState.currentMessage,
            isPrivateChat: isPrivateChat,
            replyMessage: currentState.replyMessage,
            sendPushToUserId: (chat is PrivateChat
                ? (chat as PrivateChat)
                    .users
                    .where((element) => element != getUserId())
                    .firstOrNull
                : null),
          );
          emit(getBaseState(currentState.copyWith(currentMessage: '')));
        }
      }
    }
  }

  void _onChanged(MessagesChangedEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(currentState.copyWith(currentMessage: event.message));
    }
  }

  void _onUpdated(MessagesUpdatedEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
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

      emit(currentState.copyWith(messages: updatedMessages));
      if (currentState.messages.first.id != event.messages.first.id) {
        playMessageSound();
      }
    } else {
      final currentChat = chat;
      emit(MessagesBaseState(event.messages, _user, '', _anchoredAdaptiveAd,
          (currentChat is PrivateChat) ? currentChat : null, const [], null));
    }
  }

  void _onUserUpdated(MessagesUserUpdatedEvent event, Emitter<MessagesState> emit) {
    _user = event.user;
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(currentState.copyWith(myUser: event.user));
    }
  }

  Future<void> _onGiphyPicked(MessagesGiphyPickedEvent event, Emitter<MessagesState> emit) async {
    final currentState = state;
    Log.d("Got giphy event");
    if (currentState is MessagesBaseState) {
      final String giphyUrl = event.gif.images?.downsized?.url ?? "";
      if (currentState.messages.firstOrNull?.text == giphyUrl &&
          currentState.messages.firstOrNull?.createdById ==
              currentState.myUser.id) {
        //We don't allow spamming the same message
        emit(MessageNoSpammingState(
            currentState.messages,
            currentState.myUser,
            '',
            currentState.bannerAd,
            currentState.privateChat,
            currentState.usersInRoom,
            null));
      } else {
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
        emit(currentState.copyWith(currentMessage: ""));
      }
    }
  }

  void _onReportMessage(MessagesReportMessageEvent event, Emitter<MessagesState> emit) {
    _firestoreRepository.reportMessage(event.message);
  }

  void _onBannerAdLoaded(MessagesBannerAdLoadedEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(currentState.copyWith(bannerAd: _anchoredAdaptiveAd));
    }
  }

  void _onPrivateChatsUpdated(MessagesPrivateChatsUpdatedEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(currentState.copyWith(privateChat: event.privateChats));
    }
  }

  void _onTranslate(MessagesTranslateEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      //Replace the message model in the state with the message model in the event and update the state
      final updatedMessages = currentState.messages
          .map((e) => e.id == event.message.id ? event.message : e)
          .toList();
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onMarked(MessagesMarkedEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      //Find the message in the current state messages and update the marked value
      final updatedMessages = currentState.messages
          .map((e) =>
              e.id == event.message.id ? e.copyWith(marked: event.marked) : e)
          .toList();
      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _onChatUsersInRoomUpdated(MessagesChatUsersInRoomUpdatedEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(currentState.copyWith(usersInRoom: event.chatUsers));
    } else {
      final currentChat = chat;
      emit(MessagesBaseState(const [],
          _user,
          '',
          _anchoredAdaptiveAd,
          (currentChat is PrivateChat) ? currentChat : null,
          event.chatUsers,
          null));
    }
  }

  void _onReply(MessagesReplyEvent event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(currentState.copyWith(replyMessage: event.message));
    }
  }

  void _onReplyClear(MessagesReplyEventClear event, Emitter<MessagesState> emit) {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(getBaseState(currentState));
    }
  }

  Future<void> _onGalleryClicked(MessagesGalleryClickedEvent event, Emitter<MessagesState> emit) async {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(MessagesLoadingState());
      if (_user.kvitterCredits > 0 || kIsWeb || _user.isPremiumUser) {
        XFile? pickedFile;
        try {
          pickedFile = await picker.pickImage(
              source: ImageSource.gallery, imageQuality: photoQuality);
        } catch (e) {
          Log.e(e);
          emit(currentState.copyWith(currentMessage: ""));
        }
        if (pickedFile != null) {
          String base64Image = '';
          if (kIsWeb) {
            var imageForWeb = await pickedFile.readAsBytes();
            base64Image = base64Encode(imageForWeb);
          }
          final imageUrl = await _storageRepository.uploadMessageImage(
              pickedFile.path, base64Image);
          final finalUrl = await imageUrl?.getDownloadURL() ?? "";
          await _firestoreRepository.postMessage(
              chatId: chat.id,
              user: currentState.myUser,
              chatType: ChatType.image,
              message: finalUrl,
              isPrivateChat: isPrivateChat,
              sendPushToUserId: (chat is PrivateChat
                  ? (chat as PrivateChat)
                      .users
                      .where((element) => element != getUserId())
                      .firstOrNull
                  : null),
              isGiphy: true);
          if (!kIsWeb || _user.isPremiumUser) {
            _firestoreRepository.reduceUserCredits(_user.id, 1);
          }
          emit(currentState.copyWith(currentMessage: ""));
        } else {
          emit(currentState.copyWith(currentMessage: ""));
        }
      } else {
        emit(MessagesShowCreditsOfferState(currentState));
      }
    }
  }

  Future<void> _onCameraClicked(MessagesCameraClickedEvent event, Emitter<MessagesState> emit) async {
    final currentState = state;
    if (currentState is MessagesBaseState) {
      emit(MessagesLoadingState());
      if (_user.kvitterCredits > 0 || kIsWeb || _user.isPremiumUser) {
        final pickedFile = await picker.pickImage(
            maxHeight: 400,
            maxWidth: 400,
            source: ImageSource.camera,
            imageQuality: photoQuality);
        if (pickedFile != null) {
          final imageUrl = await _storageRepository.uploadMessageImage(
              pickedFile.path, '');
          final finalUrl = await imageUrl?.getDownloadURL() ?? "";
          await _firestoreRepository.postMessage(
              chatId: chat.id,
              user: currentState.myUser,
              chatType: ChatType.image,
              message: finalUrl,
              isPrivateChat: isPrivateChat,
              sendPushToUserId: (chat is PrivateChat
                  ? (chat as PrivateChat)
                      .users
                      .where((element) => element != getUserId())
                      .firstOrNull
                  : null),
              isGiphy: true);
          if (!kIsWeb || _user.isPremiumUser) {
            _firestoreRepository.reduceUserCredits(_user.id, 1);
          }
          emit(currentState.copyWith(currentMessage: ""));
        } else {
          emit(currentState.copyWith(currentMessage: ""));
        }
      } else {
        emit(MessagesShowCreditsOfferState(currentState));
      }
    }
  }

  MessagesBaseState getBaseState(MessagesBaseState currentState) {
    return MessagesBaseState(
        currentState.messages,
        currentState.myUser,
        currentState.currentMessage,
        currentState.bannerAd,
        currentState.privateChat,
        currentState.usersInRoom,
        null);
  }

  void _setUpMessagesListener(String chatId) async {
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

  void _setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository.streamUser().listen((event) async {
      if (event.docs.isEmpty) {
        return;
      }

      final Map<String, dynamic> userData =
          event.docs.first.data() as Map<String, dynamic>;

      // Convert Timestamp to int (milliseconds since epoch)
      if (userData.containsKey('lastActive') &&
          userData['lastActive'] is Timestamp) {
        userData['lastActive'] =
            (userData['lastActive'] as Timestamp).millisecondsSinceEpoch;
      }

      final user = ChatUser.fromJson(event.docs.first.id, userData);
      add(MessagesUserUpdatedEvent(user));
    });
  }

  void _setUpPrivateChatStream() async {
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

  void _setUpOnlineUsersListener() {
    onlineUsersStream =
        _firestoreRepository.onlineUsersStream.listen((event) async {
      final filteredUsers = event
          .where((element) => element.currentRoomChatId == chat.id)
          .toList();

      //Sort users with the same country code as my users first
      Log.d('MessagesChatUsersInRoomUpdatedEvent');
      add(MessagesChatUsersInRoomUpdatedEvent(filteredUsers));
    });
  }

  Future<void> loadAd(int adWidth) async {
    if (_user.isPremiumUser) {
      return;
    }
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

  void _setUpChatClickedListener() {
    _chatClickedRepository.listenToChatClicked().listen((event) {
      Log.d('Chat got clicked 1');
      if (event.id == chat.id && messagesStream == null) {
        Log.d('Chat got clicked 2');
        _setUpMessagesListener(chat.id);
      }
    });
  }
}
