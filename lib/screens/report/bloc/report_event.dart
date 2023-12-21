import 'package:equatable/equatable.dart';


abstract class ReportEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ReportInitialEvent extends ReportEvent {}
class ReportInappropriateImageEvent extends ReportEvent {}
class ReportHatefulLanguageEvent extends ReportEvent {}
class ReportBotEvent extends ReportEvent {}
