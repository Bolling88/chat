import 'package:chat/screens/create_chat/create_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import '../../model/chat.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../message_holder/message_holder_screen.dart';
import '../profile/profile_screen.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_state.dart';

class ChatScreen extends StatelessWidget {
  static const routeName = "/home_screen";

  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          ChatBloc(context.read<FirestoreRepository>()),
      child: const ChatsScreenContent(),
    );
  }
}

class ChatsScreenContent extends StatelessWidget {
  const ChatsScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.main,
          title: Text(
            FlutterI18n.translate(context, "chat"),
            style: const TextStyle(color: AppColors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, ProfileScreen.routeName);
              },
            )
          ],
        ),
        body: BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {},
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatBaseState) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListView(children: <Widget>[getRegularChats(state)]),
                  );
                } else if (state is ChatEmptyState) {
                  return Center(
                    child: Text(FlutterI18n.translate(context, "no_chats")),
                  );
                } else {
                  return const Center(
                    child: AppSpinner(),
                  );
                }
              },
            )));
  }

  ListView getRegularChats(ChatBaseState state) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.chats.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: ListTile(
            title: (state.chats[index].lastMessageReadBy
                    .contains(FirebaseAuth.instance.currentUser!.uid))
                ? Text(
                    (state.chats[index].chatName.isNotEmpty)
                        ? state.chats[index].chatName
                        : state.chats[index].usersText,
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.grey_1,
                        fontWeight: FontWeight.bold),
                  )
                : Text(
                    (state.chats[index].chatName.isNotEmpty)
                        ? state.chats[index].chatName
                        : state.chats[index].usersText,
                    style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.grey_1,
                        fontWeight: FontWeight.bold),
                  ),
            trailing: Text(
              state.chats[index].getLastMessageReadableDate(),
              style: const TextStyle(fontSize: 13, color: AppColors.grey_1),
            ),
            leading: const Icon(Icons.chat),
            subtitle: (state.chats[index].lastMessageReadBy
                    .contains(FirebaseAuth.instance.currentUser!.uid))
                ? Text(
                    state.chats[index].lastMessage,
                    maxLines: 2,
                    style: const TextStyle(
                        color: AppColors.grey_1,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  )
                : Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: const BoxDecoration(
                            color: AppColors.main, shape: BoxShape.circle),
                      ),
                      Expanded(
                        child: Text(
                          state.chats[index].lastMessage,
                          maxLines: 2,
                          style: const TextStyle(
                              color: AppColors.grey_1,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
            onTap: () {
              Navigator.of(context, rootNavigator: true).pushNamed(
                  MessageHolderScreen.routeName,
                  arguments:
                      MessageHolderScreenArguments(chat: state.chats[index]));
            },
          ),
        );
      },
    );
  }

  Widget getLeadingPartyIcon(Chat chat) {
    return ClipOval(
      child: Container(
          width: 48,
          height: 48,
          color: AppColors.main,
          child: Padding(
              padding: const EdgeInsets.all(6),
              child: SvgPicture.asset("assets/svg/party-icon.svg",
                  semanticsLabel: "", color: AppColors.main))),
    );
  }
}
