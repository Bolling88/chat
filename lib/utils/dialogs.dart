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
        style: Theme.of(context).textTheme.bodyMedium,
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
              style: Theme.of(context).textTheme.bodyMedium,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              (button1Text != null && button1Pressed != null)
                  ? Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: TextButton(
                        onPressed: button1Pressed,
                        child: Text(button1Text!, style: Theme.of(context).textTheme.bodyMedium),
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


