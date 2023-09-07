import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../model/chat.dart';
import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../visit/visit_screen.dart';

class AppOtherMessageWidget extends StatelessWidget {
  final Message message;
  final String pictureData;
  final String displayName;
  final String userId;
  final Chat chat;

  const AppOtherMessageWidget({
    Key? key,
    required this.message,
    required this.pictureData,
    required this.userId,
    required this.displayName,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showVisitScreen(context, userId, chat, false);
      },
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, bottom: 5, top: 5, right: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pictureData.isNotEmpty && pictureData != "nan")
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 10),
                child: AppUserImage(pictureData),
              ),
            Flexible(
              child: (message.chatType == ChatType.giphy)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        imageUrl: message.text,
                        placeholder: (context, url) =>
                            const Center(child: AppSpinner()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    )
                  : Stack(
                      children: [
                        DecoratedBox(
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.grey_4,
                                    AppColors.grey_4
                                  ])),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 5, bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(displayName,
                                    textAlign: TextAlign.left,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  message.text,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
