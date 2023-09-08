import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottie extends StatefulWidget {
  final String url;
  final bool animate;

  const AppLottie({required this.url, this.animate = true, super.key});

  @override
  State<AppLottie> createState() => _AppLottieState();
}

class _AppLottieState extends State<AppLottie> {
  late final Future<LottieComposition> _composition;

  @override
  void initState() {
    super.initState();

    _composition = NetworkLottie(widget.url).load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LottieComposition>(
      future: _composition,
      builder: (context, snapshot) {
        var composition = snapshot.data;
        if (composition != null) {
          return Lottie(
            composition: composition,
            fit: BoxFit.fitHeight,
            animate: widget.animate,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
