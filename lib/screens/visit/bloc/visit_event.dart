import 'package:equatable/equatable.dart';

abstract class VisitEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class VisitInitialEvent extends VisitEvent {}