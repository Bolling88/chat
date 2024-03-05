import 'package:equatable/equatable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PremiumState extends Equatable {
  const PremiumState();

  @override
  List<Object?> get props => [];
}

class PremiumBaseState extends PremiumState {
  final Package package;

  const PremiumBaseState(this.package);

  @override
  List<Object?> get props => [package];
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