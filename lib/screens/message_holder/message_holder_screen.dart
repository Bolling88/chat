import 'package:chat/repository/chat_clicked_repository.dart';
import 'package:chat/repository/fcm_repository.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/repository/subscription_repository.dart';
import 'package:chat/screens/chat/chat_screen.dart';
import 'package:chat/screens/feedback/feedback_screen.dart';
import 'package:chat/screens/visit/visit_screen.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../model/chat.dart';
import '../../model/chat_user.dart';
import '../../model/private_chat.dart';
import '../../model/room_chat.dart';
import '../../repository/presence_database.dart';
import '../../utils/app_widgets.dart';
import '../account/account_screen.dart';
import '../app_life_cycle/app_life_cycle_screen.dart';
import '../messages/messages_screen.dart';
import '../people/people_screen.dart';
import 'bloc/message_holder_bloc.dart';
import 'bloc/message_holder_event.dart';
import 'bloc/message_holder_state.dart';

class MessageHolderScreenArguments {
  final RoomChat chat;
  final ChatUser user;

  const MessageHolderScreenArguments({required this.chat, required this.user});
}

class MessageHolderScreen extends StatelessWidget {
  static const routeName = "/chat_home";

  const MessageHolderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<PresenceDatabase>().updateUserPresence();
    return BlocProvider(
      create: (BuildContext context) => MessageHolderBloc(
          context.read<FirestoreRepository>(),
          context.read<FcmRepository>(),
          context.read<ChatClickedRepository>(),
          context.read<SubscriptionRepository>()),
      child: const AppLifecycleScreen(child: MessageHolderScreenContent()),
    );
  }
}

