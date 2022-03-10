import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashBaseState extends SplashState {}

class SplashLoginState extends SplashState {}

class SplashSuccessState extends SplashState {}

class SplashErrorState extends SplashState {}
