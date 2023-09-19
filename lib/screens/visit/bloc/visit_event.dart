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