import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchtheme/screens/WearScreens/wearDetailScreen.dart';

// Importa la pantalla de conexión (ajusta la ruta si es necesario)
import 'package:watchtheme/screens/WearScreens/wear_connection.dart';

class HomeWearScreen extends StatefulWidget {
  const HomeWearScreen({super.key});

  @override
  State<HomeWearScreen> createState() => _HomeWearScreenState();
}

class _HomeWearScreenState extends State<HomeWearScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _themesFuture;

  Future<List<Map<String, dynamic>>> fetchThemes() async {
    final response = await supabase
        .from('themes-files')
        .select()
        .order('name', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  void initState() {
    super.initState();
    _themesFuture = fetchThemes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Temas Wear OS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.watch),
            tooltip: 'Conectar con Teléfono',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WearConnectionScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _themesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error al cargar temas',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final themes = snapshot.data ?? [];

          if (themes.isEmpty) {
            return const Center(
              child: Text(
                'No hay temas disponibles.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WearDetailScreen(theme: theme),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: theme['image_url'] != null
                            ? Image.network(
                                theme['image_url'],
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.broken_image, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          theme['name'] ?? 'Sin nombre',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
