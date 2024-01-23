import 'dart:async';

import 'package:chat/repository/firestore_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/cloud_translation/google_cloud_translation.dart';
import '../../../utils/log.dart';
import 'credits_event.dart';
import 'credits_state.dart';

class CreditsBloc extends Bloc<CreditsEvent, CreditsState> {
  final FirestoreRepository _firestoreRepository;

  late Translation translator;

  CreditsBloc(this._firestoreRepository) : super(CreditsBaseState()) {
    add(CreditsInitialEvent());
  }

  @override
  Stream<CreditsState> mapEventToState(CreditsEvent event) async* {
    final currentState = state;
    try {
      if (event is CreditsInitialEvent) {
        yield const CreditsBaseState();
      }
    } on Exception catch (error, stacktrace) {
      yield CreditsErrorState();
      Log.e('CreditsErrorState: $error', stackTrace: stacktrace);
    }
  }
}
