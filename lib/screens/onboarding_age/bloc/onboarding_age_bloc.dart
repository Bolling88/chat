import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/firestore_repository.dart';
import '../../login/bloc/login_state.dart';
import 'onboarding_age_event.dart';
import 'onboarding_age_state.dart';

class OnboardingAgeBloc extends Bloc<OnboardingAgeEvent, OnboardingAgeState> {
  final FirestoreRepository _firestoreRepository;

  OnboardingAgeBloc(this._firestoreRepository)
      : super(OnboardingAgeBaseState(DateTime(2000, 1, 1), false));

  @override
  Stream<OnboardingAgeState> mapEventToState(OnboardingAgeEvent event) async* {
    final currentState = state;
    if (event is OnboardingAgeChangedEvent) {
      if (currentState is OnboardingAgeBaseState) {
        yield currentState.copyWith(
          birthDate: event.date,
          showInvalidAgeError: false,
        );
      }
    } else if (event is OnboardingAgeContinueClickedEvent) {
      if (currentState is OnboardingAgeBaseState) {
        //Check if the user is above 18 years old
        final now = DateTime.now();
        final difference = now.difference(currentState.birthDate);
        //18 years
        if (difference.inDays < 6570) {
          yield currentState.copyWith(showInvalidAgeError: true);
        } else {
          _firestoreRepository.updateUserBirthday(currentState.birthDate);
          final chatUser = await _firestoreRepository.getUser();
          if (chatUser?.pictureData.isEmpty == true) {
            yield const OnboardingAgeSuccessState(OnboardingNavigation.PICTURE);
          } else if (chatUser?.gender == -1) {
            yield const OnboardingAgeSuccessState(OnboardingNavigation.GENDER);
          } else {
            yield const OnboardingAgeSuccessState(OnboardingNavigation.DONE);
          }
        }
      }
    }
  }
}
