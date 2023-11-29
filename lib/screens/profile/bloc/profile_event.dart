import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileInitialEvent extends ProfileEvent {}
class ProfileUserChangedEvent extends ProfileEvent {
  final ChatUser user;

  const ProfileUserChangedEvent(this.user);

  @override
  List<Object> get props => [user];
}
