import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable{
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeBaseState extends HomeState{}
class HomeErrorState extends HomeState{}
