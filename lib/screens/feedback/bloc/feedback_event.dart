import 'package:equatable/equatable.dart';

abstract class FeedbackEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FeedbackInitialEvent extends FeedbackEvent {}
class FeedbackSendEvent extends FeedbackEvent {
  final String feedback;

  FeedbackSendEvent(this.feedback);

  @override
  List<Object> get props => [feedback];
}