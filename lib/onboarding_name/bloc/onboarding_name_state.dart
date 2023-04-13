import 'package:equatable/equatable.dart';

import '../../screens/login/bloc/login_state.dart';

abstract class OnboardingNameState extends Equatable {
  const OnboardingNameState();

  @override
  List<Object> get props => [];
}

class OnboardingNameBaseState extends OnboardingNameState {
  final String displayName;

  const OnboardingNameBaseState(this.displayName);

  OnboardingNameBaseState copyWith({String? displayName}) {
    return OnboardingNameBaseState(
        displayName ?? this.displayName);
  }

  @override
  List<Object> get props => [displayName];
}

class OnboardingNameSuccessState extends OnboardingNameState {
  final OnboardingNavigation navigation;

  const OnboardingNameSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
