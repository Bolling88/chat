import 'package:equatable/equatable.dart';
import '../../../model/chat_user.dart';

abstract class AppLifeCycleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppLifeCycleBaseState extends AppLifeCycleState {}
