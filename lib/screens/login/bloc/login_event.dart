import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginGoogleClickedEvent extends LoginEvent {}

class LoginAppleClickedEvent extends LoginEvent {}

class LoginFailedEvent extends LoginEvent {}