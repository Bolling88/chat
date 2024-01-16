import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repository/firestore_repository.dart';
import 'app_life_cycle_event.dart';
import 'app_life_cycle_state_state.dart';

class AppLifeCycleBloc extends Bloc<AppLifeCycleEvent, AppLifeCycleState> {
  final FirestoreRepository _firestoreRepository;

  AppLifeCycleBloc(this._firestoreRepository) : super(AppLifeCycleBaseState()) {
    add(AppLifeCycleInitialEvent());
  }

  @override
  Stream<AppLifeCycleState> mapEventToState(AppLifeCycleEvent event) async* {
    final currentState = state;
    if (event is AppLifeCycleInitialEvent) {
    }else if(event is AppLifeCycleResumedEvent){
      _firestoreRepository.setUserAsActive();
    }else if(event is AppLifeCyclePausedEvent){
    } else {
      throw UnimplementedError();
    }
  }
}
