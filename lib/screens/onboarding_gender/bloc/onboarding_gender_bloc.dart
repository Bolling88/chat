import 'package:chat/model/chat_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/firestore_repository.dart';
import '../../login/bloc/login_state.dart';
import 'onboarding_gender_event.dart';
import 'onboarding_gender_state.dart';

class OnboardingGenderBloc
    extends Bloc<OnboardingGenderEvent, OnboardingGenderState> {
  final FirestoreRepository _firestoreRepository;

  late ChatUser user;

  OnboardingGenderBloc(this._firestoreRepository)
      : super(OnboardingGenderLoadingState()) {
    add(OnboardingGenderInitialState());
  }

  @override
  Stream<OnboardingGenderState> mapEventToState(
      OnboardingGenderEvent event) async* {
    if (event is OnboardingGenderInitialState) {
      user = (await _firestoreRepository.getUser())!;
      yield OnboardingGenderBaseState(user.pictureData);
    } else if (event is OnboardingGenderMaleClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.male);
      yield OnboardingGenderSuccessState(OnboardingNavigation.done, user);
    } else if (event is OnboardingGenderFemaleClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.female);
      yield OnboardingGenderSuccessState(OnboardingNavigation.done, user);
    } else if (event is OnboardingGenderNonBinaryClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.nonBinary);
      yield OnboardingGenderSuccessState(OnboardingNavigation.done, user);
    } else if (event is OnboardingGenderSecretClickedEvent) {
      _firestoreRepository.updateUserGender(Gender.secret);
      yield OnboardingGenderSuccessState(OnboardingNavigation.done, user);
    }
  }
}
