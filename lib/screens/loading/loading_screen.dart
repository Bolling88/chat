import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      child: const Center(
        child: AppSpinner(),
      ),
    );
  }
}