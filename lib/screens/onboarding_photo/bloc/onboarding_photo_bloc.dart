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
    on<OnboardingPhotoInitialEvent>(_onInitial);
    on<OnboardingPhotoCameraClickedEvent>(_onCameraClicked);
    on<OnboardingPhotoGalleryClickedEvent>(_onGalleryClicked);
    on<OnboardingPhotoContinueClickedEvent>(_onContinueClicked);
    on<OnboardingPhotoRedoClickedEvent>(_onRedoClicked);
    on<OnboardingPhotoBottomSheetClosedEvent>(_onBottomSheetClosed);
    on<OnboardingPhotoSkipEvent>(_onSkip);
    on<OnboardingPhotoRemoveEvent>(_onRemove);

    add(OnboardingPhotoInitialEvent());
  }

  Future<void> _onInitial(
    OnboardingPhotoInitialEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) async {
    try {
      _chatUser = (await _firestoreRepository.getUser())!;
      emit(OnboardingPhotoBaseState(_chatUser));
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onCameraClicked(
    OnboardingPhotoCameraClickedEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) async {
    final currentState = state;
    try {
      final pickedFile = await picker.pickImage(
          maxHeight: 400,
          maxWidth: 400,
          source: ImageSource.camera,
          imageQuality: photoQuality);
      if (pickedFile != null) {
        CroppedFile? croppedFile =
            await _appImageCropper.cropImage(pickedFile);
        if (currentState is OnboardingPhotoBaseState && croppedFile != null) {
          emit(OnboardingPhotoDoneState(croppedFile.path, ''));
        } else if (currentState is OnboardingPhotoDoneState &&
            croppedFile != null) {
          emit(currentState.copyWith(filePath: croppedFile.path));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onGalleryClicked(
    OnboardingPhotoGalleryClickedEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) async {
    final currentState = state;
    try {
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

          emit(OnboardingPhotoDoneState(croppedFile.path, base64Image));
        } else if (currentState is OnboardingPhotoDoneState &&
            croppedFile != null) {
          emit(currentState.copyWith(filePath: croppedFile.path));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onContinueClicked(
    OnboardingPhotoContinueClickedEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) async {
    final currentState = state;
    try {
      if (currentState is OnboardingPhotoDoneState) {
        emit(OnboardingPhotoLoadingState());
        final hasNudity =
            await FlutterNudeDetector.detect(path: currentState.filePath);
        final imageUrl = await _storageRepository.uploadProfileImage(
            currentState.filePath, currentState.base64Image);
        final finalUrl = await imageUrl?.getDownloadURL() ?? "";
        await _firestoreRepository.updateUserProfileImage(
            profileImageUrl: finalUrl, user: _chatUser, hasNudity: hasNudity);

        if (_chatUser.gender == -1) {
          emit(const OnboardingPhotoSuccessState(
              OnboardingNavigation.gender));
        } else {
          emit(const OnboardingPhotoSuccessState(OnboardingNavigation.done));
        }
      }
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }

  void _onRedoClicked(
    OnboardingPhotoRedoClickedEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) {
    final currentState = state;
    try {
      if (currentState is OnboardingPhotoDoneState) {
        emit(OnboardingPhotoRedoState(
            currentState.filePath, currentState.base64Image));
        emit(currentState);
      }
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }

  void _onBottomSheetClosed(
    OnboardingPhotoBottomSheetClosedEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) {
    final currentState = state;
    try {
      if (currentState is OnboardingPhotoDoneState) {
        emit(OnboardingPhotoDoneState(
            currentState.filePath, currentState.base64Image));
      }
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onSkip(
    OnboardingPhotoSkipEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) async {
    try {
      await _firestoreRepository.updateUserProfileImage(
          profileImageUrl: '', user: _chatUser, hasNudity: false);
      if (_chatUser.gender == -1) {
        emit(const OnboardingPhotoSuccessState(OnboardingNavigation.gender));
      } else {
        emit(const OnboardingPhotoSuccessState(OnboardingNavigation.done));
      }
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }

  Future<void> _onRemove(
    OnboardingPhotoRemoveEvent event,
    Emitter<OnboardingPhotoState> emit,
  ) async {
    try {
      emit(OnboardingPhotoLoadingState());
      await _firestoreRepository.deleteUserPhoto();
      emit(const OnboardingPhotoSuccessState(OnboardingNavigation.done));
    } on Exception catch (error, stacktrace) {
      emit(OnboardingPhotoErrorState());
      Log.e('OnboardingPhotoBloc: $error', stackTrace: stacktrace);
    }
  }
}
