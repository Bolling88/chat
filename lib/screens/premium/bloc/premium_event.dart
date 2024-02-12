import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';
import '../../profile/bloc/profile_event.dart';

abstract class PremiumEvent extends Equatable {
  const PremiumEvent();

  @override
  List<Object> get props => [];
}

class PremiumInitialEvent extends PremiumEvent {}
class PremiumBuyEvent extends PremiumEvent {}
class PremiumRestoreEvent extends PremiumEvent {}


