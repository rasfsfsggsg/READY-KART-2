import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final String? selectedId;
  final Function(String) onCategorySelected;

  const CategoryChips({
    required this.selectedId,
    required this.onCategorySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('categories');
    final isWide = MediaQuery.of(context).size.width > 900;

    return SizedBox(
      height: 60,
      child: StreamBuilder<QuerySnapshot>(
        stream: col.snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No categories found",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final name = d['name'] ?? '';
              final isSelected = selectedId == docs[i].id;

              return GestureDetector(
                onTap: () => onCategorySelected(docs[i].id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.cyanAccent.withOpacity(0.9)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.cyanAccent : Colors.white24,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isWide ? 16 : 14,
                        color: isSelected ? Colors.black87 : Colors.white70,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
