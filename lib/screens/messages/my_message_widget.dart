import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../model/message.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';

class AppMyMessageWidget extends StatelessWidget {
  final Message message;
  final String pictureData;

  const AppMyMessageWidget(
    this.message, {
    Key? key,
    required this.pictureData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(left: 40, bottom: 5, top: 5, right: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            (message.chatType == ChatType.giphy)
                ? Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        imageUrl: message.text,
                        placeholder: (context, url) =>
                            const Center(child: AppSpinner()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  )
                : Flexible(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Stack(
                        children: [
                          DecoratedBox(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10.0),
                                  bottomRight: Radius.circular(10.0),
                                  topLeft: Radius.circular(10.0),
                                ),
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.main,
                                      AppColors.main_2
                                    ])),
                            child: Padding(
                                padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
                                child: Text(message.text,
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.merge(
                                          const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ))),
                          )
                        ],
                      ),
                    ),
                  ),
            if (pictureData.isNotEmpty && pictureData != "nan")
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: AppUserImage(pictureData),
              )
          ],
        ));
  }
}
