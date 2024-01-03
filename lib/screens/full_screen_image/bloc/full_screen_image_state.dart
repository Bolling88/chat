import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';

abstract class FullScreenImageState extends Equatable {
  @override
  List<Object> get props => [];
}

class FullScreenImageBaseState extends FullScreenImageState {
  final bool shouldBlur;
  final bool showHideButton;

  FullScreenImageBaseState(this.shouldBlur, this.showHideButton);

  @override
  List<Object> get props => [shouldBlur];
}
