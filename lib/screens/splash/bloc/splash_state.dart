import 'package:equatable/equatable.dart';

import '../../login/bloc/login_state.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashBaseState extends SplashState {}

class SplashLoginState extends SplashState {}

class SplashSuccessState extends SplashState {
  final OnboardingNavigation navigation;

  const SplashSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}

class SplashErrorState extends SplashState {}
