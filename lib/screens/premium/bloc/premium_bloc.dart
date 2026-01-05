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
      : super(const PremiumLoadingState()) {
    on<PremiumInitialEvent>(_onPremiumInitialEvent);
    on<PremiumBuyEvent>(_onPremiumBuyEvent);
    on<PremiumRestoreEvent>(_onPremiumRestoreEvent);

    add(PremiumInitialEvent());
  }

  @override
  Future<void> close() {
    _rewardedAd?.dispose();
    return super.close();
  }

  Future<void> _onPremiumInitialEvent(
    PremiumInitialEvent event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final offerings = await _subscriptionRepository.getOfferings();
      if (offerings != null) {
        final package = offerings
            .getOffering('kvitter_premium')
            ?.availablePackages
            .firstOrNull;
        if (package != null) {
          emit(PremiumBaseState(package));
        } else {
          emit(const PremiumErrorState());
        }
      } else {
        emit(const PremiumErrorState());
      }
    } on Exception catch (error, stacktrace) {
      emit(const PremiumErrorState());
      Log.e('PremiumErrorState: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onPremiumBuyEvent(
    PremiumBuyEvent event,
    Emitter<PremiumState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is PremiumBaseState) {
        emit(const PremiumLoadingState());
        final isNowPremiumUser = await _subscriptionRepository.purchase(event.package);
        await _firestoreRepository.setUserAsPremium(isNowPremiumUser);
        if (isNowPremiumUser) {
          emit(const PremiumDoneState());
        } else {
          emit(PremiumAbortedState(currentState.package));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(const PremiumErrorState());
      Log.e('PremiumErrorState: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onPremiumRestoreEvent(
    PremiumRestoreEvent event,
    Emitter<PremiumState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is PremiumBaseState) {
        final isNowPremiumUser =
            await _subscriptionRepository.restorePurchases();
        await _firestoreRepository.setUserAsPremium(isNowPremiumUser);
        if (isNowPremiumUser) {
          emit(const PremiumDoneState());
        } else {
          emit(PremiumNothingRestoreState(currentState.package));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(const PremiumErrorState());
      Log.e('PremiumErrorState: $error', stackTrace: stacktrace);
    }
  }
}
