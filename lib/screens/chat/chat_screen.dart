import 'package:chat/screens/message_holder/bloc/message_holder_bloc.dart';
import 'package:chat/screens/message_holder/bloc/message_holder_event.dart';
import 'package:chat/utils/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../repository/firestore_repository.dart';
import '../../repository/presence_database.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/constants.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_state.dart';

class ChatScreen extends StatelessWidget {

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
        body: BlocListener<ChatBloc, ChatState>(
            listener: (context, state) {},
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatBaseState) {
                  if (getSize(context) == ScreenSize.large) {
                    return Row(
                      children: [
                        Expanded(child: getSmallView(state)),
                        Expanded(child: getLargeView(context)),
                      ],
                    );
                  } else {
                    return getSmallView(state);
                  }
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

  Container getLargeView(BuildContext context) {
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

  ListView getSmallView(ChatBaseState state) {
    return ListView(children: <Widget>[getRegularChats(state)]);
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
        BlocProvider.of<MessageHolderBloc>(context)
            .add(MessageHolderChatClickedEvent(index, state.chats[index]));
      },
      child: Row(
        children: [
          Transform.translate(
            offset:
                Offset(state.chats[index].imageTranslationX.toDouble(), 0.0),
            child: SizedBox(
                width: 70,
                height: 70,
                child: OverflowBox(
                    minHeight: state.chats[index].imageOverflow.toDouble(),
                    maxHeight: state.chats[index].imageOverflow.toDouble(),
                    child: AppLottie(url: state.chats[index].imageUrl))),
          ),
          const SizedBox(width: 40),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.chats[index].chatName,
                  style: Theme.of(context).textTheme.displaySmall?.merge(
                        TextStyle(color: Color(state.chats[index].chatColor)),
                      )),
              const SizedBox(height: 5),
              Text(
                  '${state.chats[index].lastMessageByName}: ${state.chats[index].lastMessage}',
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall?.merge(
                        const TextStyle(
                            color: AppColors.grey_6,
                            overflow: TextOverflow.ellipsis),
                      ))
            ],
          )),
          Text(
            state.chats[index].users.length.toString(),
            style: Theme.of(context).textTheme.bodySmall,
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
