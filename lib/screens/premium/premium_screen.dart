import 'package:chat/repository/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';
import '../../repository/firestore_repository.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_widgets.dart';
import '../../utils/translate.dart';
import 'bloc/premium_bloc.dart';
import 'bloc/premium_event.dart';
import 'bloc/premium_state.dart';

class PremiumScreen extends StatelessWidget {
  static const routeName = "/premium_screen";

  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => PremiumBloc(
          context.read<FirestoreRepository>(),
          context.read<SubscriptionRepository>()),
      child: const PremiumScreenBuilder(),
    );
  }
}

class PremiumScreenBuilder extends StatelessWidget {
  const PremiumScreenBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translate(context, 'kvitter_premium'),
        ),
      ),
      body: BlocListener<PremiumBloc, PremiumState>(listener: (context, state) {
        if (state is PremiumDoneState) {
          Navigator.of(context).pop();
        } else if (state is PremiumNothingRestoreState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  FlutterI18n.translate(context, 'no_subscription_to_restore')),
              duration: const Duration(seconds: 1),
            ),
          );
        } else if (state is PremiumAbortedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(FlutterI18n.translate(context, 'transaction_aborted')),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }, child:
          BlocBuilder<PremiumBloc, PremiumState>(builder: (blocContext, state) {
        if (state is PremiumErrorState) {
          return AppErrorScreen(
            message: translate(context, 'transaction_aborted'),
          );
        } else if (state is PremiumBaseState) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                    child: Lottie.asset('assets/lottie/premium.json',
                        animate: true, fit: BoxFit.cover)),
              ),
              Center(
                child: Text(
                  translate(context, 'kvitter_premium'),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              Center(
                child: Text(
                  translate(context, 'includes'),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      color: context.textColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translate(context, 'unlimited_credits'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.block,
                      color: context.textColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translate(context, 'no_ads'),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              Center(
                child: Text(
                  '${state.package.storeProduct.priceString} ${FlutterI18n.translate(context, 'monthly')}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 22),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read<PremiumBloc>()
                          .add(PremiumBuyEvent(state.package));
                    },
                    child: Lottie.asset('assets/lottie/premium_button.json',
                        animate: true),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {
                      context.read<PremiumBloc>().add(PremiumRestoreEvent());
                    },
                    child: Text(
                        FlutterI18n.translate(context, 'restore_purchases')),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Center(
                  child: Text(
                    FlutterI18n.translate(context, 'no_trial'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontSize: 14),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/terms_screen");
                  },
                  child: Text('${FlutterI18n.translate(context, "terms")},',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.merge(
                            TextStyle(color: context.main),
                          )),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/privacy_screen");
                  },
                  child: Text(FlutterI18n.translate(context, "privacy"),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.merge(
                            TextStyle(color: context.main),
                          )),
                ),
              ),
              Center(
                child: Text(
                  FlutterI18n.translate(context, "and"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Center(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/eula_screen");
                      },
                      child: Text(FlutterI18n.translate(context, "eula"),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.merge(
                                TextStyle(color: context.main),
                              )),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const AppLoadingScreen();
        }
      })),
    );
  }
}
