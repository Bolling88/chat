import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';

abstract class FullScreenImageState extends Equatable {
  @override
  List<Object> get props => [];
}

class FullScreenImageBaseState extends FullScreenImageState {
  final bool shouldBlur;

  FullScreenImageBaseState(this.shouldBlur);

  @override
  List<Object> get props => [shouldBlur];
}
