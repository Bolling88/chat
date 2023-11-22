import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object> get props => [];
}

class ReviewInitialEvent extends ReviewEvent {}

class ReviewUsersChangedEvent extends ReviewEvent {
  final List<ChatUser> users;

  const ReviewUsersChangedEvent(this.users);

  @override
  List<Object> get props => [users];
}

class ReviewApproveEvent extends ReviewEvent {
  final ChatUser user;

  const ReviewApproveEvent(this.user);

  @override
  List<Object> get props => [user];
}

class ReviewRejectEvent extends ReviewEvent {
  final ChatUser user;

  const ReviewRejectEvent(this.user);

  @override
  List<Object> get props => [user];
}

