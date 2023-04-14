import 'package:chat/screens/create_chat/create_chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_svg/svg.dart';
import '../../model/chat.dart';
import '../../model/chat_user.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../message_holder/message_holder_screen.dart';
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
          elevation: 0,
          title: Text(
            FlutterI18n.translate(context, "chat"),
            style: const TextStyle(
                color: AppColors.grey_1,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                showCreateChatScreen(context);
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
            leading: getLeadingIcon(state.chats[index]),
            subtitle: (state.chats[index].lastMessageReadBy
                    .contains(FirebaseAuth.instance.currentUser!.uid))
                ? Text(
                    _getLastMessage(
                        state.chats[index],
                        state.users[state.chats[index].lastMessageUserId],
                        context),
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
                          _getLastMessage(
                              state.chats[index],
                              state.users[state.chats[index].lastMessageUserId],
                              context),
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

  Widget getLeadingIcon(Chat chat) {
    if (chat.users.length > 2) {
      return SizedBox(
        width: 50,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: AppUserImage(chat.userInfos[0].pictureData, size: 36),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: AppUserImage(
                    chat.userInfos[1].pictureData,
                    size: 36,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    } else if (chat.userInfos.isNotEmpty) {
      return AppUserImage(chat.userInfos[0].pictureData);
    } else {
      return const SizedBox(
        width: 10,
        height: 10,
      );
    }
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

  String _getLastMessage(Chat chat, ChatUser? user, BuildContext context) {
    if (chat.lastMessageUserId.isEmpty || user == null) {
      return chat.lastMessage;
    } else if (chat.lastMessageUserId ==
        FirebaseAuth.instance.currentUser!.uid) {
      if (chat.lastMessageIsGiphy) {
        return FlutterI18n.translate(context, "giphy_sent");
      } else {
        return "${FlutterI18n.translate(context, "you")}: ${chat.lastMessage}";
      }
    } else {
      if (chat.lastMessageIsGiphy) {
        return "$user ${FlutterI18n.translate(context, "giphy_info")}";
      } else {
        return "$user: ${chat.lastMessage}";
      }
    }
  }
}
