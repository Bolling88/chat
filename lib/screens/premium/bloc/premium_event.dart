import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/models/package_wrapper.dart';

import '../../../model/chat_user.dart';
import '../../profile/bloc/profile_event.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object> get props => [];
}

class PremiumInitialEvent extends PremiumEvent {}

class PremiumBuyEvent extends PremiumEvent {
  final Package package;

  const PremiumBuyEvent(this.package);

  @override
  List<Object> get props => [package];
}

class PremiumRestoreEvent extends PremiumEvent {}
