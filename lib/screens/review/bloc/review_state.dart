import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object> get props => [];
}

class ReviewBaseState extends ReviewState {
  final List<ChatUser> users;
  final ChatUser underReview;

  const ReviewBaseState({required this.users, required this.underReview});

  ReviewBaseState copyWith({List<ChatUser>? users, ChatUser? underReview}) {
    return ReviewBaseState(
        users: users ?? this.users,
        underReview: underReview ?? this.underReview);
  }

  @override
  List<Object> get props => [users, underReview];
}

class ReviewLoadingState extends ReviewState {}
class ReviewNothingToApproveState extends ReviewState {}

class ReviewErrorState extends ReviewState {}
