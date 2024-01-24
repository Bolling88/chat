import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universal_io/io.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/log.dart';
import '../../options/bloc/options_event.dart';
import 'credits_event.dart';
import 'credits_state.dart';

class CreditsBloc extends Bloc<CreditsEvent, CreditsState> {
  final FirestoreRepository _firestoreRepository;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  late Translation translator;

  CreditsBloc(this._firestoreRepository) : super(CreditsBaseState()) {
    add(CreditsInitialEvent());
  }

  @override
  Stream<CreditsState> mapEventToState(CreditsEvent event) async* {
    final currentState = state;
    try {
      if (event is CreditsInitialEvent) {
        yield const CreditsBaseState();
      }else if(event is CreditsShowAdEvent) {
        yield CreditsLoadingState();
        _rewardedInterstitialAd?.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
          _firestoreRepository.increaseUserCredits(getUserId(), rewardItem.amount.toInt());
          add(CreditsAdSuccessEvent());
        });
      }else if(event is CreditsAdFailedEvent) {
        yield const CreditsFailedState();
      }else if(event is CreditsAdSuccessEvent) {
        yield const CreditsSuccessState();
      }
    } on Exception catch (error, stacktrace) {
      yield CreditsErrorState();
      Log.e('CreditsErrorState: $error', stackTrace: stacktrace);
    }
  }

  final adUnitId = Platform.isAndroid
      ? kDebugMode? 'ca-app-pub-3940256099942544/5354046379' : 'ca-app-pub-5287847424239288/7721457165'
      : kDebugMode? 'ca-app-pub-3940256099942544/6978759866' : 'ca-app-pub-5287847424239288/4903722138';

  /// Loads a rewarded ad.
  void loadAd() {
    RewardedInterstitialAd.load(
        adUnitId: adUnitId,
         request: const AdRequest(), rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
      // Called when an ad is successfully received.
      onAdLoaded: (ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          // Called when the ad showed the full screen content.
            onAdShowedFullScreenContent: (ad) {},
            onAdImpression: (ad) {
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              add(CreditsAdFailedEvent());
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
            },
            // Called when a click is recorded for an ad.
            onAdClicked: (ad) {});
        debugPrint('$ad loaded.');
        // Keep a reference to the ad so you can show it later.
        _rewardedInterstitialAd = ad;
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (LoadAdError error) {
        debugPrint('RewardedInterstitialAd failed to load: $error');
      },
    ));
  }

}
