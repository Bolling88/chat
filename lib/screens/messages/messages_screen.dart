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
                          child: ListView.builder(
                        shrinkWrap: false,
                        reverse: true,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: state.messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (state.messages[index].messageDate != null &&
                              state.messages[index].messageDate?.isNotEmpty ==
                                  true) {
                            return getChatInfoMessage(
                                text: state.messages[index].messageDate ?? '',
                                state: state,
                                index: index,
                                context: context);
                          } else if (state.messages[index].message?.chatType ==
                              ChatType.joined) {
                            return getChatInfoMessage(
                                text:
                                    '${state.messages[index].message!.text} ${FlutterI18n.translate(context, 'joined_chat')}',
                                state: state,
                                index: index,
                                context: context);
                          } else if (state.messages[index].message?.chatType ==
                              ChatType.left) {
                            return getChatInfoMessage(
                                text:
                                    '${state.messages[index].message!.text} ${FlutterI18n.translate(context, 'left_chat')}',
                                state: state,
                                index: index,
                                context: context);
                          } else if (state
                                  .messages[index].message!.createdById ==
                              state.myUser.id) {
                            return AppMyMessageWidget(
                              message: state.messages[index].message!,
                              gender: state
                                  .messages[index].message!.createdByGender,
                              pictureData: state
                                  .messages[index].message!.createdByImageUrl,
                            );
                          } else {
                            return AppOtherMessageWidget(
                              message: state.messages[index].message!,
                              pictureData: state.messages[index].message
                                      ?.createdByImageUrl ??
                                  '',
                              userId:
                                  state.messages[index].message!.createdById,
                              displayName:
                                  state.messages[index].message!.createdByName,
                              gender: state
                                  .messages[index].message!.createdByGender,
                              chat: chat,
                              countryCode: state.messages[index].message
                                      ?.createdByCountryCode
                                      .toLowerCase() ??
                                  '',
                            );
                          }
                        },
                      )),
                      const Divider(),
                      MessageEditTextWidget(
                        currentMessage: state.currentMessage,
                        onTextChanged: (text) {
                          BlocProvider.of<MessagesBloc>(context)
                              .add(MessagesChangedEvent(text));
                        },
                        hintText: FlutterI18n.translate(
                            context, "write_message_hint"),
                        showGiphy: isPrivateChat,
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
                            ? Icons.close
                            : Icons.exit_to_app),
                        onPressed: () {
                          if (chat is PrivateChat) {
                            BlocProvider.of<MessageHolderBloc>(context).add(
                                MessageHolderClosePrivateChatEvent(
                                    chat as PrivateChat));
                          } else {
                            BlocProvider.of<MessageHolderBloc>(context)
                                .add(MessageHolderChangeChatRoomEvent());
                          }
                        },
                        label: Text(translate(
                            context,
                            (chat is PrivateChat)
                                ? 'leave_chat'
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
