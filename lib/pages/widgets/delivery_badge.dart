import 'package:flutter/material.dart';

class DeliveryBadge extends StatelessWidget {
  final String time; // make it dynamic
  const DeliveryBadge({super.key, this.time = '10 min'});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 16 : 12,
        vertical: isWide ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // subtle glass effect
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_outlined,
            size: 16,
            color: Colors.purpleAccent,
          ),
          const SizedBox(width: 6),
          Text(
            time,
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
