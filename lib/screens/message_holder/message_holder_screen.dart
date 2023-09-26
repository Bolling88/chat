import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/chat.dart';
import '../../model/chat_user.dart';
import '../../model/room_chat.dart';
import '../../repository/presence_database.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/constants.dart';
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
  static const routeName = "/message_holder_screen";

  const MessageHolderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<PresenceDatabase>().updateUserPresence();
    return BlocProvider(
      create: (BuildContext context) =>
          MessageHolderBloc(context.read<FirestoreRepository>()),
      child: const MessageHolderScreenContent(),
    );
  }
}

class MessageHolderScreenContent extends StatelessWidget {
  const MessageHolderScreenContent({Key? key}) : super(key: key);

  Future<bool> _onWillPop(blocContext) async {
    return await showDialog(
      context: blocContext,
      builder: (context) => AlertDialog(
        title: Text(FlutterI18n.translate(context, 'exit_chat_title')),
        content: Text(FlutterI18n.translate(context, 'exit_chat_message')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(FlutterI18n.translate(context, 'no')),
          ),
          TextButton(
            onPressed: () {
              return Navigator.of(context).pop(true);
            },
            child: Text(FlutterI18n.translate(context, 'yes')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageHolderBloc, MessageHolderState>(
        listener: (context, state) {},
        child: BlocBuilder<MessageHolderBloc, MessageHolderState>(
          builder: (context, state) {
            if (state is MessageHolderBaseState) {
              return WillPopScope(
                onWillPop: () => state.privateChats.isNotEmpty
                    ? _onWillPop(context)
                    : Future.value(true),
                child: Scaffold(
                    appBar: getAppBar(context, state, state.selectedChat),
                    body: LayoutBuilder(
                        builder: (BuildContext context,
                                BoxConstraints constraints) =>
                            constraints.maxWidth >
                                    (state.privateChats.isEmpty ? 855 : 970)
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
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(
          width: 350,
          child: PeopleScreen(
              chat: state.roomChat, user: state.user, parentContext: context)),
      if (state.privateChats.isEmpty)
        const VerticalDivider(
          width: 5,
        ),
      state.privateChats.isNotEmpty
          ? getSideMenu(state, context)
          : const SizedBox.shrink(),
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        child: Material(
          elevation: 0,
          child: IndexedStack(
              index: state.selectedChatIndex, children: getChatViews(state)),
        ),
      ),
      Expanded(child: getBrandNameView(context)),
    ]);
  }

  Row smallScreenContent(MessageHolderBaseState state, BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      state.privateChats.isNotEmpty
          ? getSideMenu(state, context)
          : const SizedBox.shrink(),
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
      width: getSize(context) == ScreenSize.large ? 120 : 60,
      child: ListView.builder(
          itemCount: state.privateChats.length + 1,
          itemBuilder: (context, index) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  BlocProvider.of<MessageHolderBloc>(context).add(
                      MessageHolderChatClickedEvent(
                          index,
                          (index == 0)
                              ? state.roomChat
                              : state.privateChats[index - 1]));
                },
                child: getSize(context) == ScreenSize.large
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (index != 0)
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
                      )
                    : getCard(state, index, context),
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
            ? AppColors.background
            : (index == 0)
                ? (state.roomChat?.lastMessageReadByUser == true ||
                        state.roomChat == null)
                    ? AppColors.grey_5
                    : AppColors.main
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
                : Center(
                    child: Text(
                      state.privateChats[index - 1]
                          .getChatName(FirebaseAuth.instance.currentUser!.uid),
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
              ? const ChatScreen()
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
        child: Text(
          (chat?.getChatName(FirebaseAuth.instance.currentUser!.uid) ?? '')
                  .isNotEmpty
              ? chat!.getChatName(FirebaseAuth.instance.currentUser!.uid)
              : FlutterI18n.translate(context, "chat_rooms"),
        ),
      ),
      backgroundColor: chat != null && chat is RoomChat
          ? Color(chat.chatColor)
          : AppColors.main,
      actions: [
        MediaQuery.of(context).size.width > (state.privateChats.isEmpty ? 855 : 970)
              ? const SizedBox.shrink()
              : Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      showPeopleScreen(context, state.roomChat, state.user);
                    },
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: Row(
                        children: [
                          Text(
                            state.onlineUsers.length.toString(),
                            style: Theme.of(context).textTheme.bodyLarge?.merge(
                                const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.people,
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
            Navigator.pushNamed(context, ProfileScreen.routeName);
          },
        )
      ],
    );
  }
}
