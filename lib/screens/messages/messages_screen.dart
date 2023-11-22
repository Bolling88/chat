import 'package:chat/model/private_chat.dart';
import 'package:chat/screens/message_holder/bloc/message_holder_bloc.dart';
import 'package:chat/screens/message_holder/bloc/message_holder_event.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../model/chat.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_widgets.dart';
import '../../utils/constants.dart';
import '../../utils/translate.dart';
import 'bloc/messages_bloc.dart';
import 'bloc/messages_event.dart';
import 'bloc/messages_state.dart';
import 'message_edit_text_widget.dart';
import 'my_message_widget.dart';
import 'other_message_widget.dart';

class MessagesScreen extends StatelessWidget {
  static const routeName = "/messages_screen";
  final Chat chat;
  final List<String>? userIds;

  final bool isPrivateChat;

  const MessagesScreen(this.chat, this.isPrivateChat, {this.userIds, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MessagesBloc(
          chat, context.read<FirestoreRepository>(),
          isPrivateChat: isPrivateChat),
      child: ChatsScreenContent(
        chat: chat,
        isPrivateChat: isPrivateChat,
      ),
    );
  }
}

class ChatsScreenContent extends StatelessWidget {
  final Chat chat;
  final bool isPrivateChat;

  const ChatsScreenContent(
      {required this.chat, required this.isPrivateChat, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessagesBloc, MessagesState>(
        listener: (context, state) {},
        child: BlocBuilder<MessagesBloc, MessagesState>(
          builder: (context, state) {
            if (state is MessagesBaseState) {
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ListView.builder(
                              shrinkWrap: false,
                              padding: const EdgeInsets.only(bottom: 10),
                              reverse: true,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: state.messages.length + 1,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == 0) {
                                  if (isPrivateChat &&
                                      state.privateChat?.lastMessageUserId ==
                                          getUserId()) {
                                    return (state.privateChat?.lastMessageReadBy
                                                .length ==
                                            2)
                                        ? getSeenWidget(context, true)
                                        : getSeenWidget(context, false);
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                } else if (state.messages[getActualIndex(index)]
                                            .messageDate !=
                                        null &&
                                    state.messages[getActualIndex(index)]
                                            .messageDate?.isNotEmpty ==
                                        true) {
                                  return getChatInfoMessage(
                                      text: state
                                              .messages[getActualIndex(index)]
                                              .messageDate ??
                                          '',
                                      state: state,
                                      index: getActualIndex(index),
                                      context: context);
                                } else if (state.messages[getActualIndex(index)]
                                        .message?.chatType ==
                                    ChatType.joined) {
                                  return getChatInfoMessage(
                                      text:
                                          '${state.messages[getActualIndex(index)].message!.text} ${FlutterI18n.translate(context, 'joined_chat')}',
                                      state: state,
                                      index: getActualIndex(index),
                                      context: context);
                                } else if (state.messages[getActualIndex(index)]
                                        .message?.chatType ==
                                    ChatType.left) {
                                  return getChatInfoMessage(
                                      text:
                                          '${state.messages[getActualIndex(index)].message!.text} ${FlutterI18n.translate(context, 'left_chat')}',
                                      state: state,
                                      index: getActualIndex(index),
                                      context: context);
                                } else if (state.messages[getActualIndex(index)]
                                        .message!.createdById ==
                                    state.myUser.id) {
                                  return AppMyMessageWidget(
                                    message: state
                                        .messages[getActualIndex(index)]
                                        .message!,
                                    gender: state
                                        .messages[getActualIndex(index)]
                                        .message!
                                        .createdByGender,
                                    pictureData: state
                                        .messages[getActualIndex(index)]
                                        .message!
                                        .createdByImageUrl,
                                  );
                                } else {
                                  return AppOtherMessageWidget(
                                    message: state
                                        .messages[getActualIndex(index)]
                                        .message!,
                                    pictureData: state
                                            .messages[getActualIndex(index)]
                                            .message
                                            ?.createdByImageUrl ??
                                        '',
                                    userId: state
                                        .messages[getActualIndex(index)]
                                        .message!
                                        .createdById,
                                    displayName: state
                                        .messages[getActualIndex(index)]
                                        .message!
                                        .createdByName,
                                    gender: state
                                        .messages[getActualIndex(index)]
                                        .message!
                                        .createdByGender,
                                    chat: chat,
                                    countryCode: state
                                            .messages[getActualIndex(index)]
                                            .message
                                            ?.createdByCountryCode
                                            .toLowerCase() ??
                                        '', approvedImage: state
                                      .messages[getActualIndex(index)]
                                      .message
                                      ?.approvedImage ?? 0,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      MessageEditTextWidget(
                        currentMessage: state.currentMessage,
                        onTextChanged: (text) {
                          BlocProvider.of<MessagesBloc>(context)
                              .add(MessagesChangedEvent(text));
                        },
                        hintText: FlutterI18n.translate(
                            context, "write_message_hint"),
                        showGiphy: true,
                        onTapGiphy: () async {
                          final GiphyGif? gif = await GiphyGet.getGif(
                            context: context, //Required
                            apiKey: giphyKey, //Required.
                            randomID: state.myUser
                                .id, // Optional - An ID/proxy for a specific user.
                          );
                          if (gif != null) {
                            if (context.mounted) {
                              BlocProvider.of<MessagesBloc>(context)
                                  .add(MessagesGiphyPickedEvent(gif));
                            }
                          }
                        },
                        onSendTapped: (String message) {
                          BlocProvider.of<MessagesBloc>(context)
                              .add(MessagesSendEvent());
                        },
                      ),
                      if (!kIsWeb)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          child: SafeArea(child: LayoutBuilder(
                            builder: (context, constraints) {
                              BlocProvider.of<MessagesBloc>(context)
                                  .loadAd(constraints.maxWidth.round());
                              final banner = state.bannerAd;
                              if (banner != null) {
                                return Container(
                                    color: AppColors.background,
                                    width: banner.size.width.toDouble(),
                                    height: banner.size.height.toDouble(),
                                    child: AdWidget(ad: banner));
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          )),
                        ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton.icon(
                        icon: Icon((chat is PrivateChat)
                            ? Icons.delete
                            : Icons.exit_to_app),
                        onPressed: () {
                          if (chat is PrivateChat) {
                            //show warning dialog
                            showDeleteChatDialog(context);
                          } else {
                            BlocProvider.of<MessageHolderBloc>(context)
                                .add(MessageHolderChangeChatRoomEvent());
                          }
                        },
                        label: Text(translate(
                            context,
                            (chat is PrivateChat)
                                ? 'delete_chat'
                                : 'change_room')),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is MessagesEmptyState) {
              return Center(
                child: Text(FlutterI18n.translate(context, "no_messages")),
              );
            } else if (state is MessagesErrorState) {
              return Center(
                child: Text(FlutterI18n.translate(context, "unknown_error")),
              );
            } else {
              return const Center(
                child: AppSpinner(),
              );
            }
          },
        ));
  }

  Align getSeenWidget(BuildContext context, bool isSeen) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isSeen
                ? FlutterI18n.translate(context, 'seen')
                : FlutterI18n.translate(context, 'delivered'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Icon(
            isSeen ? Icons.check_circle : Icons.check_circle_outline,
            color: isSeen ? AppColors.main : AppColors.grey_1,
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  int getActualIndex(int index) => index - 1;

  void showDeleteChatDialog(BuildContext parentContext) {
    showDialog(
        context: parentContext,
        builder: (context) => AlertDialog(
              title: Text(FlutterI18n.translate(context, "delete_chat")),
              content:
                  Text(FlutterI18n.translate(context, "delete_chat_message")),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(FlutterI18n.translate(context, "no"))),
                TextButton(
                    onPressed: () {
                      BlocProvider.of<MessageHolderBloc>(parentContext).add(
                          MessageHolderClosePrivateChatEvent(
                              chat as PrivateChat));
                      Navigator.pop(context);
                    },
                    child: Text(FlutterI18n.translate(context, "yes")))
              ],
            ));
  }

  Center getChatInfoMessage(
      {required String text,
      required MessagesBaseState state,
      required int index,
      required BuildContext context}) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5),
            child: Text(
              text,
              style:
                  Theme.of(context).textTheme.bodySmall?.merge(const TextStyle(
                        fontSize: 10,
                      )),
            )));
  }
}
