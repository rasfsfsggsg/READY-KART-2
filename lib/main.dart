import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 👇 आपकी अपनी फाइलें
import 'firebase_options.dart'; // ✅ नया Import (flutterfire configure से)
import 'screens/splash_screen.dart';
import 'screens/home.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Firebase initialize with generated options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BattleLobbyApp());
}

class BattleLobbyApp extends StatelessWidget {
  const BattleLobbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battle Lobby',
      debugShowCheckedModeBanner: false,

      // ✅ अब ThemeProvider हट गया, सिर्फ default theme और dark theme रहेंगे
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF1877F2),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1877F2),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF1C1E21)),
          bodyMedium: TextStyle(color: Color(0xFF1C1E21)),
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFFFFFF)),
        fontFamily: 'Roboto',
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1877F2),
        scaffoldBackgroundColor: const Color(0xFF1C1E21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1C1E21),
          iconTheme: IconThemeData(color: Color(0xFF1877F2)),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1C1E21)),
        fontFamily: 'Roboto',
      ),

      // Default theme mode
      themeMode: ThemeMode.system,

      home: const AppWithSplashAndAuth(),
    );
  }
}

class AppWithSplashAndAuth extends StatefulWidget {
  const AppWithSplashAndAuth({super.key});

  @override
  State<AppWithSplashAndAuth> createState() => _AppWithSplashAndAuthState();
}

class _AppWithSplashAndAuthState extends State<AppWithSplashAndAuth> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  // 👉 2 सेकंड का Splash Timer
  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    // 👉 Firebase Auth Status चेक करना
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // जब तक Firebase ready नहीं होता
        }

        // ✅ Agar user logged in hai to HomePage open hoga
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
