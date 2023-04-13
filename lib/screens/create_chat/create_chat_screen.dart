//a bloc builder widget class for creating a chat
import 'package:chat/utils/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../error/error_screen.dart';
import '../loading/loading_screen.dart';
import 'bloc/create_chat_bloc.dart';
import 'bloc/create_chat_event.dart';
import 'bloc/create_chat_state.dart';

class CreatePartyScreen extends StatelessWidget {
  const CreatePartyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          CreateChatBloc(context.read<FirestoreRepository>()),
      child: const CreateChatScreenBuilder(),
    );
  }
}

class CreateChatScreenBuilder extends StatelessWidget {
  const CreateChatScreenBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateChatBloc, CreateChatState>(listener: (context, state) {
      if (state is CreateChatSuccessState) {
        Navigator.pop(context);
      }
    }, child: BlocBuilder<CreateChatBloc, CreateChatState>(builder: (context, state) {
      if (state is CreateChatErrorState) {
        return const ErrorScreen();
      }else if(state is CreateChatBaseState){
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SizedBox(
                width: 220,
                height: 60,
                child: TextFormField(
                    initialValue: state.name,
                    keyboardType: TextInputType.name,
                    maxLines: 1,
                    maxLength: 30,
                    autofocus: false,
                    autocorrect: false,
                    style: const TextStyle(
                        color: AppColors.main, fontSize: 15),
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: AppColors.main,
                    onChanged: (text) {
                      BlocProvider.of<CreateChatBloc>(context)
                          .add(CreateChatNameChangedEvent(text));
                    },
                    decoration: InputDecoration(
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            )),
                        fillColor: AppColors.white,
                        hintStyle: const TextStyle(color: AppColors.grey_1),
                        contentPadding:
                        const EdgeInsets.only(left: 15, right: 15),
                        hintText: FlutterI18n.translate(
                            context, "chat_name"))),
              ),
            ),
          ],
        );
      } else {
        return const LoadingScreen();
      }
    }));
  }
}