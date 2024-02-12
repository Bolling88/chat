import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object> get props => [];
}

class AccountInitialEvent extends AccountEvent {}
class AccountDeleteAccountEvent extends AccountEvent {}
class AccountLogoutEvent extends AccountEvent {}
class AccountBuyPremiumEvent extends AccountEvent {}
class AccountContinueClickedEvent extends AccountEvent {}
class AccountUserChangedEvent extends AccountEvent {
  final ChatUser user;

  const AccountUserChangedEvent(this.user);

  @override
  List<Object> get props => [user];
}
