import 'package:equatable/equatable.dart';

class OnboardingNameEvent extends Equatable{

  const OnboardingNameEvent();

  @override
  List<Object> get props => [];

}

class OnboardingNameContinueClickedEvent extends OnboardingNameEvent{}
class OnboardingLastNameChangedEvent extends OnboardingNameEvent{
  final String lastName;

  OnboardingLastNameChangedEvent(this.lastName);

  @override
  List<Object> get props => [lastName];
}
class OnboardingNameChangedEvent extends OnboardingNameEvent{
  final String firstName;

  OnboardingNameChangedEvent(this.firstName);

  @override
  List<Object> get props => [firstName];
}