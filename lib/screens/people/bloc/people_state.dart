import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class PeopleState extends Equatable {
  const PeopleState();

  @override
  List<Object> get props => [];
}

class PeopleBaseState extends PeopleState {
  final List<ChatUser> allOnlineUsers;
  final List<ChatUser> filteredUsers;
  final int genderFilterIndex;

  const PeopleBaseState(this.allOnlineUsers, this.filteredUsers, this.genderFilterIndex);

  PeopleBaseState copyWith({
    List<ChatUser>? allOnlineUsers,
    List<ChatUser>? filteredUsers,
    int? genderFilterIndex,
  }) {
    return PeopleBaseState(
      allOnlineUsers ?? this.allOnlineUsers,
      filteredUsers ?? this.filteredUsers,
      genderFilterIndex ?? this.genderFilterIndex,
    );
  }

  @override
  List<Object> get props => [allOnlineUsers, filteredUsers, genderFilterIndex];
}

class PeopleErrorState extends PeopleState {}
class PeopleLoadingState extends PeopleState {}
