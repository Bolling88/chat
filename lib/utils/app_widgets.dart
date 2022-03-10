import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppSpinner extends StatelessWidget {
  const AppSpinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white));
  }
}
