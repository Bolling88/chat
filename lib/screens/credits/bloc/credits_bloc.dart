import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:universal_io/io.dart';
import '../../../model/chat_user.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/log.dart';
import 'credits_event.dart';
import 'credits_state.dart';

class CreditsBloc extends Bloc<CreditsEvent, CreditsState> {
  final FirestoreRepository _firestoreRepository;
  RewardedAd? _rewardedAd;
  final rewardAmount = 10;
  final ChatUser _user;

  late Translation translator;

  CreditsBloc(this._firestoreRepository, this._user)
      : super(const CreditsBaseState()) {
    add(CreditsInitialEvent());
  }

  @override
  Future<void> close() {
    _rewardedAd?.dispose();
    return super.close();
  }

  @override
  Stream<CreditsState> mapEventToState(CreditsEvent event) async* {
    try {
      if (event is CreditsInitialEvent) {
        yield const CreditsBaseState();
      } else if (event is CreditsShowAdEvent) {
        yield CreditsLoadingState();
        loadAd();
      } else if (event is CreditsAdLoadedEvent) {
        _rewardedAd?.show(onUserEarnedReward:
            (AdWithoutView ad, RewardItem rewardItem) async {
          await _firestoreRepository.increaseUserCredits(
              getUserId(), rewardAmount);
        });
      } else if (event is CreditsAdFailedEvent) {
        //For now the user will still get rewarded, due to fill rates might be low
        //yield const CreditsFailedState();
        if (_user.kvitterCredits < 1) {
          //If he has no credits, we give him some
          await _firestoreRepository.increaseUserCredits(
              getUserId(), rewardAmount);
        }
        add(CreditsAdSuccessEvent());
      } else if (event is CreditsAdSuccessEvent) {
        yield const CreditsSuccessState();
      }
    } on Exception catch (error, stacktrace) {
      yield CreditsErrorState();
      Log.e('CreditsErrorState: $error', stackTrace: stacktrace);
    }
  }

  final adUnitId = Platform.isAndroid
      ? kDebugMode
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-5287847424239288/7721457165'
      : kDebugMode
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-5287847424239288/4903722138';

  /// Loads a rewarded ad.
  void loadAd() {
    RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                onAdImpression: (ad) {},
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                  add(CreditsAdFailedEvent());
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                  add(CreditsAdSuccessEvent());
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _rewardedAd = ad;
            add(CreditsAdLoadedEvent());
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            Log.e('RewardedAd failed to load: $error');
            add(CreditsAdFailedEvent());
          },
        ));
  }
}
