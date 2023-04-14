import 'package:equatable/equatable.dart';

class OnboardingNameEvent extends Equatable{

  const OnboardingNameEvent();

  @override
  List<Object> get props => [];

}

class OnboardingNameInitialEvent extends OnboardingNameEvent{}
class OnboardingNameContinueClickedEvent extends OnboardingNameEvent{}

class OnboardingNameChangedEvent extends OnboardingNameEvent{
  final String displayName;

  const OnboardingNameChangedEvent(this.displayName);

  @override
  List<Object> get props => [displayName];
}