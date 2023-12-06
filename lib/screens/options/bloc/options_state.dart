import 'package:chat/utils/cloud_translation/google_cloud_translation.dart';
import 'package:equatable/equatable.dart';

import '../../../utils/cloud_translation/translation_model.dart';

abstract class OptionsState extends Equatable {
  const OptionsState();

  @override
  List<Object> get props => [];
}

class OptionsBaseState extends OptionsState {

  const OptionsBaseState();

  @override
  List<Object> get props => [];
}

class OptionsTranslationDoneState extends OptionsBaseState {
  final TranslationModel translation;

  const OptionsTranslationDoneState({required this.translation});

  @override
  List<Object> get props => [translation];
}

class OptionsLoadingState extends OptionsState {}

class OptionsErrorState extends OptionsState {}
