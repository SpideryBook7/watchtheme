import 'package:flutter/material.dart';

class TvDetailScreen extends StatelessWidget {
  final Map<String, dynamic> theme;

  const TvDetailScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda con imagen, tarjeta y botones
              Column(
                children: [
                  // Imagen del tema
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      theme['image_url'] ?? '',
                      width: 360,
                      height: 340,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(
                            Icons.broken_image,
                            size: 80,
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta del dispositivo
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color.fromARGB(255, 199, 77, 255),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Dispositivo: ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme['device'] ?? 'Desconocido',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(218, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botones
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: lógica para aplicar tema
                        },
                        icon: const Icon(Icons.watch),
                        label: const Text("Aplicar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            110,
                            238,
                            226,
                          ),
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Regresar"),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(width: 24),

              // Columna derecha: nombre + descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme['name'] ?? 'Sin nombre',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          theme['description'] ?? 'Sin descripción',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
