import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 🔁 Background animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _checkUser();
  }

  Future<void> _checkUser() async {
    // ⏳ 3-second splash (instead of 2 minutes for web)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF00172D),
                    const Color(0xFF002E5D),
                    _controller.value,
                  )!.withOpacity(1),
                  Color.lerp(
                    const Color(0xFF002E5D),
                    const Color(0xFF0A2342),
                    _controller.value,
                  )!.withOpacity(1),
                ],
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 25,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🧊 Neon Title
                    Text(
                      "READY",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF00E5FF),
                        fontSize: size.width < 600 ? 48 : 68,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            blurRadius: 30,
                            color: Colors.cyanAccent.withOpacity(0.9),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "CART",
                      style: TextStyle(
                        color: const Color(0xFF2196F3),
                        fontSize: size.width < 600 ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      "Fast • Easy • Secure checkout experience",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Loader
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: CircularProgressIndicator(
                        strokeWidth: 5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF00E5FF),
                        ),
                        backgroundColor: Colors.blueGrey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
