import 'package:equatable/equatable.dart';

import '../../login/bloc/login_state.dart';

abstract class OnboardingNameState extends Equatable {
  const OnboardingNameState();

  @override
  List<Object> get props => [];
}

class OnboardingNameBaseState extends OnboardingNameState {
  final String displayName;
  final bool isValidatingName;
  final bool isNameTaken;

  const OnboardingNameBaseState(
      this.displayName, this.isValidatingName, this.isNameTaken);

  OnboardingNameBaseState copyWith(
      {String? displayName, bool? isValidatingName, bool? isNameTaken}) {
    return OnboardingNameBaseState(
        displayName ?? this.displayName,
        isValidatingName ?? this.isValidatingName,
        isNameTaken ?? this.isNameTaken);
  }

  @override
  List<Object> get props => [displayName, isValidatingName, isNameTaken];
}

class OnboardingNameSuccessState extends OnboardingNameState {
  final OnboardingNavigation navigation;

  const OnboardingNameSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
