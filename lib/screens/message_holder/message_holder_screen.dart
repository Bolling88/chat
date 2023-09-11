import 'package:chat/repository/firestore_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/private_chat.dart';
import '../../model/room_chat.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/constants.dart';
import '../messages/messages_screen.dart';
import '../people/people_screen.dart';
import 'bloc/message_holder_bloc.dart';
import 'bloc/message_holder_event.dart';
import 'bloc/message_holder_state.dart';

class MessageHolderScreenArguments {
  final RoomChat chat;

  const MessageHolderScreenArguments({required this.chat});
}

class MessageHolderScreen extends StatelessWidget {
  static const routeName = "/message_holder_screen";

  const MessageHolderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MessageHolderScreenArguments args = ModalRoute.of(context)
        ?.settings
        .arguments as MessageHolderScreenArguments;
    return BlocProvider(
      create: (BuildContext context) =>
          MessageHolderBloc(context.read<FirestoreRepository>(), args.chat),
      child: MessageHolderScreenContent(chat: args.chat),
    );
  }
}

class MessageHolderScreenContent extends StatelessWidget {
  final RoomChat chat;

  const MessageHolderScreenContent({required this.chat, Key? key})
      : super(key: key);

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
              BlocProvider.of<MessageHolderBloc>(blocContext)
                  .add(MessageHolderExitChatEvent());
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
                    appBar: getAppBar(context, state, chat),
                    body: (getSize(context) == ScreenSize.large)
                        ? largeScreenContent(state, context)
                        : smallScreenContent(state)),
              );
            } else {
              return const Scaffold(body: Center(child: AppSpinner()));
            }
          },
        ));
  }

  Row largeScreenContent(MessageHolderBaseState state, BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(
          flex: 1, child: PeopleScreen(chat: chat, parentContext: context)),
      if (state.privateChats.isEmpty) const VerticalDivider(),
      state.privateChats.isNotEmpty
          ? getSideMenu(state)
          : const SizedBox.shrink(),
      Expanded(
          flex: 3,
          child: Material(
            elevation: 0,
            child: IndexedStack(
                index: state.selectedChatIndex, children: getChatViews(state)),
          )),
    ]);
  }

  Row smallScreenContent(MessageHolderBaseState state) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      state.privateChats.isNotEmpty
          ? getSideMenu(state)
          : const SizedBox.shrink(),
      Expanded(
          child: Material(
        elevation: 0,
        child: IndexedStack(
            index: state.selectedChatIndex, children: getChatViews(state)),
      )),
    ]);
  }

  Widget getSideMenu(MessageHolderBaseState state) {
    return Container(
      color: AppColors.grey_3,
      width: 60,
      child: ListView.builder(
          itemCount: state.privateChats.length + 1,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                BlocProvider.of<MessageHolderBloc>(context).add(
                    MessageHolderChatClickedEvent(
                        index,
                        (index == 0)
                            ? state.roomChat
                            : state.privateChats[index - 1]));
              },
              child: Padding(
                padding: (state.selectedChatIndex == index)
                    ? const EdgeInsets.only(left: 4, top: 4, bottom: 4)
                    : const EdgeInsets.all(4),
                child: Material(
                  type: MaterialType.card,
                  elevation: 2,
                  color: (state.selectedChatIndex == index)
                      ? AppColors.background
                      : (index == 0)
                          ? (state.roomChat.lastMessageReadBy
                                  .contains(getUserId()))
                              ? AppColors.grey_5
                              : AppColors.main
                          : (state.privateChats[index - 1].lastMessageReadBy
                                  .contains(getUserId()))
                              ? AppColors.grey_5
                              : AppColors.main,
                  shape: RoundedRectangleBorder(
                      borderRadius: (state.selectedChatIndex == index)
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              bottomLeft: Radius.circular(5.0))
                          : const BorderRadius.all(Radius.circular(5.0))),
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: (index == 0)
                          ? Center(
                              child: Text(state.roomChat.chatName,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.merge(
                                        TextStyle(
                                            color:
                                                state.selectedChatIndex == index
                                                    ? AppColors.grey_1
                                                    : AppColors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                            )
                          : Center(
                              child: Text(
                                state.privateChats[index - 1].getChatName(
                                    FirebaseAuth.instance.currentUser!.uid),
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.merge(
                                      TextStyle(
                                          color:
                                              state.selectedChatIndex == index
                                                  ? AppColors.grey_1
                                                  : AppColors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                              ),
                            )),
                ),
              ),
            );
          }),
    );
  }

  List<Widget> getChatViews(MessageHolderBaseState state) {
    return {
          MessagesScreen(
            state.roomChat,
            false,
            key: Key(state.roomChat.id),
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
      BuildContext context, MessageHolderBaseState state, RoomChat chat) {
    return AppBar(
      title: Text(
        state.selectedChat.getChatName(FirebaseAuth.instance.currentUser!.uid),
      ),
      backgroundColor: Color(chat.chatColor),
      actions: [
        if (getSize(context) == ScreenSize.small)
          if (state.selectedChat is PrivateChat)
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.white,
              ),
              onPressed: () {
                BlocProvider.of<MessageHolderBloc>(context)
                    .add(MessageHolderClosePrivateChatEvent());
              },
            )
          else
            IconButton(
              icon: const Icon(
                Icons.people,
                color: AppColors.white,
              ),
              onPressed: () {
                showPeopleScreen(context, state.roomChat);
              },
            )
      ],
    );
  }
}
