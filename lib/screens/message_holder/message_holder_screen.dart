import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/chat.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../messages/messages_screen.dart';
import 'bloc/message_holder_bloc.dart';
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
                  body: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MessagesScreen(state.chatId)));
            } else {
              return const Scaffold(
                  backgroundColor: AppColors.white,
                  body: Center(child: AppSpinner()));
            }
          },
        ));
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
