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

class CreateChatScreen extends StatelessWidget {
  const CreateChatScreen({Key? key}) : super(key: key);

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
    return BlocListener<CreateChatBloc, CreateChatState>(listener:
        (context, state) {
      if (state is CreateChatSuccessState) {
        Navigator.pop(context);
      }
    }, child:
        BlocBuilder<CreateChatBloc, CreateChatState>(builder: (context, state) {
      if (state is CreateChatErrorState) {
        return const ErrorScreen();
      } else if (state is CreateChatBaseState) {
        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
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
                            color: AppColors.main,
                            fontSize: 15,
                            fontFamily: 'socialize'),
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
                            hintText:
                                FlutterI18n.translate(context, "chat_name"))),
                  ),
                ),
                const SizedBox(height: 40),
                (state.name.length >= 5)
                    ? AppButton(
                        text: FlutterI18n.translate(context, 'create_chat'),
                        width: 200,
                        onTap: () {
                          BlocProvider.of<CreateChatBloc>(context)
                              .add(CreateChatContinueClickedEvent());
                        })
                    : AppButtonDisabled(
                        text: FlutterI18n.translate(context, 'create_chat'),
                        width: 200),
                const SizedBox(height: 40)
              ],
            ),
          ),
        );
      } else {
        return const LoadingScreen();
      }
    }));
  }
}

Future showCreateChatScreen(BuildContext context) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return const CreateChatScreen();
    },
  );
}
