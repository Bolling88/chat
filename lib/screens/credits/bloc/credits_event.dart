import 'package:equatable/equatable.dart';

abstract class CreditsEvent extends Equatable {
  const CreditsEvent();

  @override
  List<Object> get props => [];
}

class CreditsInitialEvent extends CreditsEvent {}
class CreditsShowAdEvent extends CreditsEvent {}
class CreditsAdLoadedEvent extends CreditsEvent {}
class CreditsAdFailedEvent extends CreditsEvent {}
class CreditsAdSuccessEvent extends CreditsEvent {}


