import 'package:chat/repository/fcm_repository.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/chat/chat_screen.dart';
import 'package:chat/screens/feedback/feedback_screen.dart';
import 'package:chat/screens/visit/visit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../model/chat.dart';
import '../../model/chat_user.dart';
import '../../model/room_chat.dart';
import '../../repository/presence_database.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../account/account_screen.dart';
import '../messages/messages_screen.dart';
import '../people/people_screen.dart';
import '../profile/profile_screen.dart';
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
          context.read<FirestoreRepository>(), context.read<FcmRepository>()),
      child: const MessageHolderScreenContent(),
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
      }
    }, child: BlocBuilder<MessageHolderBloc, MessageHolderState>(
      builder: (context, state) {
        if (state is MessageHolderBaseState) {
          return WillPopScope(
            onWillPop: () {
              if (state.selectedChat != null && state.selectedChatIndex == 0) {
                BlocProvider.of<MessageHolderBloc>(context)
                    .add(MessageHolderChangeChatRoomEvent());
                return Future.value(false);
              } else if (state.selectedChat != null &&
                  state.selectedChatIndex != 0) {
                BlocProvider.of<MessageHolderBloc>(context)
                    .add(MessageHolderChatClickedEvent(0, state.roomChat));
                return Future.value(false);
              } else if (state.selectedChat == null &&
                  state.selectedChatIndex == 0 &&
                  !kIsWeb) {
                showExitAppDialog(context);
                return Future.value(false);
              }
              return Future.value(true);
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
                chat: state.roomChat,
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
      color: AppColors.main,
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
      color: AppColors.grey_3,
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
                    showPeopleScreen(
                        context, state.roomChat, state.onlineUsers);
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

  Row getLargeScreenCard(
      int index, BuildContext context, MessageHolderBaseState state) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (index != 0 && index != state.privateChats.length + 1)
          IconButton(
            onPressed: () {
              BlocProvider.of<MessageHolderBloc>(context).add(
                  MessageHolderClosePrivateChatEvent(
                      state.privateChats[index - 1]));
            },
            icon: const Icon(
              Icons.close,
              color: AppColors.main,
            ),
          ),
        Expanded(child: getCard(state, index, context))
      ],
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
            ? AppColors.background
            : (index == 0)
                ? (state.roomChat?.lastMessageReadByUser == true ||
                        state.roomChat == null)
                    ? AppColors.grey_5
                    : AppColors.main
                : (index == state.privateChats.length + 1)
                    ? AppColors.main
                    : (state.privateChats[index - 1].lastMessageReadBy
                            .contains(getUserId()))
                        ? AppColors.grey_5
                        : AppColors.main,
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
                                      ? AppColors.main
                                      : AppColors.white,
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
                                        ? AppColors.main
                                        : AppColors.white,
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
          }
        },
        child: Row(
          children: [
            if (chat != null) getChatImage(chat, state.onlineUsers, context),
            if (chat != null) const SizedBox(width: 8),
            if (chat != null) getOnlineStatusWidget(chat, state.onlineUsers),
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
          chat?.getChatColor(FirebaseAuth.instance.currentUser!.uid) ??
              AppColors.main,
      actions: [
        MediaQuery.of(context).size.width >
                (state.privateChats.isEmpty ? 855 : 970)
            ? const SizedBox.shrink()
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    showPeopleScreen(
                        context, state.roomChat, state.onlineUsers);
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
                              const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.person,
                          color: AppColors.white,
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
      return GestureDetector(
          onTap: () {
            showVisitScreen(
                context, chat.getOtherUserId(getUserId()), chat, false);
          },
          child: AppUserImage(
            url: user.pictureData,
            gender: user.gender,
            isApproved: ApprovedImage.fromValue(user.approvedImage),
          ));
    } else {
      return const SizedBox.shrink();
    }
  } else {
    return const SizedBox.shrink();
  }
}

Widget getOnlineStatusWidget(Chat chat, List<ChatUser> onlineUsers) {
  if (chat.isPrivateChat() == true) {
    final user = onlineUsers
        .where((element) => element.id == chat.getOtherUserId(getUserId()))
        .firstOrNull;
    return getOnlineDot(user != null);
  } else {
    return const SizedBox.shrink();
  }
}

Container getOnlineDot(bool isOnline) {
  return Container(
    width: 14,
    height: 14,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.white,
    ),
    child: Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOnline ? AppColors.green : AppColors.grey_1,
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
                  child: Text(FlutterI18n.translate(context, "no"))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    SystemNavigator.pop();
                  },
                  child: Text(FlutterI18n.translate(context, "yes")))
            ],
          ));
}
