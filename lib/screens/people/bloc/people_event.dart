import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class PeopleEvent extends Equatable{
  const PeopleEvent();

  @override
  List<Object> get props => [];
}

class PeopleInitialEvent extends PeopleEvent{}
class PeopleLoadedEvent extends PeopleEvent{
  final List<ChatUser> chatUsers;

  const PeopleLoadedEvent(this.chatUsers);

  @override
  List<Object> get props => [chatUsers];
}