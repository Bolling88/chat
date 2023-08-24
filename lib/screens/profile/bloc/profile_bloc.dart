import 'package:chat/repository/data_repository.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/profile/bloc/profile_event.dart';
import 'package:chat/screens/profile/bloc/profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/log.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirestoreRepository _firestoreRepository;

  ProfileBloc(this._firestoreRepository)
      : super(const ProfileBaseState(name: '')) {
    add(ProfileInitialEvent());
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    final currentState = state;
    try {
      if (event is ProfileInitialEvent) {
      } else if (event is ProfileDeleteAccountEvent) {
        if (currentState is ProfileBaseState) {
          yield ProfileLoadingState();
          Log.d('Deleting user');
          await _firestoreRepository.deleteUserAndFiles();
          yield ProfileLogoutState();
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
}
