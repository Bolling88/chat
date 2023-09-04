import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/chat.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../messages/messages_screen.dart';
import '../people/people_screen.dart';
import 'bloc/message_holder_bloc.dart';
import 'bloc/message_holder_event.dart';
import 'bloc/message_holder_state.dart';

class MessageHolderScreenArguments {
  final Chat chat;

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
                    appBar: getAppBar(context, state),
                    body: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          state.privateChats.isNotEmpty
                              ? getSideMenu(state)
                              : const SizedBox.shrink(),
                          Expanded(
                              child: IndexedStack(
                                  index: state.selectedChatIndex,
                                  children: getChatViews(state))),
                        ])),
              );
            } else {
              return const Scaffold(
                  backgroundColor: AppColors.white,
                  body: Center(child: AppSpinner()));
            }
          },
        ));
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
                            ? state.chat
                            : state.privateChats[index - 1]));
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Material(
                  type: MaterialType.card,
                  elevation: (state.selectedChatIndex == index) ? 0 : 4,
                  color: (state.selectedChatIndex == index)
                      ? AppColors.main_2
                      : (index == 0)
                          ? (state.chat.lastMessageReadBy.contains(getUserId()))
                              ? AppColors.grey_2
                              : AppColors.main
                          : (state.privateChats[index - 1].lastMessageReadBy
                                  .contains(getUserId()))
                              ? AppColors.grey_2
                              : AppColors.main,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: (index == 0)
                          ? Text(
                              state.chat.chatName,
                              style: const TextStyle(color: AppColors.white),
                            )
                          : Text(
                              state.privateChats[index - 1].chatName,
                              style: const TextStyle(color: AppColors.white),
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
            state.chat,
            false,
            key: Key(state.chat.id),
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

  AppBar getAppBar(BuildContext context, MessageHolderBaseState state) {
    return AppBar(
      title: Text(
        state.selectedChat.chatName,
        style: const TextStyle(color: AppColors.white),
      ),
      actions: [
        (state.selectedChatIndex == 0)
            ? IconButton(
                icon: const Icon(
                  Icons.people,
                  color: AppColors.white,
                ),
                onPressed: () {
                  showPeopleScreen(context, state.chat);
                },
              )
            : IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.white,
                ),
                onPressed: () {
                  BlocProvider.of<MessageHolderBloc>(context)
                      .add(MessageHolderClosePrivateChatEvent());
                },
              ),
      ],
    );
  }
}
