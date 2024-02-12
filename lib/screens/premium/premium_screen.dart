import 'package:chat/repository/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';
import '../../repository/firestore_repository.dart';
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
        }else if(state is PremiumNothingRestoreState){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(FlutterI18n.translate(
                  context, 'no_subscription_to_restore')),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }, child:
          BlocBuilder<PremiumBloc, PremiumState>(builder: (blocContext, state) {
        if (state is PremiumErrorState) {
          return const AppErrorScreen();
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
                        animate: true,
                        fit: BoxFit.cover)),
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
                      Icons.block,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translate(context, 'no_ads'),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.translate,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translate(context, 'free_translation'),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translate(context, 'and_more_to_come'),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontSize: 20),
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
                  '${FlutterI18n.translate(context, 'only')} ${state.offerings?.product?.price} ${state.offerings?.product?.currencyCode} ${FlutterI18n.translate(context, 'per_month')}',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontSize: 20),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
                child: GestureDetector(
                  onTap: () {
                    context.read<PremiumBloc>().add(PremiumBuyEvent());
                  },
                  child: Lottie.asset('assets/lottie/premium_button.json',
                      animate: true),
                ),
              ),
              Center(
                child: SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: TextButton(onPressed: (){
                    context.read<PremiumBloc>().add(PremiumRestoreEvent());
                  }, child: Text(FlutterI18n.translate(context, 'restore_purchases')),),
                )),
              )
            ],
          );
        } else {
          return const AppLoadingScreen();
        }
      })),
    );
  }
}
