import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import '../../utils/app_colors.dart';
import 'bloc/messages_bloc.dart';
import 'bloc/messages_event.dart';

class MessageEditTextWidget extends StatefulWidget {
  final String currentMessage;
  final ValueChanged<String> onTextChanged;
  final GestureTapCallback onTapGiphy;

  const MessageEditTextWidget(
      {Key? key,
        required this.currentMessage,
        required this.onTextChanged,
        required this.onTapGiphy})
      : super(key: key);

  @override
  State<MessageEditTextWidget> createState() =>
      _MessageEditTextWidgetState();
}

class _MessageEditTextWidgetState extends State<MessageEditTextWidget> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    maxLength: 100,
                    minLines: 1,
                    autofocus: false,
                    autocorrect: false,
                    controller: controller,
                    style: const TextStyle(
                        color: AppColors.main,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'socialize'),
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: AppColors.main,
                    onChanged: widget.onTextChanged,
                    onEditingComplete: () {
                      BlocProvider.of<MessagesBloc>(context)
                          .add(MessagesSendEvent());
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
                              BlocProvider.of<MessagesBloc>(context)
                                  .add(MessagesSendEvent());
                              controller.text = "";
                            },
                            icon: Icon(Icons.send,
                                color: (controller.text.isNotEmpty)
                                    ? AppColors.main
                                    : AppColors.grey_1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              width: 2,
                              color: AppColors.grey_1,
                              style: BorderStyle.solid,
                            )),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              width: 3,
                              color: AppColors.main,
                              style: BorderStyle.solid,
                            )),
                        fillColor: AppColors.white,
                        hintStyle: const TextStyle(
                            color: AppColors.grey_1,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                        contentPadding:
                        const EdgeInsets.only(left: 15, right: 15),
                        hintText: FlutterI18n.translate(
                            context, "write_message_hint"))),
              ),
              const SizedBox(
                width: 10,
              ),
              (widget.currentMessage.isNotEmpty)
                  ? const SizedBox.shrink()
                  : Material(
                child: InkWell(
                  splashColor: AppColors.main.withOpacity(0.5),
                  hoverColor: AppColors.main.withOpacity(0.5),
                  highlightColor: AppColors.main.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(25.0),
                  onTap: widget.onTapGiphy,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: AppColors.main, width: 3)),
                    child: const Icon(
                      Icons.gif,
                      size: 30,
                      color: AppColors.main,
                    ),
                  ),
                ),
              ),
              (widget.currentMessage.isNotEmpty)
                  ? const SizedBox.shrink()
                  : const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}