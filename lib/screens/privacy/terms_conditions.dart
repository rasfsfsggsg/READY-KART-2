import 'dart:html' as html;
import 'package:flutter/material.dart';

class RefundPolicyPage extends StatelessWidget {
  const RefundPolicyPage({super.key});

  void downloadRefundPolicy() {
    const content = '''
Refund Policy - ReadyKart

We strive for customer satisfaction. If you're not satisfied, please check our refund terms:

1. Refund Eligibility
Refunds apply only for damaged, incorrect, or missing items within 3 days of delivery.

2. Refund Process
Once approved, refunds are processed to your original payment method within 7 business days.

3. Cancellation Policy
Orders can be cancelled before dispatch. Shipped orders cannot be cancelled.

Contact us: support@readykart.com
''';
    final blob = html.Blob([content]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "RefundPolicy.txt")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Refund Policy"),
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
                          "Refund Policy",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "We aim for customer satisfaction. If you face any issue, refer to our refund terms below.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "1. Refund Eligibility",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Refunds are valid for defective or incorrect products reported within 3 days.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "2. Refund Process",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Once approved, refunds are processed back to your original payment method within 7 working days.",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "3. Cancellation Policy",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Orders can be cancelled before shipment. Once shipped, cancellations are not accepted.",
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
                        onPressed: downloadRefundPolicy,
                        icon: const Icon(Icons.download),
                        label: const Text("Download Policy"),
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
