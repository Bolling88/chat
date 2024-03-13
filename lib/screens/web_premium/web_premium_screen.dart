import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class WebPremiumScreen extends StatelessWidget {
  static const routeName = "/web_premium_screen";

  const WebPremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Center(
                child: Lottie.asset('assets/lottie/premium.json',
                    animate: true, fit: BoxFit.cover)),
          ),
          Center(
            child: Text(
              FlutterI18n.translate(context, "web_premium_title"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          Center(
            child: Text(
              FlutterI18n.translate(context, "web_premium_title_second"),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 400,
              child: Text(
                FlutterI18n.translate(context, "web_premium_description"),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              _launchUrl('https://play.google.com/store/apps/details?id=com.xevenition.chat&hl=en_US');
            },
            child: SizedBox(
                width: 300,
                child: Image.asset('assets/img/google_big.webp')),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _launchUrl('https://apps.apple.com/us/app/kvitter-chat-rooms/id6466395401');
            },
            child: SizedBox(
                width: 300,
                child: Image.asset('assets/img/apple_big.png')),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
