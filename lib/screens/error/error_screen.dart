import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.backgroundColor,
      child: const Center(child: Text('Unknown error')),
    );
  }
}
