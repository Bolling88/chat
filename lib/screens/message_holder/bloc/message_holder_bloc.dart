import 'dart:async';
import 'package:chat/model/chat_user.dart';
import 'package:chat/model/private_chat.dart';
import 'package:chat/repository/fcm_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import '../../../model/room_chat.dart';
import '../../../model/user_location.dart';
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

  StreamSubscription<QuerySnapshot>? privateChatStream;
  StreamSubscription<List<ChatUser>>? onlineUsersStream;
  StreamSubscription<QuerySnapshot>? userStream;

  InterstitialAd? _interstitialAd;

  MessageHolderBloc(
      this._firestoreRepository, this._fcmRepository)
      : super(MessageHolderLoadingState()) {
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
    return super.close();
  }

  @override
  Stream<MessageHolderState> mapEventToState(MessageHolderEvent event) async* {
    final currentState = state;
    if (event is MessageHolderInitialEvent) {
      _firestoreRepository.updateCurrentUsersCurrentChatRoom(chatId: '');
      _fcmRepository.setUpPushNotification();
      _setUpUserListener();
      _updateUserLocation();
      if (!kIsWeb) {
        loadInterstitialAd();
      }
      logEvent('started_chatting');
    } else if (event is MessageHolderUserUpdatedEvent) {
      if (currentState is MessageHolderBaseState) {
        yield currentState.copyWith(user: event.user);
      } else if (state is MessageHolderLoadingState) {
        yield MessageHolderBaseState(
            roomChat: null,
            user: event.user,
            onlineUsers: const [],
            privateChats: const [],
            selectedChat: null,
            selectedChatIndex: 0);

        _setUpOnlineUsersListener(event.user.countryCode);
        _setUpPrivateChatsListener(event.user);
        _setUpRateMyApp();
      }
    } else if (event is MessageHolderStartPrivateChatEvent) {
      if (currentState is MessageHolderBaseState) {
        final bool isChatAvailable =
            await _firestoreRepository.isPrivateChatAvailable(event.user.id);
        if (isChatAvailable) {
          await _firestoreRepository.createPrivateChat(
            otherUser: event.user,
            myUser: currentState.user,
            initialMessage: event.message,
          );
          _interstitialAd?.show();
          if (!kIsWeb) {
            loadInterstitialAd();
          }
        } else {
          final privateChat = currentState.privateChats
              .where((element) => element.users.contains(event.user.id))
              .firstOrNull;
          if (privateChat != null) {
            _firestoreRepository.setLastMessageRead(chatId: privateChat.id);
            final int index = currentState.privateChats.indexOf(privateChat);
            yield currentState.copyWith(
                selectedChatIndex: index + 1, selectedChat: privateChat);
          } else {
            Log.e("Private chat not found");
          }
        }
      }
    } else if (event is MessageHolderPrivateChatsUpdatedEvent) {
      if (currentState is MessageHolderBaseState) {
        if (!kIsWeb) updateBadgeCount(event.privateChats);
        if (currentState.privateChats.length != event.privateChats.length) {
          //If the number of chats have changed...
          if (currentState.selectedChatIndex == 0 ||
              currentState.selectedChat == null) {
            //If we are in the group chat or in all chats
            if (event.privateChats.length > currentState.privateChats.length) {
              //And private chats have increased
              if (event.privateChats.last.initiatedBy == getUserId()) {
                //And it was by you, move to that chat
                yield currentState.copyWith(
                    privateChats: event.privateChats,
                    selectedChat: event.privateChats.last,
                    selectedChatIndex: event.privateChats.length);
              } else {
                //else just update the chats and play a sound
                playNewChatSound();
                yield currentState.copyWith(privateChats: event.privateChats);
              }
            } else {
              yield currentState.copyWith(privateChats: event.privateChats);
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
                  yield currentState.copyWith(
                      privateChats: event.privateChats,
                      selectedChat: event.privateChats.last,
                      selectedChatIndex: event.privateChats.length);
                } else {
                  //Someone sent the user a private chat
                  //else just update the chats and play a sound
                  playNewChatSound();
                  yield currentState.copyWith(privateChats: event.privateChats);
                }
              } else {
                //else just update the chats
                yield currentState.copyWith(privateChats: event.privateChats);
              }
            } else {
              //A private chat is new or have been removed
              if (event.privateChats.length >
                  currentState.privateChats.length) {
                if (event.privateChats.last.initiatedBy == getUserId()) {
                  //And it was by you, move to that chat
                  yield currentState.copyWith(
                      privateChats: event.privateChats,
                      selectedChat: event.privateChats.last,
                      selectedChatIndex: event.privateChats.length);
                } else {
                  //else just update the chats and play a sound
                  playNewChatSound();
                  yield currentState.copyWith(privateChats: event.privateChats);
                }
              } else {
                if (currentState.roomChat != null) {
                  yield currentState.copyWith(
                      privateChats: event.privateChats,
                      selectedChatIndex: 0,
                      roomChat: currentState.roomChat
                          ?.copyWith(lastMessageReadByUser: true),
                      selectedChat: currentState.roomChat
                          ?.copyWith(lastMessageReadByUser: true));
                } else {
                  yield MessageHolderBaseState(
                      roomChat: null,
                      user: currentState.user,
                      onlineUsers: currentState.onlineUsers,
                      privateChats: event.privateChats,
                      selectedChat: null,
                      selectedChatIndex: 0);
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
          yield currentState.copyWith(privateChats: event.privateChats);
        }
      }
    } else if (event is MessageHolderRoomChatUpdatedEvent) {
      if (currentState is MessageHolderBaseState) {
        if (currentState.selectedChat?.id == event.chat.id) {
          yield currentState.copyWith(
              roomChat: event.chat.copyWith(lastMessageReadByUser: true));
        } else {
          yield currentState.copyWith(roomChat: event.chat);
        }
      }
    } else if (event is MessageHolderChatClickedEvent) {
      if (currentState is MessageHolderBaseState) {
        if (event.chat is RoomChat) {
          final RoomChat chat =
              (event.chat as RoomChat).copyWith(lastMessageReadByUser: true);
          //Set user current chat and mark as present
          _firestoreRepository.updateCurrentUsersCurrentChatRoom(
              chatId: chat.id);
          yield currentState.copyWith(
              selectedChatIndex: 0, selectedChat: chat, roomChat: chat);
        } else if (event.chat is PrivateChat) {
          _firestoreRepository.setLastMessageRead(chatId: event.chat!.id);
          yield currentState.copyWith(
              selectedChatIndex: event.index, selectedChat: event.chat);
        } else {
          yield MessageHolderBaseState(
              roomChat: null,
              user: currentState.user,
              onlineUsers: currentState.onlineUsers,
              privateChats: currentState.privateChats,
              selectedChat: null,
              selectedChatIndex: 0);
        }
      }
    } else if (event is MessageHolderClosePrivateChatEvent) {
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
    } else if (event is MessageHolderChangeChatRoomEvent) {
      if (currentState is MessageHolderBaseState) {
        _firestoreRepository.updateCurrentUsersCurrentChatRoom(chatId: '');
        yield MessageHolderBaseState(
            roomChat: null,
            user: currentState.user,
            onlineUsers: currentState.onlineUsers,
            privateChats: currentState.privateChats,
            selectedChat: null,
            selectedChatIndex: 0);
      }
    } else if (event is MessageHolderUsersUpdatedEvent) {
      if (currentState is MessageHolderBaseState) {
        yield currentState.copyWith(onlineUsers: event.users);
      }
    } else if (event is MessageHolderShowRateDialogEvent) {
      if (currentState is MessageHolderBaseState) {
        yield MessageHolderLikeDialogState(currentState);
      }
    } else if (event is MessageHolderRateNeverAppEvent) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('rated', true);
    } else if (event is MessageHolderShowOnlineUsersInChatEvent) {
      if (currentState is MessageHolderBaseState) {
        yield MessageHolderShowOnlineUsersInChatState(currentState, event.chat);
        yield currentState; //This is to make sure the state is not changed
      }
    } else {
      throw UnimplementedError();
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
      FlutterAppBadger.removeBadge();
    } else {
      FlutterAppBadger.updateBadgeCount(count);
    }
  }

  void _setUpRateMyApp() async {
    if (!kIsWeb) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final int appOpens = prefs.getInt('app_opens') ?? 0;
      final bool hasRatedOrDenied = prefs.getBool('rated') ?? false;
      final opens = appOpens + 1;
      if (appOpens % 5 == 0 && hasRatedOrDenied == false) {
        final InAppReview inAppReview = InAppReview.instance;
        final isInAppReviewAvailable = await inAppReview.isAvailable();
        if (isInAppReviewAvailable) {
          add(MessageHolderShowRateDialogEvent());
        }
      } else {
        prefs.setInt('app_opens', opens);
      }
    }
  }

  void loadInterstitialAd() {
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
