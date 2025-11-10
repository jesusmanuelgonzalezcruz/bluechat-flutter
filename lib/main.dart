import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlueChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: ChatHomePage(),
    );
  }
}

class ChatHomePage extends StatefulWidget {
  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final Strategy strategy = Strategy.P2P_CLUSTER;
  final String serviceId = "com.example.bluechat1";
  
  String myDeviceName = "Usuario_${DateTime.now().millisecond}";
  List<Device> discoveredDevices = [];
  String? connectedDeviceId;
  String? connectedDeviceName;
  List<ChatMessage> messages = [];
  
  TextEditingController messageController = TextEditingController();
  bool isAdvertising = false;
  bool isDiscovering = false;
  bool permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      checkAndRequestPermissions();
    });
  }

  // ========== PERMISOS ==========
  Future<void> checkAndRequestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
        Permission.location,
        Permission.locationWhenInUse,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      setState(() {
        permissionsGranted = allGranted;
      });

      if (allGranted) {
        showSnackBar("✅ Permisos concedidos. ¡Listo!", Colors.green);
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("⚠️ Permisos requeridos"),
            content: Text(
              "BlueChat necesita:\n"
              "• Bluetooth - Para conectar dispositivos\n"
              "• Dispositivos cercanos - Para buscar\n"
              "• Ubicación - Requerido por Android\n\n"
              "Por favor, acepta todos los permisos.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text("Ir a Configuración"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  checkAndRequestPermissions();
                },
                child: Text("Reintentar"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      showSnackBar("❌ Error al solicitar permisos: $e", Colors.red);
    }
  }

  // ========== PUBLICIDAD ==========
  Future<void> startAdvertising() async {
    if (!permissionsGranted) {
      showSnackBar("⚠️ Acepta los permisos primero", Colors.orange);
      checkAndRequestPermissions();
      return;
    }

    if (isAdvertising) {
      await stopAdvertising();
      return;
    }

    try {
      bool result = await Nearby().startAdvertising(
        myDeviceName,
        strategy,
        onConnectionInitiated: onConnectionInitiated,
        onConnectionResult: onConnectionResult,
        onDisconnected: onDisconnected,
        serviceId: serviceId,
      );

      if (result) {
        setState(() => isAdvertising = true);
        showSnackBar("📡 Anunciándote como: $myDeviceName", Colors.blue);
      } else {
        showSnackBar("❌ No se pudo iniciar publicidad", Colors.red);
      }
    } catch (e) {
      showSnackBar("❌ Error: $e", Colors.red);
    }
  }

  Future<void> stopAdvertising() async {
    await Nearby().stopAdvertising();
    setState(() => isAdvertising = false);
    showSnackBar("🔴 Dejaste de anunciarte", Colors.grey);
  }

  // ========== DESCUBRIMIENTO ==========
  Future<void> startDiscovery() async {
    if (!permissionsGranted) {
      showSnackBar("⚠️ Acepta los permisos primero", Colors.orange);
      checkAndRequestPermissions();
      return;
    }

    if (isDiscovering) {
      await stopDiscovery();
      return;
    }

    try {
      bool result = await Nearby().startDiscovery(
        myDeviceName,
        strategy,
        onEndpointFound: onEndpointFound,
        onEndpointLost: onEndpointLost,
        serviceId: serviceId,
      );

      if (result) {
        setState(() {
          isDiscovering = true;
          discoveredDevices.clear();
        });
        showSnackBar("🔍 Buscando dispositivos...", Colors.blue);
      } else {
        showSnackBar("❌ No se pudo iniciar búsqueda", Colors.red);
      }
    } catch (e) {
      showSnackBar("❌ Error: $e", Colors.red);
    }
  }

  Future<void> stopDiscovery() async {
    await Nearby().stopDiscovery();
    setState(() => isDiscovering = false);
    showSnackBar("🔴 Dejaste de buscar", Colors.grey);
  }

  // ========== CALLBACKS ==========
  void onConnectionInitiated(String id, ConnectionInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("🤝 Solicitud de conexión"),
        content: Text("${info.endpointName} quiere conectarse"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Nearby().rejectConnection(id);
            },
            child: Text("Rechazar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Nearby().acceptConnection(
                id,
                onPayLoadRecieved: onPayloadReceived,
              );
            },
            child: Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void onConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      setState(() {
        connectedDeviceId = id;
        Device? device = discoveredDevices.firstWhere(
          (d) => d.id == id,
          orElse: () => Device(id: id, name: "Desconocido"),
        );
        connectedDeviceName = device.name;
      });
      showSnackBar("✅ Conectado con: $connectedDeviceName", Colors.green);
      stopDiscovery();
      stopAdvertising();
    } else if (status == Status.REJECTED) {
      showSnackBar("❌ Conexión rechazada", Colors.red);
    } else {
      showSnackBar("⚠️ Error en la conexión", Colors.orange);
    }
  }

  void onDisconnected(String id) {
    setState(() {
      connectedDeviceId = null;
      connectedDeviceName = null;
    });
    showSnackBar("📴 Desconectado", Colors.grey);
  }

  void onEndpointFound(String id, String name, String serviceId) {
    setState(() {
      if (!discoveredDevices.any((d) => d.id == id)) {
        discoveredDevices.add(Device(id: id, name: name));
        showSnackBar("🎯 Encontrado: $name", Colors.green);
      }
    });
  }

  void onEndpointLost(String? id) {
    setState(() {
      discoveredDevices.removeWhere((d) => d.id == id);
    });
  }

  // ========== MENSAJES ==========
  void onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES) {
      String message = String.fromCharCodes(payload.bytes!);
      setState(() {
        messages.add(ChatMessage(
          text: message,
          isMe: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<void> sendMessage() async {
    if (connectedDeviceId == null) {
      showSnackBar("⚠️ No hay conexión", Colors.orange);
      return;
    }

    String text = messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await Nearby().sendBytesPayload(
        connectedDeviceId!,
        Uint8List.fromList(text.codeUnits),
      );

      setState(() {
        messages.add(ChatMessage(
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ));
      });

      messageController.clear();
    } catch (e) {
      showSnackBar("❌ Error al enviar: $e", Colors.red);
    }
  }

  Future<void> connectToDevice(Device device) async {
    try {
      await Nearby().requestConnection(
        myDeviceName,
        device.id,
        onConnectionInitiated: onConnectionInitiated,
        onConnectionResult: onConnectionResult,
        onDisconnected: onDisconnected,
      );
      showSnackBar("📞 Conectando con ${device.name}...", Colors.blue);
    } catch (e) {
      showSnackBar("❌ Error al conectar: $e", Colors.red);
    }
  }

  void showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BlueChat'),
        centerTitle: true,
        actions: [
          if (connectedDeviceId != null)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Nearby().disconnectFromEndpoint(connectedDeviceId!);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionStatus(),
          Expanded(
            child: connectedDeviceId == null
                ? _buildDeviceList()
                : _buildChatView(),
          ),
          if (connectedDeviceId != null) _buildMessageInput(),
        ],
      ),
      floatingActionButton: connectedDeviceId == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: "advertise",
                  onPressed: startAdvertising,
                  icon: Icon(isAdvertising ? Icons.stop : Icons.campaign),
                  label: Text(isAdvertising ? 'Detener' : 'Anunciar'),
                  backgroundColor: isAdvertising ? Colors.red : Colors.blue,
                ),
                SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: "discover",
                  onPressed: startDiscovery,
                  icon: Icon(isDiscovering ? Icons.stop : Icons.search),
                  label: Text(isDiscovering ? 'Detener' : 'Buscar'),
                  backgroundColor: isDiscovering ? Colors.red : Colors.green,
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      color: connectedDeviceId != null ? Colors.green[100] : Colors.grey[200],
      child: Column(
        children: [
          Text(
            connectedDeviceId != null
                ? "✅ Conectado con: $connectedDeviceName"
                : "⚪ Sin conexión",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Mi nombre: $myDeviceName",
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
          if (!permissionsGranted)
            TextButton.icon(
              onPressed: checkAndRequestPermissions,
              icon: Icon(Icons.warning, color: Colors.orange),
              label: Text("Conceder permisos"),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    if (discoveredDevices.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bluetooth_searching, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                isDiscovering
                    ? "Buscando dispositivos..."
                    : "No hay dispositivos",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                "Instrucciones:\n\n"
                "1. En ESTE teléfono presiona 📡 ANUNCIAR\n"
                "2. En OTRO teléfono presiona 🔍 BUSCAR\n"
                "3. Deberías aparecer en la lista",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: discoveredDevices.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        Device device = discoveredDevices[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(Icons.person),
              backgroundColor: Colors.blue,
            ),
            title: Text(device.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Toca para conectar"), // ← CORREGIDO: sin substring
            trailing: ElevatedButton(
              onPressed: () => connectToDevice(device),
              child: Text("Conectar"),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatView() {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          "Inicia la conversación 💬",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        ChatMessage message = messages[messages.length - 1 - index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.text, style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Escribe un mensaje...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: sendMessage,
            child: Icon(Icons.send),
            mini: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    Nearby().stopAllEndpoints();
    messageController.dispose();
    super.dispose();
  }
}

class Device {
  final String id;
  final String name;

  Device({required this.id, required this.name});
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
  });
}