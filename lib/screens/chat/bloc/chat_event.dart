import 'package:equatable/equatable.dart';
import '../../../model/room_chat.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitialEvent extends ChatEvent {}

class ChatUpdatedEvent extends ChatEvent {
  final List<RoomChat> chats;

  ChatUpdatedEvent(this.chats);

  @override
  List<Object?> get props => [chats];
}
