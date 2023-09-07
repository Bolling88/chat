import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/screens/profile/bloc/profile_event.dart';
import 'package:chat/screens/profile/bloc/profile_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirestoreRepository _firestoreRepository;
  late final ChatUser _chatUser;

  ProfileBloc(this._firestoreRepository)
      : super(ProfileLoadingState()) {
    add(ProfileInitialEvent());
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    final currentState = state;
    try {
      if (event is ProfileInitialEvent) {
        _chatUser = (await _firestoreRepository.getUser())!;
        yield ProfileBaseState(user: _chatUser);
      } else if (event is ProfileDeleteAccountEvent) {
        if (currentState is ProfileBaseState) {
          yield ProfileLoadingState();
          Log.d('Deleting user');
          await _firestoreRepository.deleteUserAndFiles();
          yield ProfileLogoutState();
        }
      } else if (event is ProfileLogoutEvent) {
        yield ProfileLoadingState();
        //Check if user is anonymous
        if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
          //Delete user
          await _firestoreRepository.deleteUserAndFiles();
        } else {
          //else just sign out the user
          await FirebaseAuth.instance.signOut();
        }
        yield ProfileLogoutState();
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
