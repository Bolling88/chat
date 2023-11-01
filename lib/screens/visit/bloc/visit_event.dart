import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class VisitEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitInitialEvent extends VisitEvent {}
class VisitBlocUserEvent extends VisitEvent {}
class VisitUnblocUserEvent extends VisitEvent {}

class VisitUserLoadedState extends VisitEvent {
  final ChatUser? user;

  VisitUserLoadedState(this.user);

  @override
  List<Object?> get props => [user];

}

class VisitTextChangedEvent extends VisitEvent {
  final String message;

  VisitTextChangedEvent(this.message);

  @override
  List<Object?> get props => [message];

}