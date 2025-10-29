import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _currentPage = 0;

  void _startAutoScroll(int itemCount) {
    _timer?.cancel();
    if (itemCount == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _currentPage = (_currentPage + 1) % itemCount;
      if (mounted) {
        _controller.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slidesRef = FirebaseFirestore.instance
        .collection('slides')
        .orderBy('createdAt', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: slidesRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          );
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'No slides available',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        }

        _startAutoScroll(docs.length);

        return Column(
          children: [
            SizedBox(
              height: 250, // Increased height
              child: PageView.builder(
                controller: _controller,
                itemCount: docs.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final image = data['imageUrl'] as String? ?? '';

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12, // slightly wider
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: image.isNotEmpty
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(image),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: image.isEmpty ? Colors.grey[300] : null,
                    ),
                    child: Stack(
                      children: [
                        // 🔹 Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 🔹 Optional text overlay
                        Positioned(
                          bottom: 24,
                          left: 20,
                          child: Text(
                            data['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  blurRadius: 4,
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🔹 Page Indicator Dots
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                docs.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentPage == index ? 22 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.cyanAccent
                        : Colors.cyanAccent.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
