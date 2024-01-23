import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';
import '../../profile/bloc/profile_event.dart';

abstract class OptionsEvent extends Equatable {
  const OptionsEvent();

  @override
  List<Object> get props => [];
}

class OptionsInitialEvent extends OptionsEvent {}
class OptionsTranslateEvent extends OptionsEvent {
  final String text;

  const OptionsTranslateEvent(this.text);

  @override
  List<Object> get props => [text];
}

class OptionsUserChangedEvent extends OptionsEvent {
  final ChatUser user;

  const OptionsUserChangedEvent(this.user);

  @override
  List<Object> get props => [user];
}



