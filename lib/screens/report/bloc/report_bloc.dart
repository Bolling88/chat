import 'dart:async';

import 'package:chat/screens/report/bloc/report_state.dart';
import 'package:chat/screens/report/bloc/report_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../repository/firestore_repository.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final FirestoreRepository _firestoreRepository;
  final String userId;

  ReportBloc(this._firestoreRepository, this.userId) : super(ReportBaseState()) {
    add(ReportInitialEvent());
  }

  @override
  Stream<ReportState> mapEventToState(ReportEvent event) async* {
    final currentState = state;
    if (event is ReportInitialEvent) {
    } else if (event is ReportInappropriateImageEvent) {
      if (currentState is ReportBaseState) {
        yield ReportLoadingState();
        await _firestoreRepository.postInappropriateImageReport(userId);
        yield ReportDoneState();
      }
    }else if(event is ReportHatefulLanguageEvent){
      if (currentState is ReportBaseState) {
        yield ReportLoadingState();
        await _firestoreRepository.postHatefulLanguageReport(userId);
        yield ReportDoneState();
      }
    }else if(event is ReportBotEvent){
      if (currentState is ReportBaseState) {
        yield ReportLoadingState();
        await _firestoreRepository.postBotReport(userId);
        yield ReportDoneState();
      }
    } else {
      throw UnimplementedError();
    }
  }
}
