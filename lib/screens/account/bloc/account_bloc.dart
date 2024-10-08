import 'dart:async';

import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/repository/subscription_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/chat_user.dart';
import '../../../utils/log.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final FirestoreRepository _firestoreRepository;
  final SubscriptionRepository _subscriptionRepository;

  late StreamSubscription<QuerySnapshot<Object?>> userStream;

  AccountBloc(this._firestoreRepository, this._subscriptionRepository) : super(AccountLoadingState()) {
    add(AccountInitialEvent());
  }

  @override
  Future<void> close() {
    userStream.cancel();
    return super.close();
  }

  @override
  Stream<AccountState> mapEventToState(AccountEvent event) async* {
    final currentState = state;
    try {
      if (event is AccountInitialEvent) {
        setUpUserListener();
      } else if (event is AccountDeleteAccountEvent) {
        if (currentState is AccountBaseState) {
          yield AccountLoadingState();
          Log.d('Deleting user');
          await _firestoreRepository.updateUserOnLogout();
          await _firestoreRepository.leaveAllPrivateChats();
          await _firestoreRepository.closeAllStreams();
          await _firestoreRepository.deleteUserAndFiles();
          yield AccountLogoutState();
        }
      } else if (event is AccountUserChangedEvent) {
        yield AccountBaseState(user: event.user);
      } else if (event is AccountLogoutEvent) {
        yield AccountLoadingState();
        await _firestoreRepository.updateUserOnLogout();
        await _firestoreRepository.closeAllStreams();
        if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
          //Delete user
          await _firestoreRepository.deleteUserAndFiles();
        } else {
          //else just sign out the user
          await FirebaseAuth.instance.signOut();
        }
        yield AccountLogoutState();
      }else if(event is AccountBuyPremiumEvent){
        _subscriptionRepository.getOfferings();
      } else {
        Log.e('AccountBloc: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield AccountErrorState();
      Log.e('AccountErrorState: $error', stackTrace: stacktrace);
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
      add(AccountUserChangedEvent(user));
    });
  }
}
