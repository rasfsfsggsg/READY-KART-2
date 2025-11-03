import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ready_cart/pages/profile_tab.dart';
import 'package:ready_cart/screens/navigation/update_password_section.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../login_screen.dart';

// ✅ Import Privacy Pages (same as Login)
import '../privacy/privacy_policy.dart';
import '../privacy/terms_conditions.dart';
import '../privacy/refund_policy.dart';

class SideDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const SideDrawer({super.key, this.scaffoldKey});

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? profileImageUrl;

  // ✅ Policy Versioning
  final String privacyPolicyVersion = "1.2";
  final String termsConditionsVersion = "1.2";
  final String refundPolicyVersion = "1.0";

  final gradientColors = const [
    Color(0xFF0A0F1C),
    Color(0xFF14233A),
    Color(0xFF1A3E59),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data();
        if (doc.exists && data != null && mounted) {
          setState(() {
            userName = data['name'] ?? 'No Name';
            userEmail = data['email'] ?? user.email ?? 'No Email';
            profileImageUrl = data['profileImage'];
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        userName = 'Error';
        userEmail = 'Error';
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw Exception('Could not launch');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open link. Please check your internet.'),
        ),
      );
    }
  }

  void _shareApp() {
    Share.share(
      'Check out Battle Lobby: https://play.google.com/store/apps/details?id=com.example.app',
      subject: 'Battle Lobby',
    );
  }

  void _showGradientDialog({required String title, required String content}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0F1C),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.cyanAccent),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('OK', style: TextStyle(color: Colors.redAccent)),
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.cyanAccent),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            profileImageUrl != null
                ? CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(profileImageUrl!),
                  )
                : const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_circle,
                      size: 70,
                      color: Colors.cyanAccent,
                    ),
                  ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (widget.scaffoldKey != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () =>
                    widget.scaffoldKey!.currentState?.closeDrawer(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = MediaQuery.of(context).size.width > 600;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),

            // Existing features preserved ✅
            _buildTile(Icons.person_outline, 'Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }),
            const UpdatePasswordSection(),
            _buildTile(Icons.share, 'Share App', _shareApp),

            // ✅ Added: Full Policy Section (same as login)
            const Divider(color: Colors.white30, indent: 16, endIndent: 16),
            _buildTile(
              Icons.description_outlined,
              'Terms & Conditions (v1.2)',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsConditionsPage(),
                  ),
                );
              },
            ),
            _buildTile(Icons.privacy_tip_outlined, 'Privacy Policy (v1.2)', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              );
            }),
            _buildTile(Icons.receipt_long_outlined, 'Refund Policy (v1.0)', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RefundPolicyPage()),
              );
            }),

            const Divider(color: Colors.white30, indent: 16, endIndent: 16),

            // Support Links
            _buildTile(FontAwesomeIcons.whatsapp, 'WhatsApp Support', () {
              _launchURL('https://wa.me/917222986276');
            }, iconColor: Colors.green),
            _buildTile(
              FontAwesomeIcons.telegram,
              'Telegram – Contact Us',
              () {
                _launchURL('http://t.me/battlelobbycustomersupport');
              },
              iconColor: Colors.blue,
            ),
            _buildTile(FontAwesomeIcons.envelope, 'Email Support', () {
              _launchURL('mailto:battlelobby.help@gmail.com');
            }, iconColor: Colors.orange),

            const Divider(color: Colors.white30, indent: 16, endIndent: 16),

            // Socials
            _buildTile(FontAwesomeIcons.instagram, 'Instagram', () {
              _launchURL('https://www.instagram.com/battlelobby_official');
            }, iconColor: Colors.pink),
            _buildTile(FontAwesomeIcons.youtube, 'YouTube', () {
              _launchURL('https://youtube.com/@nexxer0999h');
            }, iconColor: Colors.red),

            _buildTile(FontAwesomeIcons.envelopeOpenText, 'Contact Us', () {
              _showGradientDialog(
                title: 'Contact Us',
                content:
                    'For help, email: battlelobby.help@gmail.com\n\nPolicy Versions:\n• Privacy v$privacyPolicyVersion\n• Terms v$termsConditionsVersion\n• Refund v$refundPolicyVersion',
              );
            }),
            _buildTile(FontAwesomeIcons.gamepad, '🕹 About Us', () {
              _showGradientDialog(
                title: '🕹 About Us',
                content:
                    'Battle Lobby is your ultimate eSports companion app.\n\nApp Version: 1.0.0\nPrivacy v$privacyPolicyVersion | Terms v$termsConditionsVersion | Refund v$refundPolicyVersion',
              );
            }),

            const Divider(color: Colors.white30, indent: 16, endIndent: 16),

            // Logout
            _buildTile(
              Icons.logout,
              'Logout',
              _showLogoutConfirmDialog,
              iconColor: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
