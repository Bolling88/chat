import 'package:chat/repository/firestore_repository.dart';
import 'package:chat/repository/login_repository.dart';
import 'package:chat/repository/storage_repository.dart';
import 'package:chat/screens/chat/chat_screen.dart';
import 'package:chat/screens/hero/hero_screen.dart';
import 'package:chat/screens/message_holder/message_holder_screen.dart';
import 'package:chat/screens/onboarding_gender/onboarding_gender_screen.dart';
import 'package:chat/screens/onboarding_name/onboarding_name_screen.dart';
import 'package:chat/screens/onboarding_photo/onboarding_photo_screen.dart';
import 'package:chat/screens/profile/profile_screen.dart';
import 'package:chat/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/save_file.dart';
import 'utils/simple_bloc_observer.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        fallbackFile: 'en', basePath: 'assets/flutter_i18n'),
    missingTranslationHandler: (key, locale) {
      print(
          "--- Missing Key: $key, languageCode: ${locale?.languageCode ?? ""}");
    },
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(Chat(flutterI18nDelegate: flutterI18nDelegate, prefs: prefs));
  });
}

class Chat extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  final FlutterI18nDelegate flutterI18nDelegate;

  final SharedPreferences prefs;

  Chat({Key? key, required this.flutterI18nDelegate, required this.prefs})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(
            child: Text(FlutterI18n.translate(context, "unknown_error")),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          final SaveFile saveFile = SaveFile(prefs);
          final FirestoreRepository firestoreRepository = FirestoreRepository();
          final LoginRepository loginRepository = LoginRepository();
          final StorageRepository storageRepository = StorageRepository();

          return MultiProvider(
            providers: [
              Provider<SaveFile>.value(value: saveFile),
              Provider<FirestoreRepository>.value(value: firestoreRepository),
              Provider<LoginRepository>.value(value: loginRepository),
              Provider<StorageRepository>.value(value: storageRepository),
            ],
            child: MaterialApp(
              title: 'gambit.ai',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                flutterI18nDelegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: const [Locale('en', 'EN')],
              builder: FlutterI18n.rootAppBuilder(),
              theme: ThemeData(fontFamily: 'chat'),
              home: const SplashScreen(),
              routes: {
                LoginScreen.routeName: (context) => const LoginScreen(),
                OnboardingGenderScreen.routeName: (context) =>
                    const OnboardingGenderScreen(),
                OnboardingNameScreen.routeName: (context) =>
                    const OnboardingNameScreen(),
                OnboardingPhotoScreen.routeName: (context) =>
                    const OnboardingPhotoScreen(),
                ChatScreen.routeName: (context) => const ChatScreen(),
                MessageHolderScreen.routeName: (context) =>
                    const MessageHolderScreen(),
                HeroScreen.routeName: (context) => const HeroScreen(),
                ProfileScreen.routeName: (context) => const ProfileScreen(),
              },
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const LoadingScreen();
      },
    );
  }
}
