import 'package:equatable/equatable.dart';

import '../../login/bloc/login_state.dart';

abstract class OnboardingGenderState extends Equatable {
  const OnboardingGenderState();

  @override
  List<Object> get props => [];
}

class OnboardingGenderBaseState extends OnboardingGenderState {
  final String filePath;

  const OnboardingGenderBaseState(this.filePath);

  OnboardingGenderBaseState copyWith({String? filePath}) {
    return OnboardingGenderBaseState(filePath ?? this.filePath);
  }

  @override
  List<Object> get props => [filePath];
}

class OnboardingGenderLoadingState extends OnboardingGenderState{}

class OnboardingGenderSuccessState extends OnboardingGenderState {
  final OnboardingNavigation navigation;

  const OnboardingGenderSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
