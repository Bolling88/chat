import 'dart:async';

import 'package:chat/screens/visit/bloc/visit_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../repository/data_repository.dart';
import '../../../repository/firestore_repository.dart';
import 'visit_event.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final FirestoreRepository _firestoreRepository;
  final String userId;
  StreamSubscription<DocumentSnapshot>? userStream;

  late ChatUser user;
  late ChatUser me;

  VisitBloc(this._firestoreRepository, this.userId)
      : super(VisitLoadingState()) {
    add(VisitInitialEvent());
  }

  @override
  Future<void> close() {
    userStream?.cancel();
    return super.close();
  }

  @override
  Stream<VisitState> mapEventToState(VisitEvent event) async* {
    if (event is VisitInitialEvent) {
      user = (await _firestoreRepository.getUser(userId: userId))!;
      me = (await _firestoreRepository.getUser())!;
      yield VisitBaseState(user);
    } else {
      throw UnimplementedError();
    }
  }
}
