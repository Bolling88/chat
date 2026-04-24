import 'dart:async';

import 'package:chat/screens/report/bloc/report_state.dart';
import 'package:chat/screens/report/bloc/report_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/supabase_repository.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final SupabaseRepository _supabaseRepository;
  final String userId;

  ReportBloc(this._supabaseRepository, this.userId) : super(ReportBaseState()) {
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
        await _supabaseRepository.postInappropriateImageReport(userId);
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
        await _supabaseRepository.postHatefulLanguageReport(userId);
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
        await _supabaseRepository.postBotReport(userId);
        emit(ReportDoneState());
      } catch (e) {
        emit(ReportErrorState(e.toString()));
      }
    }
  }
}
