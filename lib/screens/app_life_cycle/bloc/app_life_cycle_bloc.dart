import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universal_io/io.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import 'app_life_cycle_event.dart';
import 'app_life_cycle_state_state.dart';

class AppLifeCycleBloc extends Bloc<AppLifeCycleEvent, AppLifeCycleState> {
  final FirestoreRepository _firestoreRepository;
  AppOpenAd? _appOpenAd;
  StreamSubscription<QuerySnapshot>? userStream;
  ChatUser? _user;

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
  Future<void> close() {
    userStream?.cancel();
    userStream = null;
    return super.close();
  }

  @override
  Stream<AppLifeCycleState> mapEventToState(AppLifeCycleEvent event) async* {
    if (event is AppLifeCycleInitialEvent) {
      _setUpUserListener();
    } else if (event is AppLifeCycleResumedEvent) {
      _showAdIfAvailable();
      _firestoreRepository.setUserAsActive();
    } else if (event is AppLifeCyclePausedEvent) {
      if (!kIsWeb && _user?.isPremiumUser != true) {
          _loadAd();
      }
    } else {
      throw UnimplementedError();
    }
  }

  void _setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository.streamUser().listen((event) async {
      if (event.docs.isEmpty) {
        return;
      }

      final Map<String, dynamic> userData =
      event.docs.first.data() as Map<String, dynamic>;

      // Convert Timestamp to int (milliseconds since epoch)
      if (userData.containsKey('lastActive') &&
          userData['lastActive'] is Timestamp) {
        userData['lastActive'] =
            (userData['lastActive'] as Timestamp).millisecondsSinceEpoch;
      }

      _user = ChatUser.fromJson(event.docs.first.id, userData);
    });
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
