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
  bool isDarkMode = true;
  String? errorMessage;
  bool isPasswordError = false;
  bool isLoading = false;
  double passwordStrength = 0.0;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  // ✅ Auto login if saved credentials
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

  // 🧠 Password Strength Logic
  void checkPasswordStrength(String value) {
    double strength = 0;
    if (value.isEmpty) {
      strength = 0;
    } else if (value.length < 6) {
      strength = 0.25;
    } else if (value.contains(RegExp(r'[A-Z]')) &&
        value.contains(RegExp(r'[0-9]'))) {
      strength = 0.75;
    } else {
      strength = 0.5;
    }
    setState(() => passwordStrength = strength);
  }

  // 🔐 Login Logic
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

  // ✏️ Input Field Builder
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
      onChanged: password ? checkPasswordStrength : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        suffixIcon: password
            ? Tooltip(
                message: isPasswordVisible ? 'Hide Password' : 'Show Password',
                child: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.cyanAccent,
                  ),
                  onPressed: () =>
                      setState(() => isPasswordVisible = !isPasswordVisible),
                ),
              )
            : null,
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: error ? Colors.red : Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: error ? Colors.red : Colors.cyanAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // 🌈 Password Strength Bar
  Widget buildPasswordStrengthBar() {
    if (passwordStrength == 0) return const SizedBox.shrink();
    Color color;
    String text;
    if (passwordStrength <= 0.25) {
      color = Colors.red;
      text = 'Weak';
    } else if (passwordStrength <= 0.5) {
      color = Colors.orange;
      text = 'Medium';
    } else {
      color = Colors.green;
      text = 'Strong';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: passwordStrength,
              color: color,
              backgroundColor: Colors.white24,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  // 🧩 Active UI Policy Link
  Widget policyLink(String title, Widget page) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
            color: Colors.cyanAccent.withOpacity(0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.policy_outlined,
                color: Colors.cyanAccent,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.png', height: 100),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: isMobile ? 26 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Login to your account",
                    style: TextStyle(color: Colors.white70),
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
                  buildPasswordStrengthBar(),

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
                  ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 48),
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
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 20),

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
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // 🌟 ACTIVE POLICY LINKS
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      policyLink("Privacy Policy", const PrivacyPolicyPage()),
                      policyLink(
                        "Terms & Conditions",
                        const TermsConditionsPage(),
                      ),
                      policyLink("Refund Policy", const RefundPolicyPage()),
                    ],
                  ),

                  const SizedBox(height: 30),
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
    );
  }
}
