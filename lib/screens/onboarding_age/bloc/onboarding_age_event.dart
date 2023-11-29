import 'package:equatable/equatable.dart';

class OnboardingAgeEvent extends Equatable{

  const OnboardingAgeEvent();

  @override
  List<Object> get props => [];

}

class OnboardingAgeChangedEvent extends OnboardingAgeEvent{
  final DateTime date;

  const OnboardingAgeChangedEvent(this.date);

  @override
  List<Object> get props => [date];
}

class OnboardingAgeContinueClickedEvent extends OnboardingAgeEvent{}
