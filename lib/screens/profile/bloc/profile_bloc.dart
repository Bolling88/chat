import 'dart:async';

import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/profile/bloc/profile_event.dart';
import 'package:chat/screens/profile/bloc/profile_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirestoreRepository _firestoreRepository;

  late StreamSubscription<QuerySnapshot<Object?>> userStream;

  ProfileBloc(this._firestoreRepository) : super(ProfileLoadingState()) {
    add(ProfileInitialEvent());
  }

  @override
  Future<void> close() {
    userStream.cancel();
    return super.close();
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    final currentState = state;
    try {
      if (event is ProfileInitialEvent) {
        setUpUserListener();
      } else if (event is ProfileUserChangedEvent) {
        yield ProfileBaseState(user: event.user);
      } else if (event is ProfileShowAgeChangedEvent) {
        if (currentState is ProfileBaseState) {
          _firestoreRepository.updateUserShowAge(event.showAge);
        }
      } else {
        Log.e('ProfileBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield ProfileErrorState();
      Log.e('ProfileErrorState: $error', stackTrace: stacktrace);
    }
  }

  void setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _firestoreRepository.streamUser().listen((event) async {
      if (event.docs.isEmpty) {
        Log.d('No user found');
        return;
      }
      final Map<String, dynamic> userData =
          event.docs.first.data() as Map<String, dynamic>;

      // Convert Timestamp to int (milliseconds since epoch)
      if (userData.containsKey('lastActive') &&
          userData['lastActive'] is Timestamp) {
        userData['lastActive'] =
            (userData['lastActive'] as Timestamp).millisecondsSinceEpoch;
      }
      final user = ChatUser.fromJson(event.docs.first.id, userData);
      add(ProfileUserChangedEvent(user));
    });
  }
}
