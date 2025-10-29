import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';
import 'navigation/forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final emailOrPhoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool rememberMe = false;
  String? errorMessage;
  bool isPasswordError = false;
  bool isLoading = false;

  @override
  void dispose() {
    emailOrPhoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // 🔐 Login Logic
  Future<void> loginUser() async {
    final identifier = emailOrPhoneController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      errorMessage = null;
      isPasswordError = false;
    });

    if (identifier.isEmpty || password.isEmpty) {
      setState(
        () => errorMessage =
            'Please enter both identifier (email or phone) and password.',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String loginEmail = '';
      final phoneOnly = RegExp(r'^\d{10}$');
      final emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
        r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
        r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
      );

      if (phoneOnly.hasMatch(identifier)) {
        final formattedPhone = '+91$identifier';
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: formattedPhone)
            .limit(1)
            .get();

        if (querySnapshot.docs.isEmpty) {
          setState(() {
            errorMessage =
                'No account found for this phone number. Please sign up first.';
            isLoading = false;
          });
          return;
        }

        final userDoc = querySnapshot.docs.first;
        final storedEmail = (userDoc.data())['email'] as String?;
        if (storedEmail == null || storedEmail.isEmpty) {
          setState(() {
            errorMessage =
                'No email associated with this phone account. Contact support.';
            isLoading = false;
          });
          return;
        }

        loginEmail = storedEmail;
      } else if (emailRegex.hasMatch(identifier)) {
        loginEmail = identifier;
      } else {
        setState(() {
          errorMessage = 'Enter a valid email or 10-digit phone number.';
          isLoading = false;
        });
        return;
      }

      await _auth.signInWithEmailAndPassword(
        email: loginEmail,
        password: password,
      );

      Fluttertoast.showToast(
        msg: 'Login successful!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Login failed. Please try again.';
      if (e.code == 'user-not-found') {
        msg = 'No account found for this identifier.';
      } else if (e.code == 'wrong-password') {
        msg = 'Incorrect password. Please try again.';
        setState(() => isPasswordError = true);
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        msg = 'This account has been disabled.';
      }
      setState(() => errorMessage = msg);
    } catch (e) {
      setState(() => errorMessage = 'Unexpected error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🌐 Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Fluttertoast.showToast(msg: 'Google sign-in cancelled');
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      final email = user?.email ?? '';

      if (email.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Google account has no email!',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        try {
          await user?.delete();
        } catch (_) {}
        await _auth.signOut();
        await _googleSignIn.signOut();
        Fluttertoast.showToast(
          msg: 'This email is not registered. Please sign up first.',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      Fluttertoast.showToast(
        msg: 'Google login successful!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Google Sign-In failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // ✏️ Reusable Input Field
  Widget buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool password = false,
    bool error = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: password && !isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        suffixIcon: password
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.cyanAccent,
                ),
                onPressed: () =>
                    setState(() => isPasswordVisible = !isPasswordVisible),
              )
            : null,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: error ? Colors.red : Colors.white.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: error ? Colors.red : Colors.white.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: error ? Colors.red : Colors.cyanAccent),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1C), Color(0xFF14233A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🖼️ Logo or Title
                    Image.asset('assets/logo.png', height: 100),
                    const SizedBox(height: 20),
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: isMobile ? 26 : 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Login to your account",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    buildInput(
                      label: "Email or Mobile (10 digits)",
                      icon: Icons.person,
                      controller: emailOrPhoneController,
                    ),
                    const SizedBox(height: 18),
                    buildInput(
                      label: "Password",
                      icon: Icons.lock,
                      controller: passwordController,
                      password: true,
                      error: isPasswordError,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (v) =>
                                  setState(() => rememberMe = v ?? false),
                              activeColor: Colors.cyanAccent,
                            ),
                            const Text(
                              "Remember me",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "LOGIN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.3)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "or",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white.withOpacity(0.3)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    OutlinedButton.icon(
                      onPressed: signInWithGoogle,
                      icon: Image.asset('assets/google.png', height: 22),
                      label: const Text(
                        "Continue with Google",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don’t have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
