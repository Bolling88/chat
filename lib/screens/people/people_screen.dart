import 'package:chat/screens/visit/visit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../model/chat.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../error/error_screen.dart';
import '../hero/hero_screen.dart';
import '../loading/loading_screen.dart';
import 'bloc/people_bloc.dart';
import 'bloc/people_state.dart';

class PeopleScreen extends StatelessWidget {
  final Chat chat;
  final BuildContext parentContext;

  const PeopleScreen(
      {required this.chat, required this.parentContext, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          PeopleBloc(context.read<FirestoreRepository>(), chat),
      child: PeopleScreenBuilder(chat: chat, parentContext: parentContext),
    );
  }
}

class PeopleScreenBuilder extends StatelessWidget {
  final BuildContext parentContext;
  final Chat chat;

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
              height: 400,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: (state.chatUsers.isEmpty)
                  ? Center(
                      child: Text(FlutterI18n.translate(context, 'no_users')))
                  : Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
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
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.chatUsers.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(state.chatUsers[index].displayName),
                                subtitle: Text(
                                    state.chatUsers[index].gender.toString()),
                                leading: (state.chatUsers[index].pictureData !=
                                        'nan')
                                    ? GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, HeroScreen.routeName,
                                              arguments: HeroScreenArguments(
                                                  state.chatUsers[index]
                                                      .pictureData));
                                        },
                                        child: AppUserImage(
                                            state.chatUsers[index].pictureData))
                                    : const SizedBox.shrink(),
                                onTap: () {
                                  Navigator.pop(context);
                                  showVisitScreen(context,
                                      state.chatUsers[index].id, chat, true);
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
            );
          } else {
            return const LoadingScreen();
          }
        }));
  }
}

Future showPeopleScreen(BuildContext parentContext, Chat chat) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: parentContext,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return PeopleScreen(chat: chat, parentContext: parentContext);
    },
  );
}
