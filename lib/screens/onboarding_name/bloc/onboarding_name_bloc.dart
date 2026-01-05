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
    on<OnboardingNameInitialEvent>(_onInitial);
    on<OnboardingNameContinueClickedEvent>(_onContinueClicked);
    on<OnboardingNameChangedEvent>(_onNameChanged);

    add(OnboardingNameInitialEvent());
  }

  Future<void> _onInitial(
    OnboardingNameInitialEvent event,
    Emitter<OnboardingNameState> emit,
  ) async {
    final user = await _firestoreRepository.getUser();
    if (user != null) {
      add(OnboardingNameChangedEvent(user.displayName));
    }
  }

  Future<void> _onContinueClicked(
    OnboardingNameContinueClickedEvent event,
    Emitter<OnboardingNameState> emit,
  ) async {
    final currentState = state;
    if (currentState is OnboardingNameBaseState) {
      final name = currentState.displayName.trim();
      emit(currentState.copyWith(isValidatingName: true, displayName: name));
      final nameAvailable =
          await _firestoreRepository.getIsNameAvailable(name);
      if (!nameAvailable) {
        emit(currentState.copyWith(
            isValidatingName: false, isNameTaken: true));
      } else {
        final fullName = name;
        final searchArray = _getSearchArray(fullName);
        await _firestoreRepository.updateUserDisplayName(
            fullName, searchArray);
        final chatUser = await _firestoreRepository.getUser();
        if (chatUser?.birthDate == null && Platform.isAndroid) {
          emit(const OnboardingNameSuccessState(OnboardingNavigation.age));
        } else if (chatUser?.pictureData.isEmpty == true) {
          emit(const OnboardingNameSuccessState(
              OnboardingNavigation.picture));
        } else if (chatUser?.gender == -1) {
          emit(const OnboardingNameSuccessState(OnboardingNavigation.gender));
        } else {
          emit(const OnboardingNameSuccessState(OnboardingNavigation.done));
        }
      }
    }
  }

  void _onNameChanged(
    OnboardingNameChangedEvent event,
    Emitter<OnboardingNameState> emit,
  ) {
    final currentState = state;
    if (currentState is OnboardingNameBaseState) {
      Log.d(event.displayName);
      emit(currentState.copyWith(
          displayName: event.displayName, isNameTaken: false));
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
