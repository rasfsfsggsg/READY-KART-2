import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();
  final referralController = TextEditingController();

  bool isVerificationSent = false;
  bool checkingVerification = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? errorMessage;

  final String selectedUserType = 'Customer';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    referralController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() => errorMessage = 'Passwords do not match');
      return;
    }

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.sendEmailVerification();

      setState(() {
        isVerificationSent = true;
        errorMessage = null;
      });

      Fluttertoast.showToast(
        msg: 'Verification link sent. Check your inbox or spam.',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() => errorMessage = 'Error: ${e.toString()}');
    }
  }

  Future<void> verifyAndSaveUser() async {
    setState(() => checkingVerification = true);
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      try {
        String rawPhone = phoneController.text.trim();
        if (rawPhone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(rawPhone)) {
          setState(() {
            errorMessage = 'Enter valid 10-digit phone number';
            checkingVerification = false;
          });
          return;
        }

        String formattedPhone = '+91$rawPhone';

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'surname': surnameController.text.trim(),
          'phone': formattedPhone,
          'email': emailController.text.trim(),
          'userType': selectedUserType,
          'timestamp': Timestamp.now(),
          if (referralController.text.trim().isNotEmpty)
            'referralCode': referralController.text.trim(),
        });

        Fluttertoast.showToast(
          msg: 'Registration Successful!',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } catch (e) {
        setState(() => errorMessage = 'Error saving data: ${e.toString()}');
      }
    } else {
      setState(() => errorMessage = 'Email not verified yet.');
    }

    setState(() => checkingVerification = false);
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            prefixIcon: Icon(icon, color: Colors.cyanAccent),
            suffixIcon: toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.cyanAccent,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 450 : double.infinity,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    /// Header
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyanAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Fill in your details to register",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 25),

                    /// Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: buildInputField(
                                  label: "First Name",
                                  controller: nameController,
                                  icon: Icons.person,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: buildInputField(
                                  label: "Surname",
                                  controller: surnameController,
                                  icon: Icons.person_outline,
                                ),
                              ),
                            ],
                          ),
                          buildInputField(
                            label: "Phone Number",
                            controller: phoneController,
                            icon: Icons.phone,
                            inputType: TextInputType.phone,
                          ),
                          buildInputField(
                            label: "Email",
                            controller: emailController,
                            icon: Icons.email,
                            inputType: TextInputType.emailAddress,
                          ),
                          buildInputField(
                            label: "Password",
                            controller: passwordController,
                            icon: Icons.lock,
                            obscureText: !isPasswordVisible,
                            toggleObscure: () {
                              setState(
                                () => isPasswordVisible = !isPasswordVisible,
                              );
                            },
                          ),
                          buildInputField(
                            label: "Confirm Password",
                            controller: confirmPasswordController,
                            icon: Icons.lock_outline,
                            obscureText: !isConfirmPasswordVisible,
                            toggleObscure: () {
                              setState(
                                () => isConfirmPasswordVisible =
                                    !isConfirmPasswordVisible,
                              );
                            },
                          ),
                          buildInputField(
                            label: "Referral Code (optional)",
                            controller: referralController,
                            icon: Icons.card_giftcard,
                          ),

                          /// Error Message
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          /// Submit or Verify
                          if (!isVerificationSent)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: registerUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Text("Submit & Send Verification"),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: verifyAndSaveUser,
                              child: checkingVerification
                                  ? const CircularProgressIndicator(
                                      color: Colors.cyanAccent,
                                    )
                                  : const Text(
                                      'Click here after verifying email',
                                      style: TextStyle(
                                        color: Colors.cyanAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),

                          const SizedBox(height: 20),

                          /// Already have account?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.white),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Login',
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
