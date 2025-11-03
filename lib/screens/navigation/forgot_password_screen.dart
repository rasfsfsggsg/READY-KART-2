import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  final List<Color> gradientColors = const [
    Color(0xFF0A0F1C), // Deep Navy
    Color(0xFF14233A), // Dark Blue
  ];

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter your email',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      // ✅ Step 1: Check Firestore for user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Fluttertoast.showToast(
          msg: 'User not found',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // ✅ Step 2: Send reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: 'Reset link sent. Check your inbox or spam.',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Colors.cyanAccent, Colors.blue],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.black),
            if (icon != null) const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop
                    ? 400
                    : double
                          .infinity, // 📱 Mobile full, 💻 Desktop centered box
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Header
                  const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your email to receive a reset link",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 30),

                  /// 🔹 Email Input
                  buildInputField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email,
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 30),

                  /// 🔹 Reset Button
                  buildGradientButton(
                    text: "Send Reset Email",
                    icon: Icons.send,
                    onPressed: resetPassword,
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Footer
                  const Center(
                    child: Text(
                      "We'll send you an email to reset your password.",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
