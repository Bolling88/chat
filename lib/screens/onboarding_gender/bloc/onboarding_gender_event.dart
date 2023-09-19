import 'package:equatable/equatable.dart';

class OnboardingGenderEvent extends Equatable{

  const OnboardingGenderEvent();

  @override
  List<Object> get props => [];

}

class OnboardingGenderInitialState extends OnboardingGenderEvent{}
class OnboardingGenderMaleClickedEvent extends OnboardingGenderEvent{}
class OnboardingGenderFemaleClickedEvent extends OnboardingGenderEvent{}
class OnboardingGenderNonBinaryClickedEvent extends OnboardingGenderEvent{}
class OnboardingGenderSecretClickedEvent extends OnboardingGenderEvent{}
