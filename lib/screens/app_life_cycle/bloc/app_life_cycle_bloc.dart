import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universal_io/io.dart';
import '../../../model/chat_user.dart';
import '../../../repository/supabase_repository.dart';
import '../../../utils/log.dart';
import 'app_life_cycle_event.dart';
import 'app_life_cycle_state_state.dart';

class AppLifeCycleBloc extends Bloc<AppLifeCycleEvent, AppLifeCycleState> {
  final SupabaseRepository _supabaseRepository;
  AppOpenAd? _appOpenAd;
  StreamSubscription<ChatUser?>? userStream;
  ChatUser? _user;

  String adUnitId = Platform.isAndroid
      ? kDebugMode
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-5287847424239288/1917644338'
      : kDebugMode
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-5287847424239288/5933066490';

  AppLifeCycleBloc(this._supabaseRepository) : super(AppLifeCycleBaseState()) {
    on<AppLifeCycleInitialEvent>(_onInitialEvent);
    on<AppLifeCycleResumedEvent>(_onResumedEvent);
    on<AppLifeCyclePausedEvent>(_onPausedEvent);

    add(AppLifeCycleInitialEvent());
  }

  @override
  Future<void> close() {
    userStream?.cancel();
    userStream = null;
    return super.close();
  }

  void _onInitialEvent(
    AppLifeCycleInitialEvent event,
    Emitter<AppLifeCycleState> emit,
  ) {
    _setUpUserListener();
  }

  void _onResumedEvent(
    AppLifeCycleResumedEvent event,
    Emitter<AppLifeCycleState> emit,
  ) {
    _showAdIfAvailable();
    _supabaseRepository.setUserAsActive();
  }

  void _onPausedEvent(
    AppLifeCyclePausedEvent event,
    Emitter<AppLifeCycleState> emit,
  ) {
    if (!kIsWeb && _user?.isPremiumUser != true) {
      _loadAd();
    }
  }

  void _setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _supabaseRepository.streamUser().listen((user) async {
      if (user == null) return;
      _user = user;
    });
  }

  void _loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
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
