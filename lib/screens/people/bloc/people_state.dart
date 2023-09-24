import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class PeopleState extends Equatable {
  const PeopleState();

  @override
  List<Object> get props => [];
}

class PeopleBaseState extends PeopleState {
  final List<ChatUser> onlineUser;

  const PeopleBaseState(this.onlineUser);

  @override
  List<Object> get props => [onlineUser];
}

class PeopleErrorState extends PeopleState {}
class PeopleLoadingState extends PeopleState {}
