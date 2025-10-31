import 'dart:html' as html; // For Flutter web download
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  void downloadPolicy() {
    const content = '''
Privacy Policy - ReadyKart

At ReadyKart, we value your privacy. This document explains how we collect, use, and protect your personal data.

1. Data Collection
We collect basic information such as name, email, phone number, and address only for processing orders.

2. Payment Security
All payments are processed securely through Razorpay. We never store your card or payment details.

3. Usage of Data
Your data is used solely for order tracking, updates, and occasional promotional offers.

4. Third-Party Services
We may use trusted partners for analytics or delivery purposes while ensuring your data privacy.

Contact Us:
support@readykart.com
''';
    final blob = html.Blob([content]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "PrivacyPolicy.txt")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.cyanAccent.withOpacity(0.2),
        foregroundColor: Colors.cyanAccent,
        elevation: 0,
      ),
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
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Privacy Policy",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "At ReadyKart, we value your privacy. This document explains how we collect, use, and protect your personal data.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "1. Data Collection",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "We collect name, email, phone, and address only to process your orders securely.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "2. Payment Security",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "All payments are handled by Razorpay with top-level encryption.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "3. Data Usage",
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Your data is never sold or shared for unrelated purposes.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: downloadPolicy,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.download),
                          label: const Text("Download Policy"),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            html.window.open(
                              "mailto:support@readykart.com",
                              "_blank",
                            );
                          },
                          icon: const Icon(
                            Icons.email_outlined,
                            color: Colors.cyanAccent,
                          ),
                          label: const Text(
                            "Contact Support",
                            style: TextStyle(color: Colors.cyanAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        "© 2025 ReadyKart | All Rights Reserved",
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
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
