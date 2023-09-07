import 'dart:typed_data';

import 'package:chat/model/chat_user.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/repository/storage_repository.dart';
import 'package:chat/screens/login/bloc/login_state.dart';
import 'package:chat/utils/image_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';
import '../../../utils/log.dart';
import 'onboarding_photo_event.dart';
import 'onboarding_photo_state.dart';

const int photoQuality = 50;

class OnboardingPhotoBloc
    extends Bloc<OnboardingPhotoEvent, OnboardingPhotoState> {
  final FirestoreRepository _firestoreRepository;
  final StorageRepository _storageRepository;
  final AppImageCropper _appImageCropper;
  final picker = ImagePicker();

  late ChatUser _chatUser;

  OnboardingPhotoBloc(
      this._firestoreRepository, this._storageRepository, this._appImageCropper)
      : super(OnboardingPhotoLoadingState()) {
    add(OnboardingPhotoInitialEvent());
  }

  @override
  Stream<OnboardingPhotoState> mapEventToState(
      OnboardingPhotoEvent event) async* {
    final currentState = state;
    try {
      if (event is OnboardingPhotoInitialEvent) {
        _chatUser = (await _firestoreRepository.getUser())!;
        yield OnboardingPhotoBaseState(_chatUser.displayName ?? '');
      } else if (event is OnboardingPhotoCameraClickedEvent) {
        final pickedFile = await picker.pickImage(
            source: ImageSource.camera, imageQuality: photoQuality);
        if (pickedFile != null) {
          CroppedFile? croppedFile =
              await _appImageCropper.cropImage(pickedFile);
          if (currentState is OnboardingPhotoBaseState && croppedFile != null) {
            yield OnboardingPhotoDoneState(croppedFile.path);
          } else if (currentState is OnboardingPhotoDoneState &&
              croppedFile != null) {
            yield currentState.copyWith(filePath: croppedFile.path);
          }
        }
      } else if (event is OnboardingPhotoGalleryClickedEvent) {
        XFile? pickedFile;
        try {
          pickedFile = await picker.pickImage(
              source: ImageSource.gallery, imageQuality: photoQuality);
        } catch (e) {
          Log.e(e);
        }
        if (pickedFile != null) {
          CroppedFile? croppedFile =
              await _appImageCropper.cropImage(pickedFile);
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
          final imageUrl = await _storageRepository
              .uploadProfileImage(currentState.filePath);
          final finalUrl = await imageUrl?.getDownloadURL() ?? "";
          await _firestoreRepository.updateUserProfileImage(finalUrl);

          if (_chatUser.gender == -1) {
            yield const OnboardingPhotoSuccessState(
                OnboardingNavigation.GENDER);
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
      } else if (event is OnboardingPhotoSkipEvent) {
        await _firestoreRepository.updateUserProfileImage('nan');
        if (_chatUser.gender == -1) {
          yield const OnboardingPhotoSuccessState(OnboardingNavigation.GENDER);
        } else {
          yield const OnboardingPhotoSuccessState(OnboardingNavigation.DONE);
        }
      } else {
        Log.e('OnboardingPhotoErrorState: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield OnboardingPhotoErrorState();
      Log.e('OnboardingPhotoRedoState: $error', stackTrace: stacktrace);
    }
  }
}

Future<File?> convertBlobToFile(Uint8List blobData, String filePath) async {
  File file = File(filePath);

  try {
    await file.writeAsBytes(blobData);
    return file;
  } catch (e) {
    // Handle any errors that occur during the file writing process
    Log.e('Error converting Blob to File: $e');
    return null;
  }
}
