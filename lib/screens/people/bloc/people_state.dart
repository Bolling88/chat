import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class PeopleState extends Equatable {
  const PeopleState();

  @override
  List<Object> get props => [];
}

class PeopleBaseState extends PeopleState {
  final List<ChatUser> chatUsers;

  const PeopleBaseState(this.chatUsers);

  @override
  List<Object> get props => [chatUsers];
}

class PeopleErrorState extends PeopleState {}
class PeopleLoadingState extends PeopleState {}
