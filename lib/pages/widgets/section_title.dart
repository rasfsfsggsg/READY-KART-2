import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 32 : 16, vertical: 12),
      child: Row(
        children: [
          // Title with gradient accent underline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 50,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.blueAccent],
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Optional trailing widget (like "See All")
          if (trailing != null)
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              child: trailing!,
            ),
        ],
      ),
    );
  }
}
