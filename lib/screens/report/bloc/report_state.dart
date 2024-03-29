import 'package:equatable/equatable.dart';

abstract class ReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportBaseState extends ReportState {}
class ReportLoadingState extends ReportState {}
class ReportDoneState extends ReportLoadingState {}
