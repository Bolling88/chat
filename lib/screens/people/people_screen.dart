import 'package:chat/screens/visit/visit_screen.dart';
import 'package:chat/utils/gender.dart';
import 'package:chat/utils/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../model/chat.dart';
import '../../model/chat_user.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/constants.dart';
import '../../utils/flag.dart';
import '../error/error_screen.dart';
import '../loading/loading_screen.dart';
import '../messages/other_message_widget.dart';
import 'bloc/people_bloc.dart';
import 'bloc/people_state.dart';

class PeopleScreen extends StatelessWidget {
  final Chat? chat;
  final ChatUser user;
  final BuildContext parentContext;

  const PeopleScreen(
      {required this.chat,
      required this.user,
      required this.parentContext,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          PeopleBloc(context.read<FirestoreRepository>(), chat, user),
      child: PeopleScreenBuilder(chat: chat, parentContext: parentContext),
    );
  }
}

class PeopleScreenBuilder extends StatelessWidget {
  final BuildContext parentContext;
  final Chat? chat;

  const PeopleScreenBuilder(
      {required this.chat, required this.parentContext, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PeopleBloc, PeopleState>(
        listener: (context, state) {},
        child: BlocBuilder<PeopleBloc, PeopleState>(builder: (context, state) {
          if (state is PeopleErrorState) {
            return const ErrorScreen();
          } else if (state is PeopleBaseState) {
            return Container(
              height:
                  getSize(context) == ScreenSize.large ? double.infinity : bottomsheetHeight,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: (state.onlineUser.isEmpty)
                  ? Column(
                      children: [
                        const Center(
                            child: SizedBox(
                                height: 200,
                                child: AppLottie(
                                    url:
                                        'https://firebasestorage.googleapis.com/v0/b/chat-60225.appspot.com/o/lottie%2Fshrug.json?alt=media&token=73407d43-f0b5-4762-9042-12f07b3646e5'))),
                        Center(
                            child: Text(
                                FlutterI18n.translate(context, 'no_users')))
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        getTopBar(context, chat),
                        getList(state.onlineUser),
                      ],
                    ),
            );
          } else {
            return Container(
              width: double.infinity,
              height: bottomsheetHeight,
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: const Center(
                child: AppSpinner(),
              ),
            );
          }
        }));
  }

  Expanded getList(List<ChatUser> users) {
    return Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Row(
                                children: [
                                  Text(users[index].displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.merge(TextStyle(
                                              fontSize: 20,
                                              color: getGenderColor(
                                                  Gender.fromValue(users[index]
                                                      .gender))))),
                                  const SizedBox(width: 2),
                                  if (users[index].gender !=
                                      Gender.secret.value)
                                    SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: AppLottie(
                                          url: getGenderUrl(
                                              users[index].gender),
                                          animate: false,
                                        )),
                                ],
                              ),
                              trailing: getFlag(
                                  countryCode:
                                  users[index].countryCode,
                                  fontSize: 30),
                              subtitle: Text(
                                  '${users[index].city}, ${users[index].country}',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              leading: AppUserImage(
                                url: users[index].pictureData,
                                gender: users[index].gender,
                                size: 40,
                              ),
                              onTap: () {
                                if (getSize(context) == ScreenSize.small) {
                                  //Navigator.pop(context);
                                }
                                showVisitScreen(
                                    parentContext,
                                    users[index].id,
                                    chat,
                                    getSize(context) == ScreenSize.small);
                              },
                            );
                          },
                        ),
                      );
  }

  Row getTopBar(BuildContext context, Chat? chat) {
    return Row(
      children: [
        Visibility(
          visible: false,
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              child: const Icon(Icons.arrow_back)),
        ),
        Expanded(
            child: Center(
                child: Text(
          FlutterI18n.translate(
            context,
            'user_online',
          ),
          style: Theme.of(context).textTheme.displaySmall,
        ))),
        if (getSize(context) == ScreenSize.small)
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(10),
              ),
              child: const Icon(Icons.close))
      ],
    );
  }
}

Future showPeopleScreen(
    BuildContext parentContext, Chat? chat, ChatUser user) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return PeopleScreen(chat: chat, user: user, parentContext: parentContext);
    },
  );
}
