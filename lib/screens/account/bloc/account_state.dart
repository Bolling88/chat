import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object> get props => [];
}

class AccountBaseState extends AccountState {
  final ChatUser user;

  const AccountBaseState({required this.user});

  AccountBaseState copyWith({ChatUser? user}) {
    return AccountBaseState(user: user ?? this.user);
  }

  @override
  List<Object> get props => [user];
}

class AccountLoadingState extends AccountState {}

class AccountLogoutState extends AccountState {}

class AccountErrorState extends AccountState {}