import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class WearConnectionScreen extends StatefulWidget {
  const WearConnectionScreen({super.key});

  @override
  State<WearConnectionScreen> createState() => _WearConnectionScreenState();
}

class _WearConnectionScreenState extends State<WearConnectionScreen> {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final Map<String, ConnectionInfo> _connections = {};

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
          print("Conexión iniciada desde $id (${info.endpointName})");
          Nearby().acceptConnection(
            id,
            onPayLoadRecieved: (endpointId, payload) {
              if (payload.type == PayloadType.BYTES) {
                final data = String.fromCharCodes(payload.bytes!);
                print("Payload recibido: $data");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Datos recibidos: $data")),
                );
                // Aquí puedes parsear y aplicar el tema en el reloj
              }
              // Puedes manejar archivos si envías .hwt con PayloadType.FILE
            },
            onPayloadTransferUpdate: (eid, update) {
              // Opcional: manejar progreso si quieres
            },
          );
          setState(() {
            _connections[id] = info;
          });
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            print("Conectado con $id");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Conectado a ${_connections[id]?.endpointName ?? ''}")),
            );
          } else {
            print("Fallo conexión $id: $status");
          }
        },
        onDisconnected: (id) {
          print("Desconectado de $id");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Desconectado de ${_connections[id]?.endpointName ?? ''}")),
          );
          setState(() {
            _connections.remove(id);
          });
        },
      );
      print("Advertising iniciado");
    } catch (e) {
      print("Error iniciando advertising: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error iniciando advertising: $e")),
      );
    }
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
        title: const Text("Wear OS - Esperando conexiones"),
      ),
      body: _connections.isEmpty
          ? const Center(child: Text("Esperando conexiones..."))
          : ListView(
              children: _connections.entries
                  .map(
                    (e) => ListTile(
                      title: Text(e.value.endpointName),
                      subtitle: Text("ID: ${e.key}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Nearby().disconnectFromEndpoint(e.key);
                          setState(() {
                            _connections.remove(e.key);
                          });
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
