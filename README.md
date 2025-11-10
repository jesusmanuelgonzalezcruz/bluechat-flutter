README.md

BlueChat - Chat P2P con Flutter y Bluetooth

Descripción
BlueChat es una aplicación de mensajería peer-to-peer (P2P) que permite la comunicación entre
dos dispositivos Android mediante Bluetooth y Wi-Fi Direct, sin necesidad de conexión a
Internet.

Objetivo
Permitir el intercambio de mensajes de texto en tiempo real entre dos dispositivos móviles
utilizando Google Nearby Connections API.

Tecnologías Utilizadas
- **Framework:** Flutter
- **Lenguaje:** Dart
- **IDE:** Android Studio / VS Code
- **API:** Google Nearby Connections
- **Conectividad:** Bluetooth + Wi-Fi Direct (P2P)

Requisitos Previos
- Flutter SDK (>=2.17.0)
- Android SDK (API 21+)
- Dispositivo Android físico (no funciona en emulador)
- Google Play Services actualizados

Dependencias

yaml
dependencies:
flutter:
sdk: flutter
nearby_connections: ^3.3.1
permission_handler: ^11.3.1
```

Instalación
### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/bluechat.git
cd bluechat
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Conectar dispositivo Android
```bash
flutter devices
```

### 4. Ejecutar la aplicación

```bash
flutter run
```

### 5. Generar APK (Release)
```bash
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

Cómo Usar

### Paso 1: Permisos
Al abrir la app por primera vez, acepta **todos los permisos**:
- Bluetooth
- Ubicación
- Dispositivos cercanos

### Paso 2: Conexión entre dispositivos

**Teléfono A:**
1. Presiona el botón azul 📡 **"ANUNCIAR"**
2. Espera a que el otro dispositivo se conecte

**Teléfono B:**
1. Presiona el botón verde 🔍 **"BUSCAR"**

2. Verás aparecer "Usuario_XX" en la lista
3. Presiona **"Conectar"**

**Teléfono A:**
4. Aparecerá un diálogo de solicitud de conexión
5. Presiona **"ACEPTAR"**

### Paso 3: Chatear
Una vez conectados, ambos dispositivos pueden enviar y recibir mensajes en tiempo real.

## 🔧 Solución de Problemas

### No encuentra dispositivos
- Verifica que Bluetooth esté activado en ambos teléfonos
- Verifica que Ubicación/GPS esté activado
- Asegúrate de que ambos teléfonos tengan los permisos concedidos
- Mantén los dispositivos cerca (máximo 10-20 metros)

### Error de permisos
- Verifica que `AndroidManifest.xml` tenga todos los permisos necesarios
- Ve a Configuración → Aplicaciones → BlueChat → Permisos y activa todos

### La app se cierra al conectar
- Actualiza Google Play Services desde Play Store
- Verifica que la versión de Android sea 5.0 o superior

Estructura del Proyecto
```

bluechat/
├── android/
│ └── app/
│ └── src/
│ └── main/
│ └── AndroidManifest.xml
├── lib/
│ └── main.dart
├── pubspec.yaml
└── README.md
```

Equipo de Desarrollo
- **Desarrollador 1:** Jesus Manuel Gonzalez Cruz
- **Desarrollador 2:** Oscar Gael Castro Hernandez

Sprints Realizados
- **Sprint 1:** Configuración y UI estática
- **Sprint 2:** Integración de permisos y descubrimiento
- **Sprint 3:** Establecimiento de conexión
- **Sprint 4:** Envío y recepción de mensajes

Licencia
Este proyecto fue desarrollado como práctica académica.

Agradecimientos
- Google Nearby Connections API
- Comunidad de Flutter
- Asistencia de IA (Claude) para debugging y desarrollo
