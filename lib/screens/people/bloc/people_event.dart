import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class PeopleEvent extends Equatable{
  const PeopleEvent();

  @override
  List<Object> get props => [];
}

class PeopleInitialEvent extends PeopleEvent{}
class PeopleLoadedEvent extends PeopleEvent{
  final List<ChatUser> onlineUser;

  const PeopleLoadedEvent(this.onlineUser);

  @override
  List<Object> get props => [onlineUser];
}

class PeopleFilterEvent extends PeopleEvent{
  final int filter;

  const PeopleFilterEvent(this.filter);

  @override
  List<Object> get props => [filter];
}