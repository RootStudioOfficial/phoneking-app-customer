import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phonekingcustomer/page/auth/splash_page.dart';
import 'package:phonekingcustomer/persistent/language_persistent.dart';
import 'package:phonekingcustomer/services/notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationHandler.initialize();

  await EasyLocalization.ensureInitialized();
  final languageService = LanguagePersistent();
  await languageService.init();
  final initialLocale = languageService.currentLocale;
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('my')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: initialLocale,
      child: MyApp(languageService: languageService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final LanguagePersistent languageService;

  const MyApp({super.key, required this.languageService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHandler.handlePendingInitialMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationHandler.navigatorKey,
      title: 'Phone King',
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: SplashPage(),
    );
  }
}
