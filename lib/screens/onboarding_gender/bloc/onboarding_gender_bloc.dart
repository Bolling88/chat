import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/firestore_repository.dart';
import '../../login/bloc/login_state.dart';
import 'onboarding_gender_event.dart';
import 'onboarding_gender_state.dart';

class OnboardingGenderBloc
    extends Bloc<OnboardingGenderEvent, OnboardingGenderState> {
  final FirestoreRepository _firestoreRepository;

  OnboardingGenderBloc(this._firestoreRepository)
      : super(OnboardingGenderLoadingState()) {
    add(OnboardingGenderInitialState());
  }

  @override
  Stream<OnboardingGenderState> mapEventToState(
      OnboardingGenderEvent event) async* {
    if (event is OnboardingGenderInitialState) {
      final user = await _firestoreRepository.getUser();
      yield OnboardingGenderBaseState(user!.pictureData);
    } else if (event is OnboardingGenderMaleClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.male);
      yield const OnboardingGenderSuccessState(OnboardingNavigation.done);
    } else if (event is OnboardingGenderFemaleClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.female);
      yield const OnboardingGenderSuccessState(OnboardingNavigation.done);
    } else if (event is OnboardingGenderNonBinaryClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.nonBinary);
      yield const OnboardingGenderSuccessState(OnboardingNavigation.done);
    } else if (event is OnboardingGenderSecretClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.secret);
      yield const OnboardingGenderSuccessState(OnboardingNavigation.done);
    }
  }
}
