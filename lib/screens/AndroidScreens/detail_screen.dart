import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:watchtheme/screens/AndroidScreens/apply_theme_screen.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> theme;

  const DetailScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    List<String> gallery = [];
    var rawGallery = theme['gallery_urls'];

    if (rawGallery is String && rawGallery.isNotEmpty) {
      try {
        List<dynamic> decoded = jsonDecode(rawGallery);
        gallery = decoded.map((e) => e.toString()).toList();
      } catch (e) {
        gallery = [];
      }
    } else if (rawGallery is List) {
      gallery = rawGallery.map((e) => e.toString()).toList();
    }

    final List<String> allImages = [
      if (theme['image_url'] != null &&
          theme['image_url'].toString().isNotEmpty)
        theme['image_url'].toString(),
      ...gallery,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: Text(theme['name'] ?? 'Detalles'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RectangularImageCarousel(images: allImages),
            const SizedBox(height: 20),
            Text(
              theme['name'] ?? 'Sin nombre',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              theme['description'] ?? 'Sin descripción disponible.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.devices, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Compatible con: ${theme['device'] ?? 'TV, Reloj y Teléfono'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ThemeApplier.applyTheme(context, theme);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text("Aplicar"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 221, 201, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Volver"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.deepPurple),
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RectangularImageCarousel extends StatefulWidget {
  final List<String> images;

  const RectangularImageCarousel({super.key, required this.images});

  @override
  State<RectangularImageCarousel> createState() =>
      _RectangularImageCarouselState();
}

class _RectangularImageCarouselState extends State<RectangularImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  final double _viewportFraction = 0.6;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              bool isActive = index == _currentPage;
              double scale = isActive ? 1.05 : 0.85;
              double opacity = isActive ? 1.0 : 0.5;
              final width = 220.0;
              final height = 140.0;

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Center(
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: width,
                              height: height,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: isActive ? 12 : 6,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                                border: Border.all(
                                  color:
                                      isActive
                                          ? const Color.fromARGB(
                                            255,
                                            234,
                                            231,
                                            238,
                                          )
                                          : Colors.deepPurple.shade200,
                                  width: isActive ? 4 : 2,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.network(
                                widget.images[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          progress.expectedTotalBytes != null
                                              ? progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes!
                                              : null,
                                      color: Colors.deepPurple,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Indicadores circulares
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (i) {
            bool active = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: active ? 18 : 12,
              height: active ? 18 : 12,
              decoration: BoxDecoration(
                color: active ? Colors.deepPurple : Colors.deepPurple.shade100,
                shape: BoxShape.circle,
                boxShadow:
                    active
                        ? [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                        : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}
