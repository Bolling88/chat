import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';
import '../../profile/bloc/profile_event.dart';

abstract class CreditsEvent extends Equatable {
  const CreditsEvent();

  @override
  List<Object> get props => [];
}

class CreditsInitialEvent extends CreditsEvent {}



