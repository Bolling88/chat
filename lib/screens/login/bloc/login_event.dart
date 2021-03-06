import 'package:equatable/equatable.dart';

class LoginEvent extends Equatable{

  const LoginEvent();

  @override
  List<Object> get props => [];

}

class LoginFacebookClickedEvent extends LoginEvent{}
class LoginGoogleClickedEvent extends LoginEvent{}
class LoginAppleClickedEvent extends LoginEvent{}

class LoginFailedEvent extends LoginEvent{}

class FacebookLoggedInEvent extends LoginEvent{
  final String result;

  FacebookLoggedInEvent(this.result);

  @override
  List<Object> get props => [result];
}