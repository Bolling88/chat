import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String userName;

  const FullScreenImage({super.key, required this.imageUrl, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(userName)),
      backgroundColor: AppColors.black,
      body: Hero(
        tag: 'fullscreenImage',
        child: Center(
          child: InteractiveViewer(
              panEnabled: true, // Set it to false
              minScale: 1,
              clipBehavior: Clip.none,
              maxScale: 3,
              child: Image.network(imageUrl)),
        ),
      ),
    );
  }
}