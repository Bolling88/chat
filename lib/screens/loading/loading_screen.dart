import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: AppSpinner(),
      ),
    );
  }
}