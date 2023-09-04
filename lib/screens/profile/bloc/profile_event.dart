import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileInitialEvent extends ProfileEvent {}
class ProfileDeleteAccountEvent extends ProfileEvent {}
class ProfileLogoutEvent extends ProfileEvent {}
class ProfileContinueClickedEvent extends ProfileEvent {}

class ProfileNameChangedEvent extends ProfileEvent {
  final String name;

  const ProfileNameChangedEvent(this.name);

  @override
  List<Object> get props => [name];
}
