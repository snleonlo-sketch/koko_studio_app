import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';

import 'themes/theme_provider.dart';

import 'services/notification_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await NotificationService.init();

  runApp(

    ChangeNotifierProvider(

      create: (_) => ThemeProvider(),

      child: const KokoStudioApp(),
    ),
  );
}

class KokoStudioApp
    extends StatelessWidget {

  const KokoStudioApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final themeProvider =

    Provider.of<ThemeProvider>(
      context,
    );

    return MaterialApp(

      debugShowCheckedModeBanner:
      false,

      title: 'Koko Studio',

      themeMode:
      themeProvider.themeMode,

      theme: ThemeData(

        brightness:
        Brightness.light,

        primaryColor:
        const Color(0xFFD9A5B3),

        scaffoldBackgroundColor:
        const Color(0xFFFFF5F7),

        appBarTheme:
        const AppBarTheme(

          backgroundColor:
          Color(0xFFD9A5B3),

          foregroundColor:
          Colors.black,
        ),
      ),

      darkTheme: ThemeData(

        brightness:
        Brightness.dark,

        primaryColor:
        const Color(0xFFD9A5B3),

        scaffoldBackgroundColor:
        const Color(0xFF1E1E1E),

        appBarTheme:
        const AppBarTheme(

          backgroundColor:
          Color(0xFF2C2C2C),

          foregroundColor:
          Colors.white,
        ),
      ),

      home:
      const SplashScreen(),
    );
  }
}