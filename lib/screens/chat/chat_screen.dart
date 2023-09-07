import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/utils/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../repository/firestore_repository.dart';
import '../../repository/presence_database.dart';
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
    context.read<PresenceDatabase>().updateUserPresence();
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
        appBar: AppBar(
          title: Text(
            FlutterI18n.translate(context, "chat_rooms"),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.settings,
              ),
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

  Widget getListTile(ChatBaseState state, int index, BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed(
            MessageHolderScreen.routeName,
            arguments: MessageHolderScreenArguments(chat: state.chats[index]));
      },
      child: Row(
        children: [
          state.chats[index].countryCode.isNotEmpty
              ? SizedBox(
                width: 70,
                height: 70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: CachedNetworkImage(
                    imageUrl: state.chats[index].imageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape:BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => const SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: AppSpinner(),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error_outline),
                  ),
                ),
              )
              : Transform.translate(
                  offset: Offset(
                      state.chats[index].imageTranslationX.toDouble(), 0.0),
                  child: SizedBox(
                      width: 70,
                      height: 70,
                      child: OverflowBox(
                          minHeight:
                              state.chats[index].imageOverflow.toDouble(),
                          maxHeight:
                              state.chats[index].imageOverflow.toDouble(),
                          child: AppLottie(url: state.chats[index].imageUrl))),
                ),
          const SizedBox(width: 40),
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (state.chats[index].lastMessageReadBy
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
              Text(
                '${state.chats[index].lastMessageByName}: ${state.chats[index].lastMessage}',
                maxLines: 2,
                style: const TextStyle(
                    color: AppColors.grey_1,
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis),
              )
            ],
          )),
          Text(
            state.chats[index].users.length.toString(),
            style: const TextStyle(fontSize: 14, color: AppColors.grey_1),
          ),
          Icon(
            Icons.person,
            color: state.chats[index].users.isNotEmpty
                ? AppColors.main
                : AppColors.grey_1,
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
