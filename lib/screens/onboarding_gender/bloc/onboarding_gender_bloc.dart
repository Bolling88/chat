import 'package:chat/model/chat_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/supabase_repository.dart';
import '../../../utils/enums.dart';
import '../../login/bloc/login_state.dart';
import 'onboarding_gender_event.dart';
import 'onboarding_gender_state.dart';

class OnboardingGenderBloc
    extends Bloc<OnboardingGenderEvent, OnboardingGenderState> {
  final SupabaseRepository _supabaseRepository;

  late ChatUser user;

  OnboardingGenderBloc(this._supabaseRepository)
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
    user = (await _supabaseRepository.getUser())!;
    emit(OnboardingGenderBaseState(user.pictureData));
  }

  void _onMaleClicked(
    OnboardingGenderMaleClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _supabaseRepository.updateUserGender(Gender.male);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }

  void _onFemaleClicked(
    OnboardingGenderFemaleClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _supabaseRepository.updateUserGender(Gender.female);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }

  void _onNonBinaryClicked(
    OnboardingGenderNonBinaryClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _supabaseRepository.updateUserGender(Gender.nonBinary);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }

  void _onSecretClicked(
    OnboardingGenderSecretClickedEvent event,
    Emitter<OnboardingGenderState> emit,
  ) {
    _supabaseRepository.updateUserGender(Gender.secret);
    emit(OnboardingGenderSuccessState(OnboardingNavigation.done, user));
  }
}
