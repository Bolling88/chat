import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class MessageEditTextWidget extends StatefulWidget {
  final String currentMessage;
  final String hintText;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<String> onSendTapped;
  final GestureTapCallback onTapGiphy;
  final bool showGiphy;

  const MessageEditTextWidget(
      {Key? key,
      required this.currentMessage,
      required this.hintText,
      required this.onTextChanged,
      required this.onSendTapped,
      required this.onTapGiphy,
      required this.showGiphy})
      : super(key: key);

  @override
  State<MessageEditTextWidget> createState() => _MessageEditTextWidgetState();
}

class _MessageEditTextWidgetState extends State<MessageEditTextWidget> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                maxLength: 200,
                minLines: 1,
                autofocus: false,
                autocorrect: true,
                controller: controller,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.merge(const TextStyle(color: AppColors.main)),
                textCapitalization: TextCapitalization.sentences,
                cursorColor: AppColors.main,
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
                    fillColor: AppColors.grey_4,
                    hintStyle: Theme.of(context).textTheme.bodyMedium,
                    contentPadding:
                        const EdgeInsets.only(left: 15, right: 15),
                    hintText: widget.hintText)),
          ),
          const SizedBox(
            width: 10,
          ),
          if(widget.currentMessage.isEmpty && widget.showGiphy)
            Material(
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
                      border:
                      Border.all(color: AppColors.main, width: 3)),
                  child: const Icon(
                    Icons.gif,
                    size: 30,
                    color: AppColors.main,
                  ),
                ),
              ),
            ),
          (widget.currentMessage.isNotEmpty && widget.showGiphy)
              ? const SizedBox.shrink()
              : const SizedBox(
                  width: 10,
                ),
        ],
      ),
    );
  }
}
