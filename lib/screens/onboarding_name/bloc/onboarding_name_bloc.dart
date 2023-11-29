import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';
import '../../../repository/firestore_repository.dart';
import '../../../utils/log.dart';
import '../../login/bloc/login_state.dart';
import 'onboarding_name_event.dart';
import 'onboarding_name_state.dart';

class OnboardingNameBloc
    extends Bloc<OnboardingNameEvent, OnboardingNameState> {
  final FirestoreRepository _firestoreRepository;
  final picker = ImagePicker();

  OnboardingNameBloc(this._firestoreRepository)
      : super(const OnboardingNameBaseState('', false, false)) {
    add(OnboardingNameInitialEvent());
  }

  @override
  Stream<OnboardingNameState> mapEventToState(
      OnboardingNameEvent event) async* {
    final currentState = state;
    if (event is OnboardingNameInitialEvent) {
      _firestoreRepository.getUser().then((value) {
        if (value != null) {
          add(OnboardingNameChangedEvent(value.displayName));
        }
      });
    } else if (event is OnboardingNameContinueClickedEvent) {
      if (currentState is OnboardingNameBaseState) {
        final name = currentState.displayName.trim();
        yield currentState.copyWith(isValidatingName: true, displayName: name);
        final nameAvailable =
            await _firestoreRepository.getIsNameAvailable(name);
        if (!nameAvailable) {
          yield currentState.copyWith(
              isValidatingName: false, isNameTaken: true);
        } else {
          final fullName = name;
          final searchArray = _getSearchArray(fullName);
          await _firestoreRepository.updateUserDisplayName(
              fullName, searchArray);
          final chatUser = await _firestoreRepository.getUser();
          if (chatUser?.birthDate == null && Platform.isAndroid) {
            yield const OnboardingNameSuccessState(OnboardingNavigation.AGE);
          } else if (chatUser?.pictureData.isEmpty == true) {
            yield const OnboardingNameSuccessState(
                OnboardingNavigation.PICTURE);
          } else if (chatUser?.gender == -1) {
            yield const OnboardingNameSuccessState(OnboardingNavigation.GENDER);
          } else {
            yield const OnboardingNameSuccessState(OnboardingNavigation.DONE);
          }
        }
      }
    } else if (event is OnboardingNameChangedEvent) {
      if (currentState is OnboardingNameBaseState) {
        Log.d(event.displayName);
        yield currentState.copyWith(
            displayName: event.displayName, isNameTaken: false);
      }
    }
  }

  List<String> _getSearchArray(String name) {
    List<String> searchArray = [];
    for (int i = 1; i < name.length + 1; i++) {
      searchArray.add(name.substring(0, i).toLowerCase());
    }
    return searchArray;
  }
}
