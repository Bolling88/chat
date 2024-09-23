import 'package:chat/screens/messages/bloc/messages_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/message.dart';
import '../../utils/app_colors.dart';
import 'bloc/messages_bloc.dart';
import 'other_message_widget.dart';

class MessageEditTextWidget extends StatefulWidget {
  final String currentMessage;
  final String hintText;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onSendTapped;
  final GestureTapCallback onTapGiphy;
  final GestureTapCallback onImageTap;
  final bool showGiphy;
  final bool showImage;
  final Message? replyMessage;

  const MessageEditTextWidget(
      {super.key,
      required this.currentMessage,
      required this.hintText,
      required this.onTextChanged,
      required this.onSendTapped,
      required this.onTapGiphy,
      required this.onImageTap,
      required this.showGiphy,
      required this.showImage,
      this.replyMessage});

  @override
  State<MessageEditTextWidget> createState() => _MessageEditTextWidgetState();
}

class _MessageEditTextWidgetState extends State<MessageEditTextWidget> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.replyMessage != null)
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                    color: context.grey_4,
                    borderRadius:
                        const BorderRadius.all(Radius.circular(10.0))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: getPostedByName(
                            context: context,
                            displayName:
                                widget.replyMessage?.createdByName ?? '',
                            gender: widget.replyMessage?.createdByGender ?? 0,
                            countryCode:
                                widget.replyMessage?.createdByCountryCode ?? '',
                            showAge: widget.replyMessage?.showAge ?? false,
                            birthDate: widget.replyMessage?.birthDate,
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                        IconButton(
                            onPressed: () {
                              BlocProvider.of<MessagesBloc>(context)
                                  .add(MessagesReplyEventClear());
                            },
                            icon: Icon(
                              Icons.close,
                              color: context.main,
                            ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, bottom: 10),
                      child: Text(
                        widget.replyMessage?.text ?? '',
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.merge(TextStyle(color: context.textColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    maxLength: 200,
                    minLines: 1,
                    autofocus: false,
                    autocorrect: true,
                    controller: controller,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: context.textColor,
                    onChanged: widget.onTextChanged,
                    onEditingComplete: () {
                      widget.onSendTapped.call(controller.text);
                      controller.text = "";
                    },
                    decoration: InputDecoration(
                        filled: true,
                        counterText: "",
                        suffixIcon: Material(
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          color: Colors.transparent,
                          child: IconButton(
                            onPressed: () {
                              widget.onSendTapped.call(controller.text);
                              controller.text = "";
                            },
                            icon: Icon(Icons.send,
                                color: (controller.text.isNotEmpty)
                                    ? context.main
                                    : context.textColor),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              width: 2,
                              color: context.textColor,
                              style: BorderStyle.solid,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(
                              width: 3,
                              color: context.main,
                              style: BorderStyle.solid,
                            )),
                        fillColor: context.grey_4,
                        hintStyle:
                            Theme.of(context).textTheme.bodyMedium?.merge(
                                  TextStyle(color: context.hintColor),
                                ),
                        contentPadding:
                            const EdgeInsets.only(left: 15, right: 15),
                        hintText: widget.hintText)),
              ),
              const SizedBox(width: 10),
              if (widget.currentMessage.isEmpty && widget.showGiphy)
                Material(
                  child: InkWell(
                    splashColor: context.main.withOpacity(0.5),
                    hoverColor: context.main.withOpacity(0.5),
                    highlightColor: context.main.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25.0),
                    onTap: widget.onTapGiphy,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: context.main, width: 3)),
                      child: Icon(
                        Icons.gif,
                        size: 30,
                        color: context.main,
                      ),
                    ),
                  ),
                ),
              if (widget.currentMessage.isEmpty && widget.showImage)
                const SizedBox(width: 10),
              if (widget.currentMessage.isEmpty && widget.showImage)
                Material(
                  child: InkWell(
                    splashColor: context.main.withOpacity(0.5),
                    hoverColor: context.main.withOpacity(0.5),
                    highlightColor: context.main.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25.0),
                    onTap: widget.onImageTap,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: context.main, width: 3)),
                      child: Icon(
                        Icons.image,
                        size: 30,
                        color: context.main,
                      ),
                    ),
                  ),
                ),
              (widget.currentMessage.isNotEmpty &&
                      (widget.showGiphy || widget.showImage))
                  ? const SizedBox.shrink()
                  : const SizedBox(
                      width: 10,
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
