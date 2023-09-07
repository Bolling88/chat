import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileBaseState extends ProfileState {
  final ChatUser user;

  const ProfileBaseState({required this.user});

  ProfileBaseState copyWith({ChatUser? user}) {
    return ProfileBaseState(user: user ?? this.user);
  }

  @override
  List<Object> get props => [user];
}

class ProfileLoadingState extends ProfileState {}

class ProfileLogoutState extends ProfileState {}

class ProfileErrorState extends ProfileState {}
