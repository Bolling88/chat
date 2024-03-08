import 'package:equatable/equatable.dart';

abstract class AppLifeCycleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppLifeCycleBaseState extends AppLifeCycleState {}
