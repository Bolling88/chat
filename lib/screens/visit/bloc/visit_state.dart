import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';

abstract class VisitState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VisitBaseState extends VisitState {
  final ChatUser? user;
  final ChatUser myUser;
  final bool isChatAvailable;
  final bool userLoaded;
  final bool userBlocked;
  final String message;

  VisitBaseState({
    required this.user,
    required this.myUser,
    required this.isChatAvailable,
    required this.userLoaded,
    required this.userBlocked,
    required this.message,
  });

  VisitBaseState copyWith({
    ChatUser? user,
    ChatUser? myUser,
    bool? isChatAvailable,
    bool? userLoaded,
    bool? userBlocked,
    String? message,
  }) {
    return VisitBaseState(
      user: user ?? this.user,
      myUser: myUser ?? this.myUser,
      isChatAvailable: isChatAvailable ?? this.isChatAvailable,
      userLoaded: userLoaded ?? this.userLoaded,
      userBlocked: userBlocked ?? this.userBlocked,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [user, myUser, isChatAvailable, userLoaded, message];
}

class VisitLoadingState extends VisitState {}
