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

  const OnboardingAgeBaseState(this.birthDate, this.showInvalidAgeError);

  @override
  List<Object> get props => [birthDate, showInvalidAgeError];

  OnboardingAgeBaseState copyWith(
      {DateTime? birthDate, bool? showInvalidAgeError}) {
    return OnboardingAgeBaseState(birthDate ?? this.birthDate,
        showInvalidAgeError ?? this.showInvalidAgeError);
  }
}

class OnboardingAgeLoadingState extends OnboardingAgeState {}

class OnboardingAgeSuccessState extends OnboardingAgeState {
  final OnboardingNavigation navigation;

  const OnboardingAgeSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
