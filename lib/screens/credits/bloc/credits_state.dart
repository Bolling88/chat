import 'package:equatable/equatable.dart';


abstract class CreditsState extends Equatable {
  const CreditsState();

  @override
  List<Object> get props => [];
}

class CreditsBaseState extends CreditsState {

  const CreditsBaseState();

  @override
  List<Object> get props => [];
}

class CreditsSuccessState extends CreditsState {

  const CreditsSuccessState();

  @override
  List<Object> get props => [];
}

class CreditsFailedState extends CreditsState {

  const CreditsFailedState();

  @override
  List<Object> get props => [];
}

class CreditsLoadingState extends CreditsState {}

class CreditsErrorState extends CreditsState {}
