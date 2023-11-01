import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';

abstract class FeedbackState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FeedbackBaseState extends FeedbackState {}
