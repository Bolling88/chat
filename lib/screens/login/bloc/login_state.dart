import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginBaseState extends LoginState {}

class LoginLoadingState extends LoginState {}

class LoginSuccessState extends LoginState {
  final OnboardingNavigation navigation;

  const LoginSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}

class LoginErrorState extends LoginState {}

class LoginAbortedState extends LoginState {}

enum OnboardingNavigation { DONE, PICTURE, NAME, GENDER }
