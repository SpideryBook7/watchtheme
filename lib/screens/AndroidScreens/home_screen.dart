// home_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchtheme/screens/AndroidScreens/detail_screen.dart';
import 'package:watchtheme/screens/AndroidScreens/upload_theme_screen.dart';
import 'package:watchtheme/screens/AndroidScreens/connection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _themesFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _themesFuture = fetchThemes();
  }

  Future<List<Map<String, dynamic>>> fetchThemes() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockThemes;
  }

  final List<Map<String, dynamic>> _mockThemes = [
    {
      'name': 'Neon Cyberpunk',
      'description': 'Futuristic high-contrast dark theme with neon accents.',
      'image_url':
          'https://images.unsplash.com/photo-1555680202-c86f0e12f086?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Ocean Breeze',
      'description': 'Calm blue gradients inspired by the deep sea.',
      'image_url':
          'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Sunset Glow',
      'description': 'Warm orange and purple hues for a relaxing vibe.',
      'image_url':
          'https://images.unsplash.com/photo-1472120435266-53107fd0c44a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Minimalist White',
      'description': 'Clean, distraction-free light theme.',
      'image_url':
          'https://images.unsplash.com/photo-1494438639946-1ebd1d20bf85?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    },
    {
      'name': 'Forest Deep',
      'description': 'Natural greens and earthy tones.',
      'image_url':
          'https://images.unsplash.com/photo-1448375240586-dfd8d395ea6c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
        title: const Text(
          'Watch Themes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.login, color: Colors.white),
            tooltip: 'Connect',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectionScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E), // Dark Navy
              Color(0xFF16213E), // Dark Blue
              Color(0xFF0F3460), // Deep Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Bar Area
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onChanged:
                          (value) => setState(
                            () => _searchQuery = value.toLowerCase(),
                          ),
                      decoration: InputDecoration(
                        hintText: 'Find your style...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _themesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurpleAccent,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Error loading themes",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    }

                    final themes = snapshot.data ?? [];
                    final filtered =
                        themes
                            .where(
                              (theme) =>
                                  theme['name']
                                      ?.toString()
                                      .toLowerCase()
                                      .contains(_searchQuery) ??
                                  false,
                            )
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No themes found matching "$_searchQuery"',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Responsive Grid Layout
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // Dynamic crossAxisCount based on width
                        int crossAxisCount = 2;
                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 5;
                        } else if (constraints.maxWidth > 900) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 3;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75, // Taller cards
                              ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final theme = filtered[index];
                            return _buildThemeCard(context, theme);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadThemeScreen()),
          );
        },
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Upload'),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, Map<String, dynamic> theme) {
    return Hero(
      tag: theme['name'] ?? 'unknown',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(theme: theme)),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          theme['image_url'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                ),
                              ),
                        ),
                        // Gradient Overlay for text readability if needed
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.6),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme['name'] ?? 'Untitled',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme['description'] ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
