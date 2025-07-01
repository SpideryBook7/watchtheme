import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class ThemeApplier {
  static bool _isDownloading = false;
  static double _progress = 0.0;

  static Future<void> applyTheme(BuildContext context, Map<String, dynamic> theme) async {
    if (_isDownloading) return; // Evita múltiples descargas simultáneas

    final url = theme['theme_file_url'] ?? '';
    if (url.isEmpty) {
      Fluttertoast.showToast(msg: 'No hay archivo de tema para descargar.');
      return;
    }

    _isDownloading = true;
    _progress = 0.0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DownloadProgressDialog(),
    );

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('No se pudo acceder al almacenamiento.');

      final fileName = url.split('/').last;
      final savePath = '${dir.path}/$fileName';

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _progress = received / total;
            _DownloadProgressDialog.updateProgress(_progress);
          }
        },
      );

      Navigator.of(context).pop(); // Cierra el diálogo

      Fluttertoast.showToast(
        msg: 'Descarga completa. Abre la app "Temas" y aplica el archivo descargado.',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: 'Error al descargar el tema: $e');
    } finally {
      _isDownloading = false;
    }
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  static late _DownloadProgressDialogState _state;

  static void updateProgress(double progress) {
    if (_state.mounted) {
      // ignore: invalid_use_of_protected_member
      _state.setState(() {
        _state._progress = progress;
      });
    }
  }

  @override
  // ignore: no_logic_in_create_state
  State<_DownloadProgressDialog> createState() {
    _state = _DownloadProgressDialogState();
    return _state;
  }
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Descargando tema'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(value: _progress),
          const SizedBox(height: 12),
          Text('${(_progress * 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}
