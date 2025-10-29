import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdatePasswordSection extends StatefulWidget {
  const UpdatePasswordSection({super.key});

  @override
  _UpdatePasswordSectionState createState() => _UpdatePasswordSectionState();
}

class _UpdatePasswordSectionState extends State<UpdatePasswordSection> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isVisible = false;
  bool isLoading = false;

  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  Future<void> _updatePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnack("❗ सभी पासवर्ड फ़ील्ड भरें");
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnack("❗ नया पासवर्ड और पुष्टि मेल नहीं खा रहे");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        _showSnack("❌ यूज़र लॉगिन नहीं है");
        return;
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      _showSnack("✅ पासवर्ड सफलतापूर्वक अपडेट हुआ");
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      setState(() => isVisible = false);
    } catch (e) {
      _showSnack("❌ पासवर्ड अपडेट में त्रुटि: ${e.toString()}");
    }

    setState(() => isLoading = false);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback toggleVisibility,
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
          obscureText: !showPassword,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            prefixIcon: const Icon(Icons.lock, color: Colors.cyanAccent),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.cyanAccent,
              ),
              onPressed: toggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
              const BorderSide(color: Colors.cyanAccent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final arrowIcon =
    isVisible ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header row (expand/collapse)
          ListTile(
            leading: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.cyanAccent.withOpacity(0.1),
              child: const Icon(Icons.lock, size: 22, color: Colors.cyanAccent),
            ),
            title: const Text(
              "Update Password",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            trailing: Icon(arrowIcon, color: Colors.cyanAccent),
            onTap: () => setState(() => isVisible = !isVisible),
          ),

          // Expanded section
          if (isVisible) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildPasswordField(
                    label: "Current Password",
                    controller: currentPasswordController,
                    showPassword: showCurrentPassword,
                    toggleVisibility: () {
                      setState(
                              () => showCurrentPassword = !showCurrentPassword);
                    },
                  ),
                  _buildPasswordField(
                    label: "New Password",
                    controller: newPasswordController,
                    showPassword: showNewPassword,
                    toggleVisibility: () {
                      setState(() => showNewPassword = !showNewPassword);
                    },
                  ),
                  _buildPasswordField(
                    label: "Confirm Password",
                    controller: confirmPasswordController,
                    showPassword: showConfirmPassword,
                    toggleVisibility: () {
                      setState(
                              () => showConfirmPassword = !showConfirmPassword);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _updatePassword,
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
                      child: isLoading
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text("Update Password"),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
