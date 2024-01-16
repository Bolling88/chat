import 'package:equatable/equatable.dart';


abstract class AppLifeCycleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppLifeCycleInitialEvent extends AppLifeCycleEvent {}

class AppLifeCyclePausedEvent extends AppLifeCycleEvent {}
class AppLifeCycleResumedEvent extends AppLifeCycleEvent {}