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
  // final SupabaseClient supabase = Supabase.instance.client; // Disabled for demo
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? imageFile;
  File? themeFile;
  List<File> extraImages = [];

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
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
        extraImages =
            result.paths.whereType<String>().map((p) => File(p)).toList();
      });
    }
  }

  Future<void> uploadTheme() async {
    final String name = nameController.text.trim();
    final String description = descriptionController.text.trim();

    if (name.isEmpty ||
        description.isEmpty ||
        imageFile == null ||
        themeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields and select files'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // Simulate network request
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme uploaded successfully! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
      }

      nameController.clear();
      descriptionController.clear();
      setState(() {
        imageFile = null;
        themeFile = null;
        extraImages = [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Upload Theme',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E), // Dark Navy
              Color(0xFF16213E), // Dark Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Theme Name',
                      icon: Icons.text_fields,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    _buildUploadCard(
                      title: 'Main Preview Image',
                      subtitle: 'Required',
                      icon: Icons.image,
                      file: imageFile,
                      onTap: pickImage,
                    ),
                    const SizedBox(height: 16),

                    _buildUploadCard(
                      title: 'Extra Screenshots',
                      subtitle:
                          extraImages.isEmpty
                              ? 'Optional'
                              : '${extraImages.length} selected',
                      icon: Icons.collections,
                      file: extraImages.isNotEmpty ? extraImages.first : null,
                      onTap: pickExtraImages,
                      isMultiple: true,
                    ),
                    const SizedBox(height: 16),

                    _buildUploadCard(
                      title: 'Theme File',
                      subtitle: '.zip, .json, .wfs, .hwt',
                      icon: Icons.folder_zip,
                      file: themeFile,
                      onTap: pickThemeFile,
                    ),
                    const SizedBox(height: 40),

                    ElevatedButton.icon(
                      onPressed: uploadTheme,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('UPLOAD THEME'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94560),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFE94560).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE94560)),
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    File? file,
    required VoidCallback onTap,
    bool isMultiple = false,
  }) {
    final bool isSelected = file != null || (isMultiple && file != null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFFE94560).withOpacity(0.1)
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? const Color(0xFFE94560)
                      : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFFE94560).withOpacity(0.2)
                          : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? Icons.check : icon,
                  color: isSelected ? const Color(0xFFE94560) : Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            isSelected
                                ? const Color(0xFFE94560)
                                : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
