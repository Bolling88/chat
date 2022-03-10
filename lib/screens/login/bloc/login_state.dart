import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable{
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginBaseState extends LoginState{}
class LoginErrorState extends LoginState{}
