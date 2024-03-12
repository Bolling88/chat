import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';
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
  final ChatUser user;

  const OnboardingGenderSuccessState(this.navigation, this.user);

  @override
  List<Object> get props => [navigation, user];
}
