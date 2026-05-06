import 'dart:async';

import 'package:chat/repository/serverpod_repository.dart';
import 'package:chat/screens/profile/bloc/profile_event.dart';
import 'package:chat/screens/profile/bloc/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ServerpodRepository _serverpodRepository;

  late StreamSubscription<ChatUser?> userStream;

  ProfileBloc(this._serverpodRepository) : super(ProfileLoadingState()) {
    on<ProfileInitialEvent>(_onProfileInitialEvent);
    on<ProfileUserChangedEvent>(_onProfileUserChangedEvent);
    on<ProfileShowAgeChangedEvent>(_onProfileShowAgeChangedEvent);

    add(ProfileInitialEvent());
  }

  @override
  Future<void> close() {
    userStream.cancel();
    return super.close();
  }

  Future<void> _onProfileInitialEvent(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      await setUpUserListener();
    } on Exception catch (error, stacktrace) {
      emit(ProfileErrorState());
      Log.e('ProfileErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onProfileUserChangedEvent(
    ProfileUserChangedEvent event,
    Emitter<ProfileState> emit,
  ) {
    try {
      emit(ProfileBaseState(user: event.user));
    } on Exception catch (error, stacktrace) {
      emit(ProfileErrorState());
      Log.e('ProfileErrorState: $error', stackTrace: stacktrace);
    }
  }

  void _onProfileShowAgeChangedEvent(
    ProfileShowAgeChangedEvent event,
    Emitter<ProfileState> emit,
  ) {
    final currentState = state;
    try {
      if (currentState is ProfileBaseState) {
        _serverpodRepository.updateUserShowAge(event.showAge);
      }
    } on Exception catch (error, stacktrace) {
      emit(ProfileErrorState());
      Log.e('ProfileErrorState: $error', stackTrace: stacktrace);
    }
  }

  Future<void> setUpUserListener() async {
    Log.d('Setting up user stream for profile');
    userStream = _serverpodRepository.streamUser().listen(
      (user) async {
        if (user == null) {
          Log.e('No user found in profile stream');
          add(ProfileUserChangedEvent(ChatUser.asUnknown('')));
          return;
        }
        add(ProfileUserChangedEvent(user));
      },
      onError: (error, stackTrace) {
        Log.e('Profile stream error: $error', stackTrace: stackTrace);
        add(ProfileUserChangedEvent(ChatUser.asUnknown('')));
      },
    );
  }
}
