import 'package:equatable/equatable.dart';

abstract class CreateChatEvent extends Equatable {
  const CreateChatEvent();

  @override
  List<Object> get props => [];
}

class CreateChatInitialEvent extends CreateChatEvent {}

class CreateChatNameChangedEvent extends CreateChatEvent {
  final String name;

  const CreateChatNameChangedEvent(this.name);

  @override
  List<Object> get props => [name];
}
