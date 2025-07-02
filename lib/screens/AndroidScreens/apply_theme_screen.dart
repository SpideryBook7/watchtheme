import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nearby_connections/nearby_connections.dart';

class ThemeApplier {
  static bool _isDownloading = false;
  static double _progress = 0.0;

  // Guardar el endpointId del reloj conectado desde fuera de este archivo
  static String? connectedWatchEndpoint;

  static Future<void> applyTheme(BuildContext context, Map<String, dynamic> theme) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DevicePicker(
        onSelect: (String device) {
          Navigator.pop(context);
          if (device == 'android') {
            _downloadToAndroid(context, theme);
          } else if (device == 'watch') {
            _sendToWatch(context, theme);
          } else {
            Fluttertoast.showToast(msg: 'Próximamente compatible con TV.');
          }
        },
      ),
    );
  }

  static Future<void> _downloadToAndroid(BuildContext context, Map<String, dynamic> theme) async {
    if (_isDownloading) return;

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

      Navigator.of(context).pop(); // Cierra diálogo

      Fluttertoast.showToast(
        msg: 'Descarga completa. Abre la app "Temas" para aplicarlo.',
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: 'Error al descargar el tema: $e');
    } finally {
      _isDownloading = false;
    }
  }

  static Future<void> _sendToWatch(BuildContext context, Map<String, dynamic> theme) async {
    final endpointId = connectedWatchEndpoint;
    final url = theme['theme_file_url'] ?? '';
    final name = theme['name'] ?? 'watch_theme';

    if (endpointId == null) {
      Fluttertoast.showToast(msg: 'No hay conexión con el reloj. Conéctalo primero.');
      return;
    }

    if (url.isEmpty) {
      Fluttertoast.showToast(msg: 'No se encontró el archivo del tema.');
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$name.hwt';
      final file = File(filePath);

      if (!await file.exists()) {
        await Dio().download(url, filePath);
      }

      Uint8List bytes = await file.readAsBytes();
      await Nearby().sendBytesPayload(endpointId, bytes);

      Fluttertoast.showToast(msg: 'Tema enviado al reloj exitosamente.');

    } catch (e) {
      Fluttertoast.showToast(msg: 'Error al enviar al reloj: $e');
    }
  }
}

class _DevicePicker extends StatelessWidget {
  final Function(String) onSelect;

  const _DevicePicker({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        ListTile(
          leading: const Icon(Icons.smartphone),
          title: const Text('Aplicar en Android'),
          onTap: () => onSelect('android'),
        ),
        ListTile(
          leading: const Icon(Icons.watch),
          title: const Text('Enviar al Reloj'),
          onTap: () => onSelect('watch'),
        ),
        ListTile(
          leading: const Icon(Icons.tv),
          title: const Text('Aplicar en TV (Próximamente)'),
          onTap: () => onSelect('tv'),
        ),
      ],
    );
  }
}

class _DownloadProgressDialog extends StatefulWidget {
  static late _DownloadProgressDialogState _state;

  static void updateProgress(double progress) {
    if (_state.mounted) {
      _state.setState(() {
        _state._progress = progress;
      });
    }
  }

  @override
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
