import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watchtheme/screens/AndroidScreens/apply_theme_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final Map<String, EndpointInfo> _endpoints = {};
  bool _isDiscovering = false;

  @override
  void initState() {
    super.initState();
    startDiscovery();
  }

  void startDiscovery() async {
    setState(() => _isDiscovering = true);

    // Pedir permiso de ubicación
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        setState(() => _isDiscovering = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permiso de ubicación es necesario")),
        );
        return;
      }
    }

    // Iniciar descubrimiento
    try {
      await Nearby().startDiscovery(
        "watch_theme_android",
        strategy,
        onEndpointFound: (id, name, serviceId) {
          setState(() {
            _endpoints[id] = EndpointInfo(name, serviceId);
          });
        },
        onEndpointLost: (id) {
          setState(() => _endpoints.remove(id));
        },
      );
    } catch (e) {
      setState(() => _isDiscovering = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al iniciar discovery: $e")));
    }
  }

  void connectTo(String endpointId) {
    Nearby().requestConnection(
      "watch_theme_android",
      endpointId,
      onConnectionInitiated: (id, info) {
        Nearby().acceptConnection(
          id,
          onPayLoadRecieved: (eid, payload) {
            // Aquí puedes manejar payload recibido (si es necesario)
          },
          onPayloadTransferUpdate: (eid, update) {
            // Puedes mostrar progreso si quieres
          },
        );
      },
      onConnectionResult: (id, status) {
        if (status == Status.CONNECTED) {
          ThemeApplier.connectedWatchEndpoint = id; // << IMPORTANTE
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Conectado a: ${_endpoints[id]?.endpointName ?? ''}",
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error de conexión: $status")));
        }
      },
      onDisconnected: (id) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Desconectado.")));
      },
    );
  }

  @override
  void dispose() {
    Nearby().stopDiscovery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Conectar al Reloj")),
      body:
          _isDiscovering
              ? _endpoints.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: _endpoints.length,
                    itemBuilder: (context, index) {
                      String id = _endpoints.keys.elementAt(index);
                      EndpointInfo info = _endpoints[id]!;
                      return ListTile(
                        leading: const Icon(Icons.watch),
                        title: Text(info.endpointName),
                        subtitle: Text("ID: $id"),
                        trailing: ElevatedButton(
                          onPressed: () => connectTo(id),
                          child: const Text("Conectar"),
                        ),
                      );
                    },
                  )
              : const Center(
                child: Text("Esperando para descubrir dispositivos..."),
              ),
    );
  }
}

class EndpointInfo {
  final String endpointName;
  final String serviceId;

  EndpointInfo(this.endpointName, this.serviceId);
}
