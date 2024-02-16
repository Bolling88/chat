import 'package:chat/utils/cloud_translation/google_cloud_translation.dart';
import 'package:equatable/equatable.dart';
import 'package:glassfy_flutter/models.dart';

import '../../../model/chat_user.dart';
import '../../../utils/cloud_translation/translation_model.dart';

abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object?> get props => [];
}

class PremiumBaseState extends PremiumState {
  final GlassfySku? offerings;

  const PremiumBaseState(this.offerings);

  @override
  List<Object?> get props => [offerings];
}

class PremiumErrorState extends PremiumState {
  const PremiumErrorState();

  @override
  List<Object> get props => [];
}

class PremiumLoadingState extends PremiumState {
  const PremiumLoadingState();

  @override
  List<Object> get props => [];
}

class PremiumDoneState extends PremiumState {
  const PremiumDoneState();

  @override
  List<Object> get props => [];
}

class PremiumNothingRestoreState extends PremiumBaseState {
  const PremiumNothingRestoreState(super.offerings);

  @override
  List<Object> get props => [];
}

class PremiumAbortedState extends PremiumBaseState {
  const PremiumAbortedState(super.offerings);

  @override
  List<Object> get props => [];
}