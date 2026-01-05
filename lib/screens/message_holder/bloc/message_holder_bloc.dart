import 'dart:async';
import 'package:chat/model/chat_user.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/repository/fcm_repository.dart';
import 'package:chat/repository/subscription_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:chat/utils/app_badge.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import '../../../model/room_chat.dart';
import '../../../model/user_location.dart';
import '../../../repository/chat_clicked_repository.dart';
import '../../../repository/firestore_repository.dart';
import '../../../repository/network_repository.dart';
import '../../../utils/analytics.dart';
import '../../../utils/audio.dart';
import '../../../utils/log.dart';
import 'message_holder_event.dart';
import 'message_holder_state.dart';
import 'dart:core';

class MessageHolderBloc extends Bloc<MessageHolderEvent, MessageHolderState> {
  final FirestoreRepository _firestoreRepository;
  final FcmRepository _fcmRepository;
  final ChatClickedRepository _chatClickedRepository;
  final SubscriptionRepository _subscriptionRepository;

  StreamSubscription<QuerySnapshot>? privateChatStream;
  StreamSubscription<List<ChatUser>>? onlineUsersStream;
  StreamSubscription<QuerySnapshot>? userStream;

  InterstitialAd? _interstitialAd;
  bool privateChatFirstLoad = true;
  ChatUser? _user;

  MessageHolderBloc(
      this._firestoreRepository, this._fcmRepository, this._chatClickedRepository, this._subscriptionRepository)
      : super(MessageHolderLoadingState()) {
    on<MessageHolderInitialEvent>(_onInitial);
    on<MessageHolderUserUpdatedEvent>(_onUserUpdated);
    on<MessageHolderStartPrivateChatEvent>(_onStartPrivateChat);
    on<MessageHolderPrivateChatsUpdatedEvent>(_onPrivateChatsUpdated);
    on<MessageHolderNewChatAddedEvent>(_onNewChatAdded);
    on<MessageHolderRoomChatUpdatedEvent>(_onRoomChatUpdated);
    on<MessageHolderChatClickedEvent>(_onChatClicked);
    on<MessageHolderClosePrivateChatEvent>(_onClosePrivateChat);
    on<MessageHolderChangeChatRoomEvent>(_onChangeChatRoom);
    on<MessageHolderUsersUpdatedEvent>(_onUsersUpdated);
    on<MessageHolderShowRateDialogEvent>(_onShowRateDialog);
    on<MessageHolderRateNeverAppEvent>(_onRateNeverApp);
    on<MessageHolderRateLaterAppEvent>(_onRateLaterApp);
    on<MessageHolderShowOnlineUsersInChatEvent>(_onShowOnlineUsersInChat);

    add(MessageHolderInitialEvent());
  }

  @override
  Future<void> close() {
    //This will probably not never be called since the app will be fried before the widget tree is unmounted.
    _firestoreRepository.closeOnlineUsersStream();
    _firestoreRepository.closePrivateChatStream();
    privateChatStream?.cancel();
    onlineUsersStream?.cancel();
    userStream?.cancel();
    _chatClickedRepository.close();
    return super.close();
  }

  void _onInitial(MessageHolderInitialEvent event, Emitter<MessageHolderState> emit) {
    _firestoreRepository.updateCurrentUsersCurrentChatRoom(chatId: '');
    _fcmRepository.setUpPushNotification();
    _setUpUserListener();
    _updateUserLocation();
    if (!kIsWeb) {
      loadInterstitialAd();
    }
    _handleSubscription();
    logEvent('started_chatting');
  }

  void _onUserUpdated(MessageHolderUserUpdatedEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    _user = event.user;
    if (currentState is MessageHolderBaseState) {
      emit(currentState.copyWith(user: event.user));
    } else if (state is MessageHolderLoadingState) {
      emit(MessageHolderBaseState(
          roomChat: null,
          user: event.user,
          onlineUsers: const [],
          privateChats: const [],
          selectedChat: null,
          selectedChatIndex: 0));

      _setUpOnlineUsersListener(event.user.countryCode);
      _setUpPrivateChatsListener(event.user);
      _setUpRateMyApp();
    }
  }

