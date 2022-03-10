import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: const Text('Unknown error'),
    );
  }
}
