import 'package:chat/utils/cloud_translation/google_cloud_translation.dart';
import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';
import '../../../utils/cloud_translation/translation_model.dart';

abstract class OptionsState extends Equatable {
  const OptionsState();

  @override
  List<Object?> get props => [];
}

class OptionsBaseState extends OptionsState {
  final ChatUser? user;

  const OptionsBaseState({this.user});

  @override
  List<Object?> get props => [user];
}

class OptionsShowCreditsOfferState extends OptionsBaseState {}

class OptionsTranslationDoneState extends OptionsState {
  final TranslationModel translation;

  const OptionsTranslationDoneState({required this.translation});

  @override
  List<Object?> get props => [translation];
}

class OptionsLoadingState extends OptionsState {}

class OptionsErrorState extends OptionsState {}
