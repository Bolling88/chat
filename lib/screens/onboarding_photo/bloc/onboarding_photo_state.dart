import 'package:chat/screens/login/bloc/login_state.dart';
import 'package:equatable/equatable.dart';

import '../../../model/chat_user.dart';

abstract class OnboardingPhotoState extends Equatable {
  const OnboardingPhotoState();

  @override
  List<Object> get props => [];
}

class OnboardingPhotoBaseState extends OnboardingPhotoState {
  final ChatUser user;

  const OnboardingPhotoBaseState(this.user);

  @override
  List<Object> get props => [user];
}

class OnboardingPhotoDoneState extends OnboardingPhotoState {
  final String filePath;
  final String base64Image;

  const OnboardingPhotoDoneState(this.filePath, this.base64Image);

  OnboardingPhotoDoneState copyWith({String? filePath, String? base64Image}) {
    return OnboardingPhotoDoneState(filePath ?? this.filePath, base64Image ?? this.base64Image);
  }

  @override
  List<Object> get props => [filePath, base64Image];
}

class OnboardingPhotoLoadingState extends OnboardingPhotoState {}
class OnboardingPhotoErrorState extends OnboardingPhotoState {}

class OnboardingPhotoRedoState extends OnboardingPhotoDoneState {
  const OnboardingPhotoRedoState(String filePath, String base64Image) : super(filePath, base64Image);
}

class OnboardingPhotoSuccessState extends OnboardingPhotoState {
  final OnboardingNavigation navigation;

  const OnboardingPhotoSuccessState(this.navigation);

  @override
  List<Object> get props => [navigation];
}
