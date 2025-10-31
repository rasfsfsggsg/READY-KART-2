import 'dart:html' as html;
import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  void downloadTerms() {
    const content = '''
Terms & Conditions - ReadyKart

Welcome to ReadyKart. By using our services, you agree to comply with the following terms.

1. Account Responsibility
You must provide valid details. Misuse may result in suspension.

2. Product Information
We ensure accurate product details but are not liable for third-party errors.

3. Payments & Refunds
All transactions are processed securely. Refunds follow our refund policy.

4. Intellectual Property
All content, design, and branding belong to ReadyKart.
''';
    final blob = html.Blob([content]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "TermsConditions.txt")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Terms & Conditions",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "By using ReadyKart, you agree to the following terms and conditions. Please read carefully.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "1. Account Responsibility",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "You are responsible for the accuracy of your account details and activity.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "2. Product Information",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "We ensure that all product data is correct but minor variations may occur.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "3. Payments & Refunds",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Payments are handled by secure gateways. Refunds are subject to policy conditions.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: downloadTerms,
                        icon: const Icon(Icons.download),
                        label: const Text("Download Terms"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          html.window.open(
                            "mailto:support@readykart.com",
                            "_blank",
                          );
                        },
                        icon: const Icon(Icons.email, color: Colors.cyanAccent),
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
    );
  }
}
