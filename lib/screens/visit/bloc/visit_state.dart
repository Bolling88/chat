import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';

abstract class VisitState extends Equatable {
  @override
  List<Object> get props => [];
}

class VisitBaseState extends VisitState {
  final ChatUser user;

  VisitBaseState(this.user);

  VisitBaseState copyWith({ChatUser? user}) {
    return VisitBaseState(user ?? this.user);
  }

  @override
  List<Object> get props => [
        user,
      ];
}

class VisitLoadingState extends VisitState {}

class VisitMoveToClubState extends VisitState {}
