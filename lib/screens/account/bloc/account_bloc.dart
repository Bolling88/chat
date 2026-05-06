import 'dart:async';

import 'package:chat/repository/serverpod_repository.dart';
import 'package:chat/repository/serverpod_auth_repository.dart';
import 'package:chat/repository/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final ServerpodRepository _serverpodRepository;
  final ServerpodAuthRepository _authRepository;
  final SubscriptionRepository _subscriptionRepository;

  late StreamSubscription<ChatUser?> userStream;

  AccountBloc(this._serverpodRepository, this._authRepository, this._subscriptionRepository) : super(AccountLoadingState()) {
    on<AccountInitialEvent>(_onAccountInitialEvent);
    on<AccountDeleteAccountEvent>(_onAccountDeleteAccountEvent);
    on<AccountUserChangedEvent>(_onAccountUserChangedEvent);
    on<AccountLogoutEvent>(_onAccountLogoutEvent);
    on<AccountBuyPremiumEvent>(_onAccountBuyPremiumEvent);

    add(AccountInitialEvent());
  }

  @override
  Future<void> close() {
    userStream.cancel();
    return super.close();
  }

  Future<void> _onAccountInitialEvent(AccountInitialEvent event, Emitter<AccountState> emit) async {
    setUpUserListener();
  }

  Future<void> _onAccountDeleteAccountEvent(AccountDeleteAccountEvent event, Emitter<AccountState> emit) async {
    final currentState = state;
    try {
      if (currentState is AccountBaseState) {
        emit(AccountLoadingState());
        Log.d('Deleting user');
        await _serverpodRepository.updateUserOnLogout();
        await _serverpodRepository.leaveAllPrivateChats();
        _serverpodRepository.closeAllStreams();
        await _serverpodRepository.deleteUserAndFiles();
        emit(AccountLogoutState());
      }
    } on Exception catch (error, stacktrace) {
      emit(AccountErrorState());
      Log.e('AccountErrorState: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onAccountUserChangedEvent(AccountUserChangedEvent event, Emitter<AccountState> emit) async {
    emit(AccountBaseState(user: event.user));
  }

  Future<void> _onAccountLogoutEvent(AccountLogoutEvent event, Emitter<AccountState> emit) async {
    try {
      emit(AccountLoadingState());
      await _serverpodRepository.updateUserOnLogout();
      _serverpodRepository.closeAllStreams();
      await _authRepository.signOut();
      emit(AccountLogoutState());
    } on Exception catch (error, stacktrace) {
      emit(AccountErrorState());
      Log.e('AccountErrorState: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onAccountBuyPremiumEvent(AccountBuyPremiumEvent event, Emitter<AccountState> emit) async {
    _subscriptionRepository.getOfferings();
  }

  void setUpUserListener() async {
    Log.d('Setting up private chats stream');
    userStream = _serverpodRepository.streamUser().listen((user) async {
      if (user == null) {
        Log.d('No user found');
        return;
      }
      add(AccountUserChangedEvent(user));
    });
  }
}
