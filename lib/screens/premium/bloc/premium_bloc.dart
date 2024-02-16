import 'dart:async';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/premium/bloc/premium_event.dart';
import 'package:chat/screens/premium/bloc/premium_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../repository/subscription_repository.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/log.dart';

class PremiumBloc extends Bloc<PremiumEvent, PremiumState> {
  final FirestoreRepository _firestoreRepository;
  final SubscriptionRepository _subscriptionRepository;
  RewardedAd? _rewardedAd;
  final rewardAmount = 10;

  late Translation translator;

  PremiumBloc(this._firestoreRepository, this._subscriptionRepository)
      : super(const PremiumBaseState(null)) {
    add(PremiumInitialEvent());
  }

  @override
  Future<void> close() {
    _rewardedAd?.dispose();
    return super.close();
  }

  @override
  Stream<PremiumState> mapEventToState(PremiumEvent event) async* {
    final currentState = state;
    try {
      if (event is PremiumInitialEvent) {
        final offerings = await _subscriptionRepository.getOfferings();
        yield PremiumBaseState(offerings?.skus?.firstOrNull);
      } else if (event is PremiumBuyEvent) {
        yield const PremiumLoadingState();
        final sku =
            currentState is PremiumBaseState ? currentState.offerings : null;
        if (sku != null) {
          final isNowPremiumUser = await _subscriptionRepository.purchase(sku);
          await _firestoreRepository.setUserAsPremium(isNowPremiumUser);
          if (isNowPremiumUser) {
            yield const PremiumDoneState();
          } else {
            yield const PremiumErrorState();
          }
        } else {
          yield const PremiumErrorState();
        }
      }else if(event is PremiumRestoreEvent){
        final isNowPremiumUser = await _subscriptionRepository.isPremiumUser();
        await _firestoreRepository.setUserAsPremium(isNowPremiumUser);
        if (isNowPremiumUser) {
          yield const PremiumDoneState();
        } else {
          yield const PremiumNothingRestoreState();
        }
      } else {
        yield const PremiumErrorState();
      }
    } on Exception catch (error, stacktrace) {
      yield const PremiumErrorState();
      Log.e('PremiumErrorState: $error', stackTrace: stacktrace);
    }
  }
}
