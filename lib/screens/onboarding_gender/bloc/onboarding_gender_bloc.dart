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
    on<OnboardingGenderInitialState>(_onInitial);
    on<OnboardingGenderMaleClickedEvent>(_onMaleClicked);
    on<OnboardingGenderFemaleClickedEvent>(_onFemaleClicked);
    on<OnboardingGenderNonBinaryClickedEvent>(_onNonBinaryClicked);
    on<OnboardingGenderSecretClickedEvent>(_onSecretClicked);

    add(OnboardingGenderInitialState());
  }

  Future<void> _onInitial(
    OnboardingGenderInitialState event,
    Emitter<OnboardingGenderState> emit,
  ) async {
    user = (await _firestoreRepository.getUser())!;
    emit(OnboardingGenderBaseState(user.pictureData));
  }

  void _onMaleClicked(
    OnboardingGenderMaleClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _firestoreRepository.updateUserGender(Gender.male);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }

  void _onFemaleClicked(
    OnboardingGenderFemaleClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _firestoreRepository.updateUserGender(Gender.female);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }

  void _onNonBinaryClicked(
    OnboardingGenderNonBinaryClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _firestoreRepository.updateUserGender(Gender.nonBinary);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }

  void _onSecretClicked(
    OnboardingGenderSecretClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _firestoreRepository.updateUserGender(Gender.secret);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }
}