  Future<void> _onStartPrivateChat(
      MessageHolderStartPrivateChatEvent event, Emitter<MessageHolderState> emit) async {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      final bool isChatAvailable =
          await _firestoreRepository.isPrivateChatAvailable(event.user.id);
      if (isChatAvailable) {
        await _firestoreRepository.createPrivateChat(
          otherUser: event.user,
          myUser: currentState.user,
          initialMessage: event.message,
        );
        if(_user?.isPremiumUser != true && !kIsWeb) {
          _interstitialAd?.show();
          loadInterstitialAd();
        }
      } else {
        final privateChat = currentState.privateChats
            .where((element) => element.users.contains(event.user.id))
            .firstOrNull;
        if (privateChat != null) {
          _firestoreRepository.setLastMessageRead(chatId: privateChat.id);
          final int index = currentState.privateChats.indexOf(privateChat);
          emit(currentState.copyWith(
              selectedChatIndex: index + 1, selectedChat: privateChat));
        } else {
          Log.e("Private chat not found");
        }
      }
    }
  }

  void _onPrivateChatsUpdated(
      MessageHolderPrivateChatsUpdatedEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      if (!kIsWeb) updateBadgeCount(event.privateChats);
      if (currentState.privateChats.length != event.privateChats.length) {
        //If the number of chats have changed...
        if (currentState.selectedChatIndex == 0 ||
            currentState.selectedChat == null) {
          //If we are in the group chat or in all chats
          if (event.privateChats.length > currentState.privateChats.length) {
            //If the new chat was initiated by the current user, navigate to it
            if (event.privateChats.last.initiatedBy == getUserId()) {
              privateChatFirstLoad = false;
              emit(currentState.copyWith(
                  privateChats: event.privateChats,
                  selectedChat: event.privateChats.last,
                  selectedChatIndex: event.privateChats.length));
              add(MessageHolderNewChatAddedEvent(event.privateChats.last));
            } else if (privateChatFirstLoad) {
              //If this is the initial load, just update the chats
              privateChatFirstLoad = false;
              emit(currentState.copyWith(privateChats: event.privateChats));
            } else {
              //Someone sent the user a private chat, play sound and update
              playNewChatSound();
              emit(currentState.copyWith(privateChats: event.privateChats));
            }
          } else {
            emit(currentState.copyWith(privateChats: event.privateChats));
          }
        } else {
          //We are not in the group chat
          if (event.privateChats.contains(currentState.selectedChat)) {
            //My selected private chat still exists
            setMessageAsRead(event, currentState);
            if (event.privateChats.length >
                currentState.privateChats.length) {
              //The private chats have increased
              if (event.privateChats.last.initiatedBy == getUserId()) {
                //And it was by you, move to that chat
                emit(currentState.copyWith(
                    privateChats: event.privateChats,
                    selectedChat: event.privateChats.last,
                    selectedChatIndex: event.privateChats.length));
              } else {
                //Someone sent the user a private chat
                //else just update the chats and play a sound
                playNewChatSound();
                emit(currentState.copyWith(privateChats: event.privateChats));
              }
            } else {
              //else just update the chats
              emit(currentState.copyWith(privateChats: event.privateChats));
            }
          } else {
            //A private chat is new or have been removed
            if (event.privateChats.length >
                currentState.privateChats.length) {
              if (event.privateChats.last.initiatedBy == getUserId()) {
                //And it was by you, move to that chat
                emit(currentState.copyWith(
                    privateChats: event.privateChats,
                    selectedChat: event.privateChats.last,
                    selectedChatIndex: event.privateChats.length));
              } else {
                //else just update the chats and play a sound
                playNewChatSound();
                emit(currentState.copyWith(privateChats: event.privateChats));
              }
            } else {
              if (currentState.roomChat != null) {
                emit(currentState.copyWith(
                    privateChats: event.privateChats,
                    selectedChatIndex: 0,
                    roomChat: currentState.roomChat
                        ?.copyWith(lastMessageReadByUser: true),
                    selectedChat: currentState.roomChat
                        ?.copyWith(lastMessageReadByUser: true)));
              } else {
                emit(MessageHolderBaseState(
                    roomChat: null,
                    user: currentState.user,
                    onlineUsers: currentState.onlineUsers,
                    privateChats: event.privateChats,
                    selectedChat: null,
                    selectedChatIndex: 0));
              }
            }
          }
        }
      } else {
        //Number of private chats did not change...
        if (currentState.selectedChatIndex != 0) {
          //If we are not in the group chat
          setMessageAsRead(event, currentState);
        }

        // The number of private chats did not change
        emit(currentState.copyWith(privateChats: event.privateChats));
      }
    }
  }

  Future<void> _onNewChatAdded(
      MessageHolderNewChatAddedEvent event, Emitter<MessageHolderState> emit) async {
    final currentState = state;
    if(currentState is MessageHolderBaseState){
      //Wait a second
      await Future.delayed(const Duration(seconds: 1));
      _chatClickedRepository.addChatClicked(event.chat);
    }
  }

  void _onRoomChatUpdated(
      MessageHolderRoomChatUpdatedEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      if (currentState.selectedChat?.id == event.chat.id) {
        emit(currentState.copyWith(
            roomChat: event.chat.copyWith(lastMessageReadByUser: true)));
      } else {
        emit(currentState.copyWith(roomChat: event.chat));
      }
    }
  }

  void _onChatClicked(
      MessageHolderChatClickedEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      final chat = event.chat;
      if (chat is RoomChat) {
        final RoomChat chat =
            (event.chat as RoomChat).copyWith(lastMessageReadByUser: true);
        //Set user current chat and mark as present
        _firestoreRepository.updateCurrentUsersCurrentChatRoom(
            chatId: chat.id);
        emit(currentState.copyWith(
            selectedChatIndex: 0, selectedChat: chat, roomChat: chat));
      } else if (chat is PrivateChat) {
        _firestoreRepository.setLastMessageRead(chatId: chat.id);
        emit(currentState.copyWith(
            selectedChatIndex: event.index, selectedChat: chat));
        _chatClickedRepository.addChatClicked(chat);
      } else {
        emit(MessageHolderBaseState(
            roomChat: null,
            user: currentState.user,
            onlineUsers: currentState.onlineUsers,
            privateChats: currentState.privateChats,
            selectedChat: null,
            selectedChatIndex: 0));
      }
    }
  }

  void _onClosePrivateChat(
      MessageHolderClosePrivateChatEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    Log.d("Closing private chat");
    if (currentState is MessageHolderBaseState) {
      if (event.privateChat != null) {
        //This is called on big screens, and can be called from any other chat
        _firestoreRepository.leavePrivateChat(event.privateChat!);
      } else {
        //This is called from a small screen, and the current chat, so we must move to the room again
        _firestoreRepository
            .leavePrivateChat(currentState.selectedChat as PrivateChat);
      }
    }
  }

  void _onChangeChatRoom(
      MessageHolderChangeChatRoomEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      _firestoreRepository.updateCurrentUsersCurrentChatRoom(chatId: '');
      emit(MessageHolderBaseState(
          roomChat: null,
          user: currentState.user,
          onlineUsers: currentState.onlineUsers,
          privateChats: currentState.privateChats,
          selectedChat: null,
          selectedChatIndex: 0));
    }
  }

  void _onUsersUpdated(
      MessageHolderUsersUpdatedEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      emit(currentState.copyWith(onlineUsers: event.users));
    }
  }

  void _onShowRateDialog(
      MessageHolderShowRateDialogEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      emit(MessageHolderLikeDialogState(currentState));
    }
  }

  Future<void> _onRateNeverApp(
      MessageHolderRateNeverAppEvent event, Emitter<MessageHolderState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rated', true);
  }

  void _onRateLaterApp(
      MessageHolderRateLaterAppEvent event, Emitter<MessageHolderState> emit) {
    //Don't do anything, it will pop up again after 5 visits
  }

  void _onShowOnlineUsersInChat(
      MessageHolderShowOnlineUsersInChatEvent event, Emitter<MessageHolderState> emit) {
    final currentState = state;
    if (currentState is MessageHolderBaseState) {
      emit(MessageHolderShowOnlineUsersInChatState(currentState, event.chat));
      emit(currentState); //This is to make sure the state is not changed
    }
  }

  Future<void> _handleSubscription() async {
    if(!kIsWeb) {
      _subscriptionRepository.setUserId();
      final subscription = await _subscriptionRepository
          .isPremiumUser();
        _firestoreRepository.setUserAsPremium(subscription);
    }
  }

  void setMessageAsRead(MessageHolderPrivateChatsUpdatedEvent event,
      MessageHolderBaseState currentState) {
    //If the private chat the user have still exists
    //Make sure we set the message as read since we are on that chat
    final currentChat = event.privateChats
        .where((element) => element.id == currentState.selectedChat?.id)
        .firstOrNull;
    if (currentChat != null) {
      if (currentState.selectedChat?.lastMessage != currentChat.lastMessage) {
        _firestoreRepository.setLastMessageRead(chatId: currentChat.id);
      }
    }
  }

  void _setUpPrivateChatsListener(ChatUser user) async {
    Log.d('Setting up private chats stream');
    _firestoreRepository.startPrivateChatsStream(user.id);
    privateChatStream =
        _firestoreRepository.getPrivateChatsStream().listen((data) {
      Log.d("Got private chats");
      final chats = data.docs
          .map((e) =>
              PrivateChat.fromJson(e.id, e.data() as Map<String, dynamic>))
          .toList();
      chats.sort((a, b) => a.created.compareTo(b.created));
      Log.d("Chats: ${chats.length}");
      add(MessageHolderPrivateChatsUpdatedEvent(chats));
    });
  }

  void _updateUserLocation() async {
    UserLocation? userLocation = await getUserLocation();
    if (userLocation != null) {
      _firestoreRepository.updateUserLocation(userLocation);
    }
  }

  void _setUpOnlineUsersListener(String countryCode) {
    _firestoreRepository.startOnlineUsersStream(countryCode);
    onlineUsersStream =
        _firestoreRepository.onlineUsersStream.listen((event) async {

      //Sort users with the same country code as my users first
      Log.d('MessageHolderUsersUpdatedEvent');
      add(MessageHolderUsersUpdatedEvent(event));
    });
  }

  void _setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository.streamUser().listen((event) async {
      if (event.docs.isEmpty) return;
      final Map<String, dynamic> userData =
          event.docs.first.data() as Map<String, dynamic>;

      // Convert Timestamp to int (milliseconds since epoch)
      if (userData.containsKey('lastActive') &&
          userData['lastActive'] is Timestamp) {
        userData['lastActive'] =
            (userData['lastActive'] as Timestamp).millisecondsSinceEpoch;
      }

      final user = ChatUser.fromJson(event.docs.first.id, userData);

      if (ApprovedImage.fromValue(user.approvedImage) == ApprovedImage.notSet &&
          user.pictureData.isNotEmpty) {
        _firestoreRepository.updateImageNotReviewedStatus();
      }
      add(MessageHolderUserUpdatedEvent(user));
    });
  }

  void updateBadgeCount(List<PrivateChat> privateChats) {
    int count = 0;
    for (final chat in privateChats) {
      if (chat.lastMessageReadBy.contains(getUserId()) == false) {
        count++;
      }
    }
    if (count == 0) {
      AppBadge.removeBadge();
    } else {
      AppBadge.updateBadgeCount(count);
    }
  }

  void _setUpRateMyApp() async {
    if (!kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int appOpens = prefs.getInt('app_opens') ?? 0;
      final bool hasRatedOrDenied = prefs.getBool('rated') ?? false;

      // Increment the app opens counter here
      appOpens += 1;
      // Always save the incremented value of app opens
      await prefs.setInt('app_opens', appOpens);

      // Check if it's the right time to show the rate dialog
      if (appOpens % 3 == 0 && !hasRatedOrDenied) {
        final InAppReview inAppReview = InAppReview.instance;
        final isInAppReviewAvailable = await inAppReview.isAvailable();
        if (isInAppReviewAvailable) {
          add(MessageHolderShowRateDialogEvent());
        }
      }
    }
  }

  void loadInterstitialAd() {
    if(_user?.isPremiumUser == true || kIsWeb){
      return;
    }
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? kDebugMode
                ? 'ca-app-pub-3940256099942544/1033173712'
                : 'ca-app-pub-5287847424239288/8506220561'
            : kDebugMode
                ? 'ca-app-pub-3940256099942544/4411468910'
                : 'ca-app-pub-5287847424239288/9174975419',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }
}
