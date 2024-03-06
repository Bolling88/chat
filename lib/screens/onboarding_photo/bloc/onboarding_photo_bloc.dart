import 'dart:convert';

import 'package:chat/model/chat_user.dart';
import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/repository/storage_repository.dart';
import 'package:chat/screens/login/bloc/login_state.dart';
import 'package:chat/utils/image_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_nude_detector/flutter_nude_detector.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/log.dart';
import 'onboarding_photo_event.dart';
import 'onboarding_photo_state.dart';

const int photoQuality = 30;

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
        yield OnboardingPhotoBaseState(_chatUser);
      } else if (event is OnboardingPhotoCameraClickedEvent) {
        final pickedFile = await picker.pickImage(
            maxHeight: 400,
            maxWidth: 400,
            source: ImageSource.camera,
            imageQuality: photoQuality);
        if (pickedFile != null) {
          CroppedFile? croppedFile =
              await _appImageCropper.cropImage(pickedFile);
          if (currentState is OnboardingPhotoBaseState && croppedFile != null) {
            yield OnboardingPhotoDoneState(croppedFile.path, '');
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
            String base64Image = '';
            if (kIsWeb) {
              var imageForWeb = await croppedFile.readAsBytes();
              base64Image = base64Encode(imageForWeb);
            }

            yield OnboardingPhotoDoneState(croppedFile.path, base64Image);
          } else if (currentState is OnboardingPhotoDoneState &&
              croppedFile != null) {
            yield currentState.copyWith(filePath: croppedFile.path);
          }
        }
      } else if (event is OnboardingPhotoContinueClickedEvent) {
        if (currentState is OnboardingPhotoDoneState) {
          yield OnboardingPhotoLoadingState();
          final hasNudity =
              await FlutterNudeDetector.detect(path: currentState.filePath);
          final imageUrl = await _storageRepository.uploadProfileImage(
              currentState.filePath, currentState.base64Image);
          final finalUrl = await imageUrl?.getDownloadURL() ?? "";
          await _firestoreRepository.updateUserProfileImage(
              profileImageUrl: finalUrl, user: _chatUser, hasNudity: hasNudity);

          if (_chatUser.gender == -1) {
            yield const OnboardingPhotoSuccessState(
                OnboardingNavigation.GENDER);
          } else {
            yield const OnboardingPhotoSuccessState(OnboardingNavigation.DONE);
          }
        }
      } else if (event is OnboardingPhotoRedoClickedEvent) {
        if (currentState is OnboardingPhotoDoneState) {
          yield OnboardingPhotoRedoState(
              currentState.filePath, currentState.base64Image);
          yield currentState;
        }
      } else if (event is OnboardingPhotoBottomSheetClosedEvent) {
        if (currentState is OnboardingPhotoDoneState) {
          yield OnboardingPhotoDoneState(
              currentState.filePath, currentState.base64Image);
        }
      } else if (event is OnboardingPhotoSkipEvent) {
        await _firestoreRepository.updateUserProfileImage(
            profileImageUrl: '', user: _chatUser, hasNudity: false);
        if (_chatUser.gender == -1) {
          yield const OnboardingPhotoSuccessState(OnboardingNavigation.GENDER);
        } else {
          yield const OnboardingPhotoSuccessState(OnboardingNavigation.DONE);
        }
      } else if (event is OnboardingPhotoRemoveEvent) {
        yield OnboardingPhotoLoadingState();
        await _firestoreRepository.deleteUserPhoto();
        yield const OnboardingPhotoSuccessState(OnboardingNavigation.DONE);
      } else {
        Log.e('OnboardingPhotoErrorState: Not implemented');
        throw UnimplementedError();
      }
    } on Exception catch (error, stacktrace) {
      yield OnboardingPhotoErrorState();
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }
}
