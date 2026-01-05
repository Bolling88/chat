import 'package:chat/utils/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

void showCameraOrImageBottomSheetMessage(
    {required BuildContext parentContext,
    required VoidCallback onCameraPressed,
    required VoidCallback onGalleryPressed,
    required bool isPremiumUser,
    required num kvitterCredits}) async {
  await showModalBottomSheet(
    useRootNavigator: true,
    isScrollControlled: true,
    context: parentContext,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
    ),
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            FlutterI18n.translate(context, 'send_a_photo'),
              style: Theme.of(context).textTheme.displaySmall
          ),
          const SizedBox(height: 24),
          if (isPremiumUser == false && kIsWeb == false)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(FlutterI18n.translate(context, '1'),
                    style: Theme.of(context).textTheme.bodyLarge),
                Icon(
                  Icons.paid_outlined,
                  color: context.textColor,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(
                    FlutterI18n.translate(
                        context, '(${kvitterCredits.toInt()})'),
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Material(
                child: InkWell(
                  splashColor: context.main.withValues(alpha: 0.5),
                  hoverColor: context.main.withValues(alpha: 0.5),
                  highlightColor: context.main.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(25.0),
                  onTap: onCameraPressed,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: context.main, width: 3)),
                    child: Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: context.main,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Material(
                child: InkWell(
                  splashColor: context.main.withValues(alpha: 0.5),
                  hoverColor: context.main.withValues(alpha: 0.5),
                  highlightColor: context.main.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(25.0),
                  onTap: onGalleryPressed,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: context.main, width: 3)),
                    child: Icon(
                      Icons.photo,
                      size: 30,
                      color: context.main,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SafeArea(child: SizedBox(height: 20)),
        ],
      );
    },
  );
}
