import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchtheme/screens/TvScreens/TvDetailScreen.dart';

class HomeTVScreen extends StatefulWidget {
  const HomeTVScreen({super.key});

  @override
  State<HomeTVScreen> createState() => _HomeTVScreenState();
}

class _HomeTVScreenState extends State<HomeTVScreen> {
  final _supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _themesFuture;

  @override
  void initState() {
    super.initState();
    _themesFuture = _fetchThemes();
  }

  Future<List<Map<String, dynamic>>> _fetchThemes() async {
    try {
      final response = await _supabase.from('themes-files').select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      debugPrint('Error al obtener temas: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _themesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar temas.\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No hay temas disponibles.',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              );
            }

            final themes = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Text(
                    'Explora Temas',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 16 / 9,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: themes.length,
                    itemBuilder: (context, index) {
                      final theme = themes[index];
                      final path = theme['image_url'];

                      final imageUrl = (path != null && path.toString().isNotEmpty)
                          ? (path.toString().startsWith('http')
                              ? path.toString()
                              : 'https://ewtzyzsoktdpphzjmteu.supabase.co/storage/v1/object/public/themes-files/$path')
                          : null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TvDetailScreen(theme: theme),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade900.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.shade900.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: imageUrl != null
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.white54, size: 40),
                                              ),
                                        )
                                      : const Center(
                                          child: Icon(Icons.image_not_supported,
                                              color: Colors.white38, size: 40),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      theme['name'] ?? 'Sin nombre',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
