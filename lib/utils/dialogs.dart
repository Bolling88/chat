import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? button1Text;
  final String? button2Text;
  final VoidCallback? button1Pressed;
  final VoidCallback? button2Pressed;

  const AppDialog({
    Key? key,
    required this.title,
    required this.message,
    this.button1Text,
    this.button2Text,
    this.button1Pressed,
    this.button2Pressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
      title: Center(
          child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, color: AppColors.black, fontFamily: 'Brown'),
      )),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey_1),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (button2Text != null && button2Pressed != null)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: TextButton(
                        onPressed: button2Pressed,
                        child: Text(
                          button2Text!,
                          style: getDialogTextStyle(),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              (button1Text != null && button1Pressed != null)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: TextButton(
                        onPressed: button1Pressed,
                        child: Text(button1Text!, style: getDialogTextStyle()),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          )
        ],
      ),
    );
  }
}
TextStyle getDialogTextStyle() {
  return const TextStyle(fontSize: 20, fontFamily: 'Brown', color: AppColors.black);
}

TextStyle getDialogTextStyleDisabled() {
  return const TextStyle(fontSize: 20, fontFamily: 'Brown', color: AppColors.grey_1);
}
