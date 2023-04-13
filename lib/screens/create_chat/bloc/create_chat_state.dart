import 'package:equatable/equatable.dart';

abstract class CreateChatState extends Equatable {
  const CreateChatState();

  @override
  List<Object> get props => [];
}

class CreateChatBaseState extends CreateChatState {
  final String name;

  const CreateChatBaseState({required this.name});

  CreateChatBaseState copyWith({String? name}) {
    return CreateChatBaseState(name: name ?? this.name);
  }

  @override
  List<Object> get props => [name];
}

class CreateChatSuccessState extends CreateChatBaseState {
  const CreateChatSuccessState({required super.name});
}

class CreateChatErrorState extends CreateChatState {}
