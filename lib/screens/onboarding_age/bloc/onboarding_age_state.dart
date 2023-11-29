import 'package:equatable/equatable.dart';

import '../../login/bloc/login_state.dart';

abstract class OnboardingAgeState extends Equatable {
  const OnboardingAgeState();

  @override
  List<Object> get props => [];
}

class OnboardingAgeBaseState extends OnboardingAgeState {
  final DateTime birthDate;
  final bool showInvalidAgeError;
  final String displayName;

  const OnboardingAgeBaseState(
      this.birthDate, this.showInvalidAgeError, this.displayName);

  @override
  List<Object> get props => [birthDate, showInvalidAgeError, displayName];

  OnboardingAgeBaseState copyWith(
      {DateTime? birthDate, bool? showInvalidAgeError, String? displayName}) {
    return OnboardingAgeBaseState(
        birthDate ?? this.birthDate,
        showInvalidAgeError ?? this.showInvalidAgeError,
        displayName ?? this.displayName);
  }
}

class OnboardingAgeLoadingState extends OnboardingAgeState {}

class OnboardingAgeSuccessState extends OnboardingAgeState {
  final OnboardingNavigation navigation;

  const OnboardingAgeSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
