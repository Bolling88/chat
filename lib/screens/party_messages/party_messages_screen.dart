import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/chat.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../messages/messages_screen.dart';
import 'bloc/party_messages_bloc.dart';
import 'bloc/party_messages_state.dart';

class PartyMessageScreenArguments {
  final Chat? chat;
  final String? chatId;

  const PartyMessageScreenArguments({this.chat, this.chatId});
}

class PartyMessagesScreen extends StatelessWidget {
  static const routeName = "/party_messages_screen";

  const PartyMessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PartyMessageScreenArguments args = ModalRoute.of(context)
        ?.settings
        .arguments as PartyMessageScreenArguments;
    return BlocProvider(
      create: (BuildContext context) => PartyMessagesBloc(
          context.read<FirestoreRepository>(), args.chat, args.chatId),
      child: const PartyScreenContent(),
    );
  }
}

class PartyScreenContent extends StatelessWidget {
  const PartyScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PartyMessagesBloc, PartyMessagesState>(
        listener: (context, state) {},
        child: BlocBuilder<PartyMessagesBloc, PartyMessagesState>(
          builder: (context, state) {
            if (state is PartyMessagesBaseState) {
              return Scaffold(
                  backgroundColor: AppColors.white,
                  appBar: getAppBar(context, state),
                  body: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: MessagesScreen(state.chatId)));
            } else {
              return Scaffold(
                  backgroundColor: AppColors.white,
                  body: Center(child: AppSpinner()));
            }
          },
        ));
  }

  AppBar getAppBar(BuildContext context, PartyMessagesBaseState state) {
    return AppBar(
      elevation: 0,
      iconTheme: const IconThemeData(
        color: AppColors.black, //change your color here
      ),
      backgroundColor: AppColors.white,
      title: Text(
        state.chat.getPartyChatName(context),
        style: TextStyle(
            color: AppColors.grey_1, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}
