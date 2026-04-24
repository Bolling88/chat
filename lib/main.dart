import 'package:chat/repository/chat_clicked_repository.dart';
import 'package:chat/repository/fcm_repository.dart';
import 'package:chat/repository/supabase_repository.dart';
import 'package:chat/repository/supabase_auth_repository.dart';
import 'package:chat/repository/supabase_presence_repository.dart';
import 'package:chat/repository/supabase_storage_repository.dart';
import 'package:chat/repository/subscription_repository.dart';
import 'package:chat/supabase_config.dart';
import 'package:chat/screens/account/account_screen.dart';
import 'package:chat/screens/message_holder/message_holder_screen.dart';
import 'package:chat/screens/onboarding_age/onboarding_age_screen.dart';
import 'package:chat/screens/onboarding_gender/onboarding_gender_screen.dart';
import 'package:chat/screens/onboarding_name/onboarding_name_screen.dart';
import 'package:chat/screens/onboarding_photo/onboarding_photo_screen.dart';
import 'package:chat/screens/premium/premium_screen.dart';
import 'package:chat/screens/profile/profile_screen.dart';
import 'package:chat/screens/review/review_screen.dart';
import 'package:chat/screens/splash/splash_screen.dart';
import 'package:chat/screens/terms/copyright.dart';
import 'package:chat/screens/terms/eula.dart';
import 'package:chat/screens/terms/privacy.dart';
import 'package:chat/screens/terms/terms.dart';
import 'package:chat/screens/web_premium/web_premium_screen.dart';
import 'package:chat/utils/app_colors.dart';
import 'package:chat/utils/color_schemes.dart';
import 'package:chat/utils/image_util.dart';
import 'package:chat/utils/log.dart';
import 'package:chat/utils/online_users_processor.dart';
import 'package:chat/utils/web_online_user_processor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/simple_bloc_observer.dart';
import 'screens/loading/loading_screen.dart';
import 'screens/login/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  if (!kIsWeb) {
    MobileAds.instance.initialize().then((initializationStatus) {
      initializationStatus.adapterStatuses.forEach((key, value) {
        debugPrint('Adapter status for $key: ${value.description}');
      });
    });
  }

  try {
    if (!kIsWeb) {
      SubscriptionRepository.initPlatformState();
    }
  } catch (e) {
    Log.e("Revenue cat error: $e");
  }

  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        fallbackFile: 'en', basePath: 'assets/flutter_i18n'),
    missingTranslationHandler: (key, locale) {
      Log.d(
          "--- Missing Key: $key, languageCode: ${locale?.languageCode ?? ""}");
    },
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Bloc.observer = SimpleBlocObserver();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(KvitterApp(flutterI18nDelegate: flutterI18nDelegate, prefs: prefs));
  });
}

class KvitterApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = _initializeFirebase();

  static Future<FirebaseApp> _initializeFirebase() async {
    final app = await Firebase.initializeApp();
    return app;
  }

  final FlutterI18nDelegate flutterI18nDelegate;

  final SharedPreferences prefs;

  KvitterApp({super.key, required this.flutterI18nDelegate, required this.prefs});

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
          final OnlineUserProcessor onlineUsersProcessor =
              kIsWeb ? WebOnlineUsersProcessor() : MobileOnlineUsersProcessor();
          final SupabaseRepository supabaseRepository =
              SupabaseRepository(onlineUsersProcessor);
          final SupabaseAuthRepository supabaseAuthRepository =
              SupabaseAuthRepository();
          final SupabaseStorageRepository supabaseStorageRepository =
              SupabaseStorageRepository();
          final FcmRepository fcmRepository =
              FcmRepository(supabaseRepository);
          final AppImageCropper appImageCropper = AppImageCropper(context);
          final SupabasePresenceRepository supabasePresenceRepository =
              SupabasePresenceRepository();
          final ChatClickedRepository chatClickedRepository =
              ChatClickedRepository();
          final SubscriptionRepository subscriptionRepository =
              SubscriptionRepository(supabaseRepository);

          return MultiProvider(
            providers: [
              Provider<SupabaseRepository>.value(value: supabaseRepository),
              Provider<SupabaseAuthRepository>.value(value: supabaseAuthRepository),
              Provider<SupabaseStorageRepository>.value(value: supabaseStorageRepository),
              Provider<SupabasePresenceRepository>.value(value: supabasePresenceRepository),
              Provider<AppImageCropper>.value(value: appImageCropper),
              Provider<FcmRepository>.value(value: fcmRepository),
              Provider<OnlineUserProcessor>.value(value: onlineUsersProcessor),
              Provider<ChatClickedRepository>.value(
                  value: chatClickedRepository),
              Provider<SubscriptionRepository>.value(
                  value: subscriptionRepository),
            ],
            child: MaterialApp(
              title: 'Kvitter',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                flutterI18nDelegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
              supportedLocales: const [
                Locale('en', 'EN'),
                Locale('sv', 'SV'),
                Locale('es', 'ES'),
                Locale('fr', 'FR'),
                Locale('de', 'DE'),
                Locale('hi', 'HI'),
                Locale('pa', 'PA'),
                Locale('ar', 'AR'),
                Locale('ru', 'RU'),
                Locale('pt', 'PT'),
                Locale('ne', 'NE'),
              ],
              builder: FlutterI18n.rootAppBuilder(),
              darkTheme: getDarkTheme(context),
              theme: getLightTheme(context),
              home: const SplashScreen(),
              routes: {
                LoginScreen.routeName: (context) => const LoginScreen(),
                OnboardingGenderScreen.routeName: (context) =>
                    const OnboardingGenderScreen(),
                OnboardingNameScreen.routeName: (context) =>
                    const OnboardingNameScreen(),
                OnboardingPhotoScreen.routeName: (context) =>
                    const OnboardingPhotoScreen(),
                OnboardingAgeScreen.routeName: (context) =>
                    const OnboardingAgeScreen(),
                MessageHolderScreen.routeName: (context) =>
                    const MessageHolderScreen(),
                ProfileScreen.routeName: (context) => const ProfileScreen(),
                AccountScreen.routeName: (context) => const AccountScreen(),
                TermsScreen.routeName: (context) => const TermsScreen(),
                PrivacyScreen.routeName: (context) => const PrivacyScreen(),
                CopyrightScreen.routeName: (context) => const CopyrightScreen(),
                EulaScreen.routeName: (context) => const EulaScreen(),
                ReviewScreen.routeName: (context) => const ReviewScreen(),
                PremiumScreen.routeName: (context) => const PremiumScreen(),
                WebPremiumScreen.routeName: (context) => const WebPremiumScreen(),
              },
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const LoadingScreen();
      },
    );
  }

  ThemeData getLightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      primaryColor: context.main,
      colorScheme: lightColorScheme,
      iconTheme: const IconThemeData(
        color: Colors.white, // <= You can change your color here.
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: context.main,
        elevation: 4,
        surfaceTintColor: context.main,
        titleTextStyle: GoogleFonts.lobster(fontSize: 30, color: context.white),
        shadowColor: Colors.black,
        toolbarTextStyle:
            GoogleFonts.lobster(fontSize: 30, color: context.white),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: context.white,
        titleTextStyle: GoogleFonts.lobster(fontSize: 30, color: context.main),
        contentTextStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.textColor,
            fontSize: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: context.backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lobster(color: context.main),
        displayMedium: TextStyle(
          color: context.textColor,
          fontWeight: FontWeight.w800,
        ),
        displaySmall: GoogleFonts.lobster(color: context.main),
        titleLarge: TextStyle(
          color: context.textColor,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: context.textColor,
          fontWeight: FontWeight.w800,
        ),
        titleSmall: TextStyle(
          color: context.textColor,
          fontWeight: FontWeight.w800,
        ),
        bodyLarge:
            TextStyle(fontWeight: FontWeight.w700, color: context.textColor),
        bodyMedium:
            TextStyle(fontWeight: FontWeight.w600, color: context.textColor),
        bodySmall:
            TextStyle(fontWeight: FontWeight.w500, color: context.textColor),
      ),
    );
  }

  ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF002022),
          elevation: 4,
          surfaceTintColor: context.main,
          titleTextStyle:
              GoogleFonts.lobster(fontSize: 30, color: const Color(0xFFFFFFFF)),
          shadowColor: Colors.black,
          toolbarTextStyle:
              GoogleFonts.lobster(fontSize: 30, color: const Color(0xFFFFFFFF)),
          iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF002022),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF002022),
          titleTextStyle:
              GoogleFonts.lobster(fontSize: 30, color: const Color(0xFF30c7c2)),
          contentTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
              fontSize: 16),
        ),
        textTheme: TextTheme(
            displayLarge: GoogleFonts.lobster(color: const Color(0xFF30c7c2)),
            displayMedium: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w800,
            ),
            displaySmall: GoogleFonts.lobster(color: const Color(0xFF30c7c2)),
            titleLarge: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w800,
            ),
            titleMedium: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w800,
            ),
            titleSmall: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontWeight: FontWeight.w800,
            ),
            bodyLarge: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
            bodyMedium: const TextStyle(
                fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
            bodySmall: const TextStyle(
                fontWeight: FontWeight.w500, color: Color(0xFFFFFFFF))));
  }
}
