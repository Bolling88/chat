import 'package:equatable/equatable.dart';

class OnboardingPhotoEvent extends Equatable{

  const OnboardingPhotoEvent();

  @override
  List<Object> get props => [];

}

class OnboardingPhotoInitialEvent extends OnboardingPhotoEvent{}
class OnboardingPhotoCameraClickedEvent extends OnboardingPhotoEvent{}
class OnboardingPhotoGalleryClickedEvent extends OnboardingPhotoEvent{}
class OnboardingPhotoContinueClickedEvent extends OnboardingPhotoEvent{}
class OnboardingPhotoRedoClickedEvent extends OnboardingPhotoEvent{}
class OnboardingPhotoBottomSheetClosedEvent extends OnboardingPhotoEvent{}