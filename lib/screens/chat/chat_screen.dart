import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/utils/translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
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
    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.chats.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return getListTile(state, index, context);
      },
      separatorBuilder: (BuildContext context, int index) {
        return const Divider();
      },
    );
  }

  ListTile getListTile(ChatBaseState state, int index, BuildContext context) {
    return ListTile(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            state.chats[index].users.length.toString(),
            style: const TextStyle(fontSize: 13, color: AppColors.grey_1),
          ),
          const Icon(Icons.person)
        ],
      ),
      leading: CachedNetworkImage(
        imageUrl: state.chats[index].imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
          ),
        ),
        placeholder: (context, url) => const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: AppSpinner(),
          ),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
      subtitle: Text(
        '${state.chats[index].lastMessageByName}: ${state.chats[index].lastMessage}',
        maxLines: 2,
        style: const TextStyle(
            color: AppColors.grey_1,
            fontSize: 13,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed(
            MessageHolderScreen.routeName,
            arguments: MessageHolderScreenArguments(chat: state.chats[index]));
      },
    );
  }
}
