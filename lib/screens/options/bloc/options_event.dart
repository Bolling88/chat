import 'package:equatable/equatable.dart';

abstract class OptionsEvent extends Equatable {
  const OptionsEvent();

  @override
  List<Object> get props => [];
}

class OptionsInitialEvent extends OptionsEvent {}
class OptionsTranslateEvent extends OptionsEvent {
  final String text;

  const OptionsTranslateEvent(this.text);

  @override
  List<Object> get props => [text];
}



