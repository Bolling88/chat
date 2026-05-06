import 'dart:async';

import 'package:chat/screens/report/bloc/report_state.dart';
import 'package:chat/screens/report/bloc/report_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/serverpod_repository.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ServerpodRepository _serverpodRepository;
  final String userId;

  ReportBloc(this._serverpodRepository, this.userId) : super(ReportBaseState()) {
    on<ReportInitialEvent>(_onReportInitialEvent);
    on<ReportInappropriateImageEvent>(_onReportInappropriateImageEvent);
    on<ReportHatefulLanguageEvent>(_onReportHatefulLanguageEvent);
    on<ReportBotEvent>(_onReportBotEvent);

    add(ReportInitialEvent());
  }

  void _onReportInitialEvent(
    ReportInitialEvent event,
    Emitter<ReportState> emit,
  ) {
    // No action needed for initial event
  }

  Future<void> _onReportInappropriateImageEvent(
    ReportInappropriateImageEvent event,
    Emitter<ReportState> emit,
  ) async {
    final currentState = state;
    if (currentState is ReportBaseState) {
      emit(ReportLoadingState());
      try {
        await _serverpodRepository.postInappropriateImageReport(userId);
        emit(ReportDoneState());
      } catch (e) {
        emit(ReportErrorState(e.toString()));
      }
    }
  }

  Future<void> _onReportHatefulLanguageEvent(
    ReportHatefulLanguageEvent event,
    Emitter<ReportState> emit,
  ) async {
    final currentState = state;
    if (currentState is ReportBaseState) {
      emit(ReportLoadingState());
      try {
        await _serverpodRepository.postHatefulLanguageReport(userId);
        emit(ReportDoneState());
      } catch (e) {
        emit(ReportErrorState(e.toString()));
      }
    }
  }

  Future<void> _onReportBotEvent(
    ReportBotEvent event,
    Emitter<ReportState> emit,
  ) async {
    final currentState = state;
    if (currentState is ReportBaseState) {
      emit(ReportLoadingState());
      try {
        await _serverpodRepository.postBotReport(userId);
        emit(ReportDoneState());
      } catch (e) {
        emit(ReportErrorState(e.toString()));
      }
    }
  }
}
