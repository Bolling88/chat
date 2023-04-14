import 'package:chat/screens/login/bloc/login_state.dart';
import 'package:equatable/equatable.dart';

abstract class OnboardingPhotoState extends Equatable {
  const OnboardingPhotoState();

  @override
  List<Object> get props => [];
}

class OnboardingPhotoBaseState extends OnboardingPhotoState {
  final String name;

  const OnboardingPhotoBaseState(this.name);

  @override
  List<Object> get props => [name];
}

class OnboardingPhotoDoneState extends OnboardingPhotoState {
  final String filePath;

  const OnboardingPhotoDoneState(this.filePath);

  OnboardingPhotoDoneState copyWith({String? filePath}) {
    return OnboardingPhotoDoneState(filePath ?? this.filePath);
  }

  @override
  List<Object> get props => [filePath];
}

class OnboardingPhotoLoadingState extends OnboardingPhotoState {}
class OnboardingPhotoErrorState extends OnboardingPhotoState {}

class OnboardingPhotoRedoState extends OnboardingPhotoDoneState {
  const OnboardingPhotoRedoState(String filePath) : super(filePath);
}

class OnboardingPhotoSuccessState extends OnboardingPhotoState {
  final OnboardingNavigation navigation;

  const OnboardingPhotoSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
