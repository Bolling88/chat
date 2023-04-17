import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/chat.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../messages/messages_screen.dart';
import 'bloc/message_holder_bloc.dart';
import 'bloc/message_holder_event.dart';
import 'bloc/message_holder_state.dart';

class MessageHolderScreenArguments {
  final Chat? chat;
  final String? chatId;

  const MessageHolderScreenArguments({this.chat, this.chatId});
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
      create: (BuildContext context) => MessageHolderBloc(
          context.read<FirestoreRepository>(), args.chat, args.chatId),
      child: const MessageHolderScreenContent(),
    );
  }
}

class MessageHolderScreenContent extends StatelessWidget {
  const MessageHolderScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessageHolderBloc, MessageHolderState>(
        listener: (context, state) {},
        child: BlocBuilder<MessageHolderBloc, MessageHolderState>(
          builder: (context, state) {
            if (state is MessageHolderBaseState) {
              return Scaffold(
                  backgroundColor: AppColors.white,
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
                      ]));
            } else {
              return const Scaffold(
                  backgroundColor: AppColors.white,
                  body: Center(child: AppSpinner()));
            }
          },
        ));
  }

  Widget getSideMenu(MessageHolderBaseState state) {
    return SizedBox(
      width: 60,
      child: ListView.builder(
          itemCount: state.privateChats.length + 1,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                BlocProvider.of<MessageHolderBloc>(context)
                    .add(MessageHolderChatClickedEvent(index));
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.main,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Stack(
                      children: [
                        (index == 0)
                            ? (state.chat.lastMessageReadBy
                                    .contains(getUserId()))
                                ? const SizedBox()
                                : Container(
                                    color: AppColors.main,
                                    width: 10,
                                    height: 10,
                                  )
                            : (state.privateChats[index - 1].lastMessageReadBy
                                    .contains(getUserId()))
                                ? const SizedBox()
                                : Container(
                                    color: AppColors.main,
                                    width: 10,
                                    height: 10,
                                  ),
                        (index == 0)
                            ? Text(state.chat.chatName)
                            : Text(state.privateChats[index - 1].chatName)
                      ],
                    )),
              ),
            );
          }),
    );
  }

  List<Widget> getChatViews(MessageHolderBaseState state) {
    return {
          MessagesScreen(
            state.chat.id,
            false,
            key: Key(state.chat.id),
          )
        }.toList() +
        Iterable.generate(state.privateChats.length)
            .map((e) => MessagesScreen(
                  state.privateChats[e].id,
                  true,
                  key: Key(state.privateChats[e].id),
                ))
            .toList();
  }

  AppBar getAppBar(BuildContext context, MessageHolderBaseState state) {
    return AppBar(
      elevation: 0,
      iconTheme: const IconThemeData(
        color: AppColors.black, //change your color here
      ),
      backgroundColor: AppColors.white,
      title: Text(
        state.chat.getPartyChatName(context),
        style: const TextStyle(
            color: AppColors.grey_1, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}
