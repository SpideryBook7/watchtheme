import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class UploadThemeScreen extends StatefulWidget {
  const UploadThemeScreen({super.key});

  @override
  State<UploadThemeScreen> createState() => _UploadThemeScreenState();
}

class _UploadThemeScreenState extends State<UploadThemeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? imageFile;
  File? themeFile;
  List<File> extraImages = [];

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> pickThemeFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['zip', 'json', 'wfs', 'hwt'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        themeFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> pickExtraImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        extraImages = result.paths.whereType<String>().map((p) => File(p)).toList();
      });
    }
  }

  Future<void> uploadTheme() async {
    final String name = nameController.text.trim();
    final String description = descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty || imageFile == null || themeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos y selecciona los archivos')),
      );
      return;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Subir imagen principal
      final imagePath = 'themes/images/${timestamp}_${imageFile!.path.split('/').last}';
      await supabase.storage.from('themes-files').upload(imagePath, imageFile!);
      final imageUrl = supabase.storage.from('themes-files').getPublicUrl(imagePath);

      // Subir archivo del tema
      final themePath = 'themes/files/${timestamp}_${themeFile!.path.split('/').last}';
      await supabase.storage.from('themes-files').upload(themePath, themeFile!);
      final themeUrl = supabase.storage.from('themes-files').getPublicUrl(themePath);

      // Subir imágenes extra (galería)
      List<String> galleryUrls = [];
      for (var file in extraImages) {
        final path = 'themes/gallery/${timestamp}_${file.path.split('/').last}';
        await supabase.storage.from('themes-files').upload(path, file);
        final url = supabase.storage.from('themes-files').getPublicUrl(path);
        galleryUrls.add(url);
      }

      // Insertar en Supabase
      await supabase.from('themes-files').insert({
        'name': name,
        'description': description,
        'image_url': imageUrl,
        'theme_file_url': themeUrl,
        'gallery_urls': galleryUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tema subido correctamente')),
      );

      nameController.clear();
      descriptionController.clear();
      setState(() {
        imageFile = null;
        themeFile = null;
        extraImages = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Subir Tema', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(nameController, 'Nombre del tema'),
            const SizedBox(height: 12),
            _buildTextField(descriptionController, 'Descripción'),
            const SizedBox(height: 24),

            _buildUploadButton(
              icon: Icons.image,
              label: imageFile == null ? 'Seleccionar Imagen Principal' : 'Imagen seleccionada',
              onTap: pickImage,
              filled: imageFile != null,
            ),
            const SizedBox(height: 12),

            _buildUploadButton(
              icon: Icons.collections,
              label: extraImages.isEmpty
                  ? 'Seleccionar Imágenes Extras'
                  : '${extraImages.length} imagen(es) seleccionada(s)',
              onTap: pickExtraImages,
              filled: extraImages.isNotEmpty,
            ),
            const SizedBox(height: 12),

            _buildUploadButton(
              icon: Icons.file_present,
              label: themeFile == null ? 'Seleccionar Archivo del Tema' : 'Archivo seleccionado',
              onTap: pickThemeFile,
              filled: themeFile != null,
            ),
            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: uploadTheme,
              icon: const Icon(Icons.upload),
              label: const Text('Subir Tema'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 221, 201, 255),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: filled ? Colors.deepPurple : Colors.grey),
        label: Text(
          label,
          style: TextStyle(color: filled ? Colors.deepPurple : Colors.grey[600]),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          side: BorderSide(color: filled ? Colors.deepPurple : Colors.grey[400]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
