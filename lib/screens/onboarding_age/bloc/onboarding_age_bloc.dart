import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/firestore_repository.dart';
import '../../login/bloc/login_state.dart';
import 'onboarding_age_event.dart';
import 'onboarding_age_state.dart';

class OnboardingAgeBloc extends Bloc<OnboardingAgeEvent, OnboardingAgeState> {
  final FirestoreRepository _firestoreRepository;

  OnboardingAgeBloc(this._firestoreRepository)
      : super(OnboardingAgeLoadingState()) {
    on<OnboardingAgeInitialEvent>(_onInitial);
    on<OnboardingAgeChangedEvent>(_onAgeChanged);
    on<OnboardingAgeContinueClickedEvent>(_onContinueClicked);

    add(OnboardingAgeInitialEvent());
  }

  Future<void> _onInitial(
    OnboardingAgeInitialEvent event,
    Emitter<OnboardingAgeState> emit,
  ) async {
    final user = await _firestoreRepository.getUser();
    emit(OnboardingAgeBaseState(
      user?.birthDate?.toDate() ?? DateTime(2000, 1, 1),
      false,
      user?.displayName ?? '',
    ));
  }

  void _onAgeChanged(
    OnboardingAgeChangedEvent event,
    Emitter<OnboardingAgeState> emit,
  ) {
    final currentState = state;
    if (currentState is OnboardingAgeBaseState) {
      emit(currentState.copyWith(
        birthDate: event.date,
        showInvalidAgeError: false,
      ));
    }
  }

  Future<void> _onContinueClicked(
    OnboardingAgeContinueClickedEvent event,
    Emitter<OnboardingAgeState> emit,
  ) async {
    final currentState = state;
    if (currentState is OnboardingAgeBaseState) {
      //Check if the user is above 18 years old
      final now = DateTime.now();
      final difference = now.difference(currentState.birthDate);
      //18 years
      if (difference.inDays < 6570) {
        emit(currentState.copyWith(showInvalidAgeError: true));
      } else {
        _firestoreRepository.updateUserBirthday(currentState.birthDate);
        final chatUser = await _firestoreRepository.getUser();
        if (chatUser?.pictureData.isEmpty == true) {
          emit(const OnboardingAgeSuccessState(OnboardingNavigation.picture));
        } else if (chatUser?.gender == -1) {
          emit(const OnboardingAgeSuccessState(OnboardingNavigation.gender));
        } else {
          emit(const OnboardingAgeSuccessState(OnboardingNavigation.done));
        }
      }
    }
  }
}
