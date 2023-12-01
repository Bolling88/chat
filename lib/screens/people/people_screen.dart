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
import '../account/account_screen.dart';
import '../error/error_screen.dart';
import '../messages/other_message_widget.dart';
import 'bloc/people_bloc.dart';
import 'bloc/people_event.dart';
import 'bloc/people_state.dart';

class PeopleScreen extends StatelessWidget {
  final Chat? chat;
  final List<ChatUser>? users;
  final BuildContext parentContext;

  const PeopleScreen(
      {required this.chat,
      required this.users,
      required this.parentContext,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          PeopleBloc(context.read<FirestoreRepository>(), users),
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
              height: getSize(context) == ScreenSize.large
                  ? double.infinity
                  : MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: (state.allOnlineUsers.isEmpty)
                  ? Column(
                      children: [
                        Center(
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
                        getTopBar(context, chat, state),
                        getList(state.filteredUsers),
                      ],
                    ),
            );
          } else {
            return Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
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
        //separatorBuilder: (BuildContext context, int index) => const Divider(),
        key: const PageStorageKey('PeopleList'),
        itemCount: users.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            visualDensity: const VisualDensity(vertical: -4),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(users[index].displayName,
                    style: Theme.of(context).textTheme.displaySmall?.merge(
                        TextStyle(
                            fontSize: 20,
                            color: getGenderColor(
                                Gender.fromValue(users[index].gender))))),
                const SizedBox(width: 4),
                if (users[index].birthDate != null && users[index].showAge)
                  Text(
                    getAge(users[index].birthDate),
                    style: Theme.of(context).textTheme.displaySmall?.merge(TextStyle(
                        color: getGenderColor(Gender.fromValue(users[index].gender)), fontSize: 16)),
                  ),
                if (users[index].birthDate != null) const SizedBox(width: 4),
                if (users[index].gender != Gender.secret.value)
                  SizedBox(
                      width: 18,
                      height: 18,
                      child: AppLottie(
                        url: getGenderUrl(users[index].gender),
                        animate: false,
                      )),
              ],
            ),
            trailing:
                getFlag(countryCode: users[index].countryCode, fontSize: 30),
            subtitle: getRegionText(users, index, context),
            leading: AppUserImage(
              url: users[index].pictureData,
              gender: users[index].gender,
              isApproved: ApprovedImage.fromValue(users[index].approvedImage),
              size: 40,
            ),
            onTap: () {
              if (getSize(context) == ScreenSize.small) {
                //Navigator.pop(context);
              }
              showVisitScreen(parentContext, users[index].id, chat,
                  getSize(context) == ScreenSize.small);
            },
          );
        },
      ),
    );
  }

  Text getRegionText(List<ChatUser> users, int index, BuildContext context) {
    final regionName = users[index].regionName;
    final countryName = users[index].country;
    final cityName = users[index].city;
    final region = (regionName.isNotEmpty) ? regionName : cityName;

    if (region.isEmpty && countryName.isEmpty) {
      return Text(FlutterI18n.translate(context, 'unknown_location'),
          style: Theme.of(context).textTheme.bodyMedium);
    }

    if (region.isNotEmpty) {
      return Text('$region, ${users[index].country}',
          style: Theme.of(context).textTheme.bodyMedium);
    } else {
      return Text(countryName, style: Theme.of(context).textTheme.bodyMedium);
    }
  }

  Column getTopBar(BuildContext context, Chat? chat, PeopleBaseState state) {
    return Column(
      children: [
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
              '${state.allOnlineUsers.length} ${FlutterI18n.translate(
                context,
                'user_online',
              )}',
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Wrap(
            spacing: 5.0,
            runSpacing: 5.0,
            children: List<Widget>.generate(
              Gender.getAsList().length + 1,
              (int index) {
                return ChoiceChip(
                  labelPadding: const EdgeInsets.all(2.0),
                  label: Text(
                    (index == 0)
                        ? FlutterI18n.translate(context, 'all')
                        : getGenderName(context, Gender.fromValue(index - 1)),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.merge(TextStyle(color: (index == state.genderFilterIndex)?  AppColors.white : AppColors.main)),
                  ),
                  selected: index == state.genderFilterIndex,
                  selectedColor: (index == 0)
                      ? AppColors.main
                      : getGenderColor(Gender.fromValue(index - 1)),
                  onSelected: (value) {
                    BlocProvider.of<PeopleBloc>(context)
                        .add(PeopleFilterEvent(index));
                  },
                  checkmarkColor: AppColors.white,
                  // backgroundColor: color,
                  elevation: 1,
                  padding: const EdgeInsets.all(6.0),
                );
              },
            ).toList(),
          ),
        )
      ],
    );
  }
}

Future showPeopleScreen(BuildContext parentContext, Chat? chat,
    List<ChatUser>? initialUsers) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: AppColors.transparent,
    builder: (BuildContext context) {
      return PeopleScreen(
          chat: chat, parentContext: parentContext, users: initialUsers);
    },
  );
}
