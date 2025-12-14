import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WearConnectionScreen extends StatefulWidget {
  const WearConnectionScreen({super.key});

  @override
  State<WearConnectionScreen> createState() => _WearConnectionScreenState();
}

class _WearConnectionScreenState extends State<WearConnectionScreen> {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final Map<String, ConnectionInfo> _connections = {};
  final Map<int, String> _incomingFiles = {}; // Payload ID => temp path

  @override
  void initState() {
    super.initState();
    startAdvertising();
  }

  void startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        "watch_theme_android",
        strategy,
        onConnectionInitiated: (id, info) {
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endpointId, payload) async {
              if (payload.type == PayloadType.FILE) {
                _incomingFiles[payload.id] = payload.filePath!;
              }
            },
            onPayloadTransferUpdate: (endpointId, update) async {
              if (update.status == PayloadStatus.SUCCESS) {
                final tempPath = _incomingFiles[update.id];
                if (tempPath != null) {
                  _incomingFiles.remove(update.id);
                  await _handleReceivedFile(tempPath);
                }
              } else if (update.status == PayloadStatus.FAILURE) {
                Fluttertoast.showToast(msg: "Error en transferencia de tema.");
              }
            },
          );
          setState(() => _connections[id] = info);
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Conectado a ${_connections[id]?.endpointName ?? ''}")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Falló conexión con ${_connections[id]?.endpointName ?? ''}")),
            );
          }
        },
        onDisconnected: (id) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Desconectado de ${_connections[id]?.endpointName ?? ''}")),
          );
          setState(() => _connections.remove(id));
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar conexión: $e")),
      );
    }
  }

  Future<void> _handleReceivedFile(String tempPath) async {
    final fileName = tempPath.split('/').last;
    final dir = await getApplicationDocumentsDirectory();
    final savedPath = '${dir.path}/$fileName';

    final tempFile = File(tempPath);
    final savedFile = File(savedPath);

    if (!await tempFile.exists()) {
      Fluttertoast.showToast(msg: "Archivo temporal no encontrado.");
      return;
    }

    final shouldApply = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tema recibido"),
        content: const Text("¿Deseas aplicar este tema al reloj?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Aplicar"),
          ),
        ],
      ),
    );

    if (shouldApply == true) {
      try {
        await tempFile.copy(savedFile.path);
        await _applyTheme(savedFile);
        Fluttertoast.showToast(msg: "Tema aplicado exitosamente.");
      } catch (e) {
        Fluttertoast.showToast(msg: "Error al aplicar el tema: $e");
      }
    } else {
      await tempFile.delete();
    }
  }

  Future<void> _applyTheme(File file) async {
    print("Aplicando tema desde: ${file.path}");
  }

  @override
  void dispose() {
    Nearby().stopAdvertising();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wear OS - Esperando conexión"),
      ),
      body: _connections.isEmpty
          ? const Center(child: Text("Esperando conexiones..."))
          : ListView(
              children: _connections.entries.map((entry) {
                return ListTile(
                  title: Text(entry.value.endpointName),
                  subtitle: Text("ID: ${entry.key}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Nearby().disconnectFromEndpoint(entry.key);
                      setState(() => _connections.remove(entry.key));
                    },
                  ),
                );
              }).toList(),
            ),
    );
  }
}