class MessageHolderScreenContent extends StatelessWidget {
  const MessageHolderScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageHolderBloc, MessageHolderState>(
        listener: (context, state) {
      if (state is MessageHolderLikeDialogState) {
        showLikeDialog(context, state);
      } else if (state is MessageHolderShowOnlineUsersInChatState) {
        showPeopleScreen(context, state.chat, state.onlineUsers);
      }
    }, child: BlocBuilder<MessageHolderBloc, MessageHolderState>(
      builder: (context, state) {
        if (state is MessageHolderBaseState) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
              if (state.selectedChat != null && state.selectedChatIndex == 0) {
                BlocProvider.of<MessageHolderBloc>(context)
                    .add(MessageHolderChangeChatRoomEvent());
              } else if (state.selectedChat != null &&
                  state.selectedChatIndex != 0) {
                BlocProvider.of<MessageHolderBloc>(context)
                    .add(MessageHolderChatClickedEvent(0, state.roomChat));
              } else if (state.selectedChat == null &&
                  state.selectedChatIndex == 0 &&
                  !kIsWeb) {
                showExitAppDialog(context);
              }
            },
            child: Scaffold(
                key: const Key("message_holder_screen"),
                appBar: getAppBar(context, state, state.selectedChat),
                body: LayoutBuilder(
                    key: const Key("message_holder_screen_layout_builder"),
                    builder:
                        (BuildContext context, BoxConstraints constraints) =>
                            constraints.maxWidth > 855
                                ? largeScreenContent(state, context)
                                : smallScreenContent(state, context))),
          );
        } else {
          return const Scaffold(body: Center(child: AppSpinner()));
        }
      },
    ));
  }

  Row largeScreenContent(MessageHolderBaseState state, BuildContext context) {
    return Row(
        key: const Key("message_holder_screen_row"),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              key: const Key("message_holder_screen_sized_box"),
              width: 350,
              child: PeopleScreen(
                key: const Key("message_holder_screen_people_screen"),
                chat: null,
                parentContext: context,
                users: null,
              )),
          getSideMenu(state, context),
          Expanded(
            flex: 3,
            child: Material(
              elevation: 0,
              child: IndexedStack(
                  index: state.selectedChatIndex,
                  children: getChatViews(state)),
            ),
          ),
          if (MediaQuery.of(context).size.width > 1150)
            Expanded(flex: 2, child: getBrandNameView(context))
        ]);
  }

  Row smallScreenContent(MessageHolderBaseState state, BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      getSideMenu(state, context),
      Expanded(
          child: Material(
        elevation: 0,
        child: IndexedStack(
            index: state.selectedChatIndex, children: getChatViews(state)),
      )),
    ]);
  }

  Container getBrandNameView(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: context.main,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FlutterI18n.translate(context, "app_name"),
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.merge(const TextStyle(color: Colors.white)),
            ),
            Text(
              FlutterI18n.translate(context, "chat_rooms"),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.merge(const TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget getSideMenu(MessageHolderBaseState state, BuildContext context) {
    return Container(
      color: context.grey_3,
      width: 60,
      child: ListView.builder(
          itemCount: state.privateChats.length + 2,
          itemBuilder: (context, index) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  //Close keyboard
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (index == state.privateChats.length + 1) {
                    showPeopleScreen(context, null, state.onlineUsers);
                    return;
                  }
                  HapticFeedback.heavyImpact();
                  BlocProvider.of<MessageHolderBloc>(context).add(
                      MessageHolderChatClickedEvent(
                          index,
                          (index == 0)
                              ? state.roomChat
                              : state.privateChats[index - 1]));
                },
                child: getCard(state, index, context),
              ),
            );
          }),
    );
  }

  Widget getCard(
      MessageHolderBaseState state, int index, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
      child: Material(
        type: MaterialType.card,
        elevation: 2,
        color: (state.selectedChatIndex == index)
            ? context.backgroundColor
            : (index == 0)
                ? (state.roomChat?.lastMessageReadByUser == true ||
                        state.roomChat == null)
                    ? context.grey_5
                    : context.main
                : (index == state.privateChats.length + 1)
                    ? context.main
                    : (state.privateChats[index - 1].lastMessageReadBy
                            .contains(getUserId()))
                        ? context.grey_5
                        : context.main,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0))),
        child: Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(5.0)),
            ),
            child: (index == 0)
                ? Center(
                    child: Text(
                        state.roomChat != null
                            ? state.roomChat!.chatName
                            : FlutterI18n.translate(context, "chat_rooms"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.merge(
                              TextStyle(
                                  color: state.selectedChatIndex == index
                                      ? context.main
                                      : context.white,
                                  fontWeight: FontWeight.bold),
                            )),
                  )
                : (index == state.privateChats.length + 1)
                    ? const Center(
                        child: Icon(Icons.add),
                      )
                    : Center(
                        child: Text(
                          state.privateChats[index - 1].getChatName(
                              FirebaseAuth.instance.currentUser!.uid),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.merge(
                                TextStyle(
                                    color: state.selectedChatIndex == index
                                        ? context.main
                                        : context.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        ),
                      )),
      ),
    );
  }

  List<Widget> getChatViews(MessageHolderBaseState state) {
    return {
          state.roomChat == null
              ? ChatScreen(state.onlineUsers)
              : MessagesScreen(
                  state.roomChat as RoomChat,
                  false,
                  key: Key(state.roomChat!.id),
                )
        }.toList() +
        Iterable.generate(state.privateChats.length)
            .map((e) => MessagesScreen(
                  state.privateChats[e],
                  true,
                  key: Key(state.privateChats[e].id),
                ))
            .toList();
  }

  AppBar getAppBar(
      BuildContext context, MessageHolderBaseState state, Chat? chat) {
    return AppBar(
      title: GestureDetector(
        onTap: () {
          if (state.selectedChatIndex == 0) {
            BlocProvider.of<MessageHolderBloc>(context)
                .add(MessageHolderChangeChatRoomEvent());
          } else {
            final PrivateChat privateChat = chat as PrivateChat;
            showVisitScreen(
                context, chat.getOtherUserId(getUserId()), privateChat, false);
          }
        },
        child: Row(
          children: [
            if (chat != null) getChatImage(chat, state.onlineUsers, context),
            if (chat != null) const SizedBox(width: 8),
            if (chat != null)
              getOnlineStatusWidget(chat, state.onlineUsers, context),
            if (chat != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                (chat?.getChatName(FirebaseAuth.instance.currentUser!.uid) ??
                            '')
                        .isNotEmpty
                    ? chat!.getChatName(FirebaseAuth.instance.currentUser!.uid)
                    : FlutterI18n.translate(context, "chat_rooms"),
              ),
            ),
          ],
        ),
      ),
      backgroundColor:
          chat?.getChatColor(FirebaseAuth.instance.currentUser!.uid, context) ??
              context.appBar,
      actions: [
        MediaQuery.of(context).size.width >
                (state.privateChats.isEmpty ? 855 : 970)
            ? const SizedBox.shrink()
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    showPeopleScreen(context, null, state.onlineUsers);
                  },
                  child: SizedBox(
                    height: 60,
                    width: 70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.onlineUsers.length.toString(),
                          style: Theme.of(context).textTheme.bodyLarge?.merge(
                              TextStyle(
                                  color: context.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.person,
                          color: context.white,
                        )
                      ],
                    ),
                  ),
                ),
              ),
        IconButton(
          icon: const Icon(
            Icons.settings,
          ),
          onPressed: () {
            Navigator.pushNamed(context, AccountScreen.routeName);
          },
        )
      ],
    );
  }

  void showLikeDialog(
      BuildContext parentContext, MessageHolderBaseState state) {
    showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
              title: Text(FlutterI18n.translate(context, "like_app_title")),
              content: Text(
                  FlutterI18n.translate(context, "like_app_title_message")),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      BlocProvider.of<MessageHolderBloc>(parentContext)
                          .add(MessageHolderRateNeverAppEvent());
                      showFeedbackScreen(parentContext, state.user);
                    },
                    child: Text(
                        FlutterI18n.translate(context, "no").toUpperCase())),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showRateDialog(parentContext, state);
                    },
                    child: Text(
                        FlutterI18n.translate(context, "yes").toUpperCase()))
              ],
            ));
  }

  void showRateDialog(
      BuildContext parentContext, MessageHolderBaseState state) {
    showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
              title: Text(FlutterI18n.translate(context, "rate_app_title")),
              content: Text(
                  FlutterI18n.translate(context, "rate_app_title_message")),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      BlocProvider.of<MessageHolderBloc>(parentContext)
                          .add(MessageHolderRateNeverAppEvent());
                    },
                    child: Text(
                        FlutterI18n.translate(context, "no").toUpperCase())),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      InAppReview.instance.requestReview();
                      BlocProvider.of<MessageHolderBloc>(parentContext)
                          .add(MessageHolderRateNeverAppEvent());
                    },
                    child: Text(
                        FlutterI18n.translate(context, "yes").toUpperCase())),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      BlocProvider.of<MessageHolderBloc>(parentContext)
                          .add(MessageHolderRateLaterAppEvent());
                    },
                    child: Text(
                        FlutterI18n.translate(context, "later").toUpperCase()))
              ],
            ));
  }
}

