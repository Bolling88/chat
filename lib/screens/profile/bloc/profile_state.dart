import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileBaseState extends ProfileState {
  final String name;

  const ProfileBaseState({required this.name});

  ProfileBaseState copyWith({String? name}) {
    return ProfileBaseState(name: name ?? this.name);
  }

  @override
  List<Object> get props => [name];
}

class ProfileLoadingState extends ProfileState {}
class ProfileLogoutState extends ProfileState {}
class ProfileErrorState extends ProfileState {}
