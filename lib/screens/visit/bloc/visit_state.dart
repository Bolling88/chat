import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';

abstract class VisitState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitBaseState extends VisitState {
  final ChatUser? user;
  final bool isChatAvailable;
  final bool userLoaded;

  VisitBaseState(this.user, this.isChatAvailable, this.userLoaded);

  VisitBaseState copyWith(
      {ChatUser? user, bool? isChatAvailable, bool? userLoaded}) {
    return VisitBaseState(user ?? this.user,
        isChatAvailable ?? this.isChatAvailable, userLoaded ?? this.userLoaded);
  }

  @override
  List<Object?> get props => [user, isChatAvailable, userLoaded];
}

class VisitLoadingState extends VisitState {}

class VisitMoveToClubState extends VisitState {}
