import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/firestore_repository.dart';
import 'bloc/app_life_cycle_bloc.dart';
import 'bloc/app_life_cycle_event.dart';

class AppLifecycleScreen extends StatelessWidget {
  static const routeName = "/chat_home";
  final Widget child;

  const AppLifecycleScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          AppLifeCycleBloc(context.read<FirestoreRepository>()),
      child: AppLifecycleScreenContent(
        child: child,
      ),
    );
  }
}

class AppLifecycleScreenContent extends StatefulWidget {
  final Widget child;

  const AppLifecycleScreenContent({super.key, required this.child});

  @override
  State<AppLifecycleScreenContent> createState() =>
      _AppLifecycleScreenContentState();
}

class _AppLifecycleScreenContentState extends State<AppLifecycleScreenContent> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();

    // Initialize the AppLifecycleListener class and pass callbacks
    _listener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
  }

  @override
  void dispose() {
    // Do not forget to dispose the listener
    _listener.dispose();

    super.dispose();
  }

  // Listen to the app lifecycle state changes
  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        BlocProvider.of<AppLifeCycleBloc>(context)
            .add(AppLifeCycleResumedEvent());
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        BlocProvider.of<AppLifeCycleBloc>(context)
            .add(AppLifeCyclePausedEvent());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
