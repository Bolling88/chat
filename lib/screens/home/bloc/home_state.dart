import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable{
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeBaseState extends HomeState{
  final int selectedChat;

  HomeBaseState(this.selectedChat);
}
class HomeLoadingState extends HomeState{}
class HomeErrorState extends HomeState{}
