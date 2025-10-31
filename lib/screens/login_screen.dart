import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'navigation/forgot_password_screen.dart';
import 'register_screen.dart';
import 'privacy/privacy_policy.dart';
import 'privacy/terms_conditions.dart';
import 'privacy/refund_policy.dart';

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
  bool isLoading = false;
  bool isPasswordError = false;
  String? errorMessage;
  double passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  // ✅ Auto Login
  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('savedEmail');
    final savedPassword = prefs.getString('savedPassword');
    if (savedEmail != null && savedPassword != null) {
      emailOrPhoneController.text = savedEmail;
      passwordController.text = savedPassword;
      rememberMe = true;
      await loginUser(autoLogin: true);
    }
  }

  // 🔐 Login User
  Future<void> loginUser({bool autoLogin = false}) async {
    final identifier = emailOrPhoneController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      errorMessage = null;
      isPasswordError = false;
    });

    if (identifier.isEmpty || password.isEmpty) {
      if (!autoLogin) {
        setState(() {
          errorMessage =
              'Please enter both identifier (email or phone) and password.';
        });
      }
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
        loginEmail = userDoc['email'] ?? '';
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

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('savedEmail', identifier);
        prefs.setString('savedPassword', password);
      }

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
        msg = 'Incorrect password.';
        setState(() => isPasswordError = true);
      }
      setState(() => errorMessage = msg);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // 🌐 Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
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

  // ✏️ Input Field
  Widget buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool password = false,
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
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
        ),
      ),
    );
  }

  // 🧩 Policy Links
  Widget policyLink(String title, Widget page) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.cyanAccent,
          fontSize: 13,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07152A), Color(0xFF0E203A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: 80),
                const SizedBox(height: 18),
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: isMobile ? 26 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Login to your account",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 25),

                buildInput(
                  label: "Email or Mobile (10 digits)",
                  icon: Icons.person,
                  controller: emailOrPhoneController,
                ),
                const SizedBox(height: 15),
                buildInput(
                  label: "Password",
                  icon: Icons.lock,
                  controller: passwordController,
                  password: true,
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (v) => setState(() => rememberMe = v!),
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
                            builder: (_) => const ForgotPasswordScreen(),
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
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(child: Divider(color: Colors.white30)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "or",
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white30)),
                  ],
                ),
                const SizedBox(height: 20),

                OutlinedButton.icon(
                  onPressed: signInWithGoogle,
                  icon: Image.asset('assets/google.png', height: 22),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.white.withOpacity(0.05),
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  children: [
                    policyLink("Privacy Policy", const PrivacyPolicyPage()),
                    policyLink(
                      "Terms & Conditions",
                      const TermsConditionsPage(),
                    ),
                    policyLink("Refund Policy", const RefundPolicyPage()),
                  ],
                ),

                const SizedBox(height: 25),

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
    );
  }
}
