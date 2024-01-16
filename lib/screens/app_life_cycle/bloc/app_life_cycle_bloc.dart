import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_io/io.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import 'app_life_cycle_event.dart';
import 'app_life_cycle_state_state.dart';

class AppLifeCycleBloc extends Bloc<AppLifeCycleEvent, AppLifeCycleState> {
  final FirestoreRepository _firestoreRepository;
  AppOpenAd? _appOpenAd;

  String adUnitId = Platform.isAndroid
      ? kDebugMode
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-5287847424239288/1917644338'
      : kDebugMode
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-5287847424239288/5933066490';

  AppLifeCycleBloc(this._firestoreRepository) : super(AppLifeCycleBaseState()) {
    add(AppLifeCycleInitialEvent());
  }

  @override
  Stream<AppLifeCycleState> mapEventToState(AppLifeCycleEvent event) async* {
    final currentState = state;
    if (event is AppLifeCycleInitialEvent) {
    } else if (event is AppLifeCycleResumedEvent) {
      _showAdIfAvailable();
      _firestoreRepository.setUserAsActive();
    } else if (event is AppLifeCyclePausedEvent) {
      if (!kIsWeb) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final int appOpens = prefs.getInt('app_opens') ?? 0;
        if(appOpens > 4) {
          _loadAd();
        }
      }
    } else {
      throw UnimplementedError();
    }
  }

  void _loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
      orientation: AppOpenAd.orientationPortrait,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          Log.e('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
      request: const AdRequest(),
    );
  }

  void _showAdIfAvailable() {
    if (_appOpenAd != null) {
      _appOpenAd?.show();
      _appOpenAd = null;
    }
  }
}
