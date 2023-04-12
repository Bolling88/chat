import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../repository/firestore_repository.dart';
import '../../repository/storage_repository.dart';
import '../../screens/login/bloc/login_state.dart';
import '../../utils/image_util.dart';
import 'onboarding_photo_event.dart';
import 'onboarding_photo_state.dart';

const int photoQuality = 50;

class OnboardingPhotoBloc
    extends Bloc<OnboardingPhotoEvent, OnboardingPhotoState> {
  final FirestoreRepository _firestoreRepository;
  final StorageRepository _storageRepository;
  final picker = ImagePicker();

  OnboardingPhotoBloc(this._firestoreRepository, this._storageRepository)
      : super(OnboardingPhotoLoadingState()) {
    add(OnboardingPhotoInitialEvent());
  }

  @override
  Stream<OnboardingPhotoState> mapEventToState(
      OnboardingPhotoEvent event) async* {
    final currentState = state;
    if (event is OnboardingPhotoInitialEvent) {
      final socializeUser = await _firestoreRepository.getUser();
      yield OnboardingPhotoBaseState(socializeUser?.name ?? '');
    } else if (event is OnboardingPhotoCameraClickedEvent) {
      final pickedFile = await picker.pickImage(
          source: ImageSource.camera, imageQuality: photoQuality);
      if (pickedFile != null) {
        CroppedFile? croppedFile = await cropImage(pickedFile);
        if (currentState is OnboardingPhotoBaseState && croppedFile != null) {
          yield OnboardingPhotoDoneState(croppedFile.path);
        } else if (currentState is OnboardingPhotoDoneState &&
            croppedFile != null) {
          yield currentState.copyWith(filePath: croppedFile.path);
        }
      }
    } else if (event is OnboardingPhotoGalleryClickedEvent) {
      final pickedFile = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: photoQuality);
      if (pickedFile != null) {
        CroppedFile? croppedFile = await cropImage(pickedFile);
        if (currentState is OnboardingPhotoBaseState && croppedFile != null) {
          yield OnboardingPhotoDoneState(croppedFile.path);
        } else if (currentState is OnboardingPhotoDoneState &&
            croppedFile != null) {
          yield currentState.copyWith(filePath: croppedFile.path);
        }
      }
    } else if (event is OnboardingPhotoContinueClickedEvent) {
      if (currentState is OnboardingPhotoDoneState) {
        yield OnboardingPhotoLoadingState();
        final imageUrl =
            await _storageRepository.uploadProfileImage(currentState.filePath);
        final finalUrl = await imageUrl?.getDownloadURL() ?? "";
        await _firestoreRepository.updateUserProfileImage(finalUrl);

        final chatUser = await _firestoreRepository.getUser();
        if (chatUser?.gender == -1) {
          yield const OnboardingPhotoSuccessState(OnboardingNavigation.GENDER);
        } else {
          yield const OnboardingPhotoSuccessState(OnboardingNavigation.DONE);
        }
      }
    } else if (event is OnboardingPhotoRedoClickedEvent) {
      if (currentState is OnboardingPhotoDoneState) {
        yield OnboardingPhotoRedoState(currentState.filePath);
        yield currentState;
      }
    } else if (event is OnboardingPhotoBottomSheetClosedEvent) {
      if (currentState is OnboardingPhotoDoneState) {
        yield OnboardingPhotoDoneState(currentState.filePath);
      }
    }
  }
}
