import 'package:equatable/equatable.dart';

import '../../screens/login/bloc/login_state.dart';

abstract class OnboardingNameState extends Equatable {
  const OnboardingNameState();

  @override
  List<Object> get props => [];
}

class OnboardingNameBaseState extends OnboardingNameState {
  final String firstName;
  final String lastName;

  const OnboardingNameBaseState(this.firstName, this.lastName);

  OnboardingNameBaseState copyWith({String? firstName, String? lastName}) {
    return OnboardingNameBaseState(
        firstName ?? this.firstName, lastName ?? this.lastName);
  }

  @override
  List<Object> get props => [firstName, lastName];
}

class OnboardingNameSuccessState extends OnboardingNameState {
  final OnboardingNavigation navigation;

  const OnboardingNameSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
