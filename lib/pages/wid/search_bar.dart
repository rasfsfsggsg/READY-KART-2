import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchInput({required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search products...",
            hintStyle: TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Colors.cyanAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