Widget getChatImage(
    Chat chat, List<ChatUser> onlineUsers, BuildContext context) {
  if (chat.isPrivateChat() == true) {
    final user = onlineUsers
        .where((element) => element.id == chat.getOtherUserId(getUserId()))
        .firstOrNull;
    if (user != null) {
      return AppUserImage(
        url: user.pictureData,
        gender: user.gender,
        imageReports: user.imageReports,
        approvalState: ApprovedImage.fromValue(user.approvedImage),
      );
    } else {
      final PrivateChat privateChat = chat as PrivateChat;
      final String? imageUrl = privateChat.getChatImage(getUserId());
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return AppUserImage(
          url: imageUrl,
          gender: privateChat.getOtherUserGender(getUserId()),
          imageReports: const [],
          approvalState: ApprovedImage.approved,
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  } else {
    return const SizedBox.shrink();
  }
}

Widget getOnlineStatusWidget(
    Chat chat, List<ChatUser> onlineUsers, BuildContext context) {
  if (chat.isPrivateChat() == true) {
    final user = onlineUsers
        .where((element) => element.id == chat.getOtherUserId(getUserId()))
        .firstOrNull;
    return getOnlineDot(user != null, context);
  } else {
    return const SizedBox.shrink();
  }
}

Container getOnlineDot(bool isOnline, BuildContext context) {
  return Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: context.white,
    ),
    child: Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? context.main : context.textColor,
        ),
      ),
    ),
  );
}

void showExitAppDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text(FlutterI18n.translate(context, "exit_app")),
            content: Text(FlutterI18n.translate(context, "exit_app_message")),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                      Text(FlutterI18n.translate(context, "no").toUpperCase())),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    SystemNavigator.pop();
                  },
                  child:
                      Text(FlutterI18n.translate(context, "yes").toUpperCase()))
            ],
          ));
}
