import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:giphy_get/giphy_get.dart';
import '../../model/chat.dart';
import '../../model/private_chat.dart';
import '../../model/room_chat.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/constants.dart';
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

  const MessagesScreen(this.chat, this.isPrivateChat,
      {this.userIds, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => MessagesBloc(
          chat.id, context.read<FirestoreRepository>(),
          isPrivateChat: isPrivateChat),
      child: ChatsScreenContent(
        chat: chat,
      ),
    );
  }
}

class ChatsScreenContent extends StatefulWidget {
  final Chat chat;

  const ChatsScreenContent({required this.chat, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatsScreenContentState();
  }
}

class ChatsScreenContentState extends State<ChatsScreenContent> {
  final _scrollThreshold = 600.0;
  final _scrollController = ScrollController();

  ChatsScreenContentState();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MessagesBloc, MessagesState>(
        listener: (context, state) {},
        child: BlocBuilder<MessagesBloc, MessagesState>(
          builder: (context, state) {
            if (state is MessagesBaseState) {
              return Column(
                children: [
                  Expanded(
                      child: NotificationListener<ScrollNotification>(
                    onNotification: (note) {
                      if (note.metrics.maxScrollExtent - note.metrics.pixels <
                          _scrollThreshold) {
                        BlocProvider.of<MessagesBloc>(context)
                            .add(MessagesFetchMoreEvent());
                      }
                      return true;
                    },
                    child: ListView.builder(
                      shrinkWrap: false,
                      reverse: true,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      controller: _scrollController,
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
                              text: '${state.messages[index].message!.text} ${FlutterI18n.translate(context, 'joined_chat')}',
                              state: state,
                              index: index,
                              context: context);
                        } else if (state.messages[index].message?.chatType ==
                            ChatType.left) {
                          return getChatInfoMessage(
                              text: '${state.messages[index].message!.text} ${FlutterI18n.translate(context, 'left_chat')}',
                              state: state,
                              index: index,
                              context: context);
                        } else if (state.messages[index].message!.createdById ==
                            state.userId) {
                          return AppMyMessageWidget(
                            state.messages[index].message!,
                            pictureData: state
                                .messages[index].message!.createdByImageUrl,
                          );
                        } else {
                          return AppOtherMessageWidget(
                            message: state.messages[index].message!,
                            pictureData: state.messages[index].message
                                    ?.createdByImageUrl ??
                                '',
                            userId: state.messages[index].message!.createdById,
                            displayName:
                                state.messages[index].message!.createdByName,
                            gender: state.messages[index].message!.createdByGender,
                            chat: widget.chat,
                          );
                        }
                      },
                    ),
                  )),
                  const Divider(),
                  MessageEditTextWidget(
                      currentMessage: state.currentMessage,
                      onTextChanged: (text) {
                        BlocProvider.of<MessagesBloc>(context)
                            .add(MessagesChangedEvent(text));
                      },
                      showGiphy: widget.chat.runtimeType is PrivateChat && widget.chat.runtimeType is! RoomChat,
                      onTapGiphy: () async {
                        final GiphyGif? gif = await GiphyGet.getGif(
                          context: context, //Required
                          apiKey: giphyKey, //Required.
                          randomID: state
                              .userId, // Optional - An ID/proxy for a specific user.
                        );
                        if (gif != null) {
                          BlocProvider.of<MessagesBloc>(context)
                              .add(MessagesGiphyPickedEvent(gif));
                        }
                      })
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
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColors.grey_1),
            )));
  }
}
