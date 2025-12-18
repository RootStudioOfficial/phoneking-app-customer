import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:phone_king_customer/page/auth/splash_page.dart';
import 'package:phone_king_customer/persistent/language_persistent.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends StatelessWidget {
  final LanguagePersistent languageService;

  const MyApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
