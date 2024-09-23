import 'package:chat/screens/message_holder/bloc/message_holder_bloc.dart';
import 'package:chat/screens/message_holder/bloc/message_holder_event.dart';
import 'package:chat/utils/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/chat_user.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/flag.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_state.dart';

class ChatScreen extends StatelessWidget {
  final List<ChatUser> _initialUsers;

  const ChatScreen(this._initialUsers, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          ChatBloc(context.read<FirestoreRepository>(), _initialUsers),
      child: const ChatsScreenContent(),
    );
  }
}

class ChatsScreenContent extends StatelessWidget {
  const ChatsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {},
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatBaseState) {
                  return getSmallView(state);
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

  ListView getSmallView(ChatBaseState state) {
    return ListView(children: <Widget>[getRegularChats(state)]);
  }

  ListView getRegularChats(ChatBaseState state) {
    return ListView.separated(
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      key: const PageStorageKey('ChatList'),
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
        BlocProvider.of<MessageHolderBloc>(context)
            .add(MessageHolderChatClickedEvent(index, state.chats[index]));
      },
      child: Row(
        children: [
          (state.chats[index].countryCode == 'all')
              ? Transform.translate(
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
                )
              : SizedBox(
                  width: 70,
                  height: 70,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: getFlag(
                          countryCode: state.chats[index].countryCode,
                          fontSize: 40),
                    ),
                  ),
                ),
          const SizedBox(width: 25),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.chats[index].chatName,
                  style: Theme.of(context).textTheme.displaySmall?.merge(
                        TextStyle(
                            color: Color(state.chats[index].chatColor),
                            fontSize: 30),
                      )),
              const SizedBox(height: 5),
              Text(state.chats[index].getInfoText(context),
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.merge(
                        const TextStyle(overflow: TextOverflow.ellipsis),
                      ))
            ],
          )),
          Text(
            state.onlineUsers.containsKey(state.chats[index].id)
                ? state.onlineUsers[state.chats[index].id]?.length.toString() ??
                    '0'
                : '0',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Icon(
            Icons.person,
            color: (state.onlineUsers[state.chats[index].id]?.length ?? 0) > 0
                ? context.main
                : context.textColor,
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}
