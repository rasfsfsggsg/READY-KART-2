import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoriesList extends StatelessWidget {
  final Function(String) onCategorySelected;
  final String? selectedId;

  const CategoriesList({
    super.key,
    required this.onCategorySelected,
    this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('categories');

    return SizedBox(
      height: 120,
      child: StreamBuilder<QuerySnapshot>(
        stream: col.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          if (!snap.hasData) {
            return const Center(
              child: Text(
                "No categories found",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final docs = snap.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final name = data['name'] ?? '';
              final iconUrl = data['iconUrl'] ?? '';
              final isSelected = selectedId == docs[i].id;

              return GestureDetector(
                onTap: () => onCategorySelected(docs[i].id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00BCD4), Color(0xFF006D77)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: iconUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: iconUrl,
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                  ),
                                )
                              : const Icon(
                                  Icons.local_offer_outlined,
                                  color: Colors.cyanAccent,
                                  size: 22,
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E2D47),
                        ),
                      ),
                    ],
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
