import 'package:equatable/equatable.dart';


abstract class FullScreenImageEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FullScreenImageInitialEvent extends FullScreenImageEvent {}
class FullScreenImageUnblurEvent extends FullScreenImageEvent {}
