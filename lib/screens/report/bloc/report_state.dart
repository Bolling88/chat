import 'package:equatable/equatable.dart';

abstract class ReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportBaseState extends ReportState {}
class ReportLoadingState extends ReportState {}
class ReportDoneState extends ReportState {}

class ReportErrorState extends ReportState {
  final String message;

  ReportErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
