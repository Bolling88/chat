import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class HeroScreenArguments {
  final String imagePath;

  const HeroScreenArguments(this.imagePath);
}

class HeroScreen extends StatelessWidget {
  static const routeName = "/hero_screen";
  const HeroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HeroScreenArguments args =
    ModalRoute.of(context)?.settings.arguments as HeroScreenArguments;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.black, //change your color here
        ),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: Image.network(
              args.imagePath,
            ),
          ),
        ),
      ),
    );
  }
}
