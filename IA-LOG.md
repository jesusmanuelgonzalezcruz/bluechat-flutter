IA-LOG.md

Log de Interacción con IA - BlueChat

Este documento registra las interacciones significativas con la IA durante el desarrollo del
proyecto.

Prompt 1: Entendimiento del Proyecto.
Necesito crear una aplicación de chat en Flutter que funcione entre dos teléfonos
Android usando Bluetooth, sin necesidad de internet. ¿Qué librería me recomiendas
y cómo funciona?

La Respuesta (resumida):
La IA recomendó usar **Google Nearby Connections API** en lugar de Bluetooth clásico,
explicando que:
- Nearby Connections usa tanto Bluetooth como Wi-Fi Direct
- Es más confiable y rápido que Bluetooth SPP
- El paquete recomendado es `nearby_connections`
- Funciona con un modelo publisher-subscriber (anunciarse/buscar)

El Aprendizaje:
Por qué preguntamos: No estábamos seguros si usar Bluetooth clásico o una API más
moderna.

Qué aprendimos: Nearby Connections es superior porque:
- No requiere emparejamiento previo
- Funciona en segundo plano

- Maneja la conexión automáticamente
- Soporta múltiples estrategias (P2P_CLUSTER, P2P_STAR, P2P_POINT_TO_POINT)

Cómo lo usamos: Decidimos usar `nearby_connections: ^3.3.1` en lugar de
`flutter_bluetooth_serial`, lo que simplificó enormemente el desarrollo.

Prompt 2: Error de Compilación - Namespace
Tengo este error al compilar:
"Namespace not specified. Specify a namespace in the module's build file"

¿Qué debo hacer?

La Respuesta (resumida):
La IA explicó que desde Android Gradle Plugin 7.0+, todos los módulos necesitan
un `namespace` declarado. Proporcionó la solución:
```gradle
android {
namespace 'com.pkmnapps.nearby_connections'
// resto de la configuración
}

El Aprendizaje:

Por qué preguntamos: La app no compilaba y el error no era claro.

Qué aprendimos:
- Los plugins de Flutter a veces están desactualizados
- El namespace es obligatorio en versiones modernas de Android
- Podemos modificar el código de plugins en la caché de Pub

Cómo lo usamos: Editamos manualmente el archivo `build.gradle` del plugin
`nearby_connections` en la caché de Pub, agregando el namespace faltante.

Prompt 3: Permisos en Android 12+.
Mi app da error: "MISSING_PERMISSION_NEARBY_WIFI_DEVICES"
¿Qué permiso me falta y cómo lo agrego?

La Respuesta (resumida):
La IA explicó que Android 13+ (API 33) requiere un nuevo permiso específico:
xml
<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES"
android:usesPermissionFlags="neverForLocation" />

También mostró cómo solicitarlo en código:
dart
Permission.nearbyWifiDevices

El Aprendizaje:
Por qué preguntamos: La app funcionaba en permisos antiguos pero fallaba en dispositivos
nuevos.

Qué aprendimos:
- Android 12 introdujo permisos granulares de Bluetooth
- Android 13 agregó el permiso NEARBY_WIFI_DEVICES
- Los permisos deben declararse en AndroidManifest.xml Y solicitarse en runtime

Cómo lo usamos: Actualizamos el AndroidManifest.xml y el código Dart para
incluir todos los permisos necesarios según la versión de Android.

Prompt 4: Error RangeError en substring
Tengo este error:
"RangeError (end): Invalid value: Not in inclusive range 0..4: 8"

Aparece cuando intento mostrar la lista de dispositivos encontrados.

La Respuesta (resumida):
La IA identificó que el problema estaba en esta línea:
dart
subtitle: Text("ID: ${device.id.substring(0, 8)}..."),

El error ocurre cuando `device.id` tiene menos de 8 caracteres. Proporcionó la solución:
dart
subtitle: Text("ID: ${device.id.length > 8 ? device.id.substring(0, 8) : device.id}..."),

El Aprendizaje:
Por qué preguntamos: La app crasheaba al encontrar un dispositivo.

Qué aprendimos:
- Siempre validar la longitud antes de usar substring()
- Los IDs de dispositivos pueden tener longitudes variables
- Es mejor usar operadores ternarios para validaciones inline

Cómo lo usamos:
Implementamos la validación de longitud y también simplificamos
mostrando el ID completo sin substring.

Prompt 5: Cómo funciona el flujo de conexión
Explícame paso a paso cómo funciona el proceso de conexión entre dos dispositivos
usando Nearby Connections. ¿Por qué no veo dispositivos cuando busco?

La Respuesta (resumida):
La IA explicó que Nearby Connections funciona con un modelo de "anunciarse/buscar":
1. **Teléfono A** debe ANUNCIARSE (startAdvertising)
2. **Teléfono B** debe BUSCAR (startDiscovery)

3. Solo entonces B verá a A en la lista
4. No es como Bluetooth tradicional que muestra todos los dispositivos emparejados

También explicó los callbacks:
- `onEndpointFound` - Cuando se encuentra un dispositivo
- `onConnectionInitiated` - Cuando alguien solicita conexión
- `onConnectionResult` - Cuando la conexión se establece o falla
- `onPayloadReceived` - Cuando llega un mensaje

El Aprendizaje:
**Por qué preguntamos:** No entendíamos por qué la lista de dispositivos estaba vacía.

Qué aprendimos:
- Nearby Connections NO muestra dispositivos Bluetooth emparejados
- Requiere que uno se anuncie y el otro busque activamente
- Solo muestra dispositivos que estén usando la misma app
- Los callbacks son el corazón de la arquitectura

Cómo lo usamos
- Ajustamos la UI para explicar claramente el proceso al usuario
- Implementamos todos los callbacks necesarios
- Agregamos validaciones de permisos antes de permitir búsqueda/anuncio

Reflexión General sobre el Uso de IA

¿Cómo cambió nuestro proceso el usar IA?

1. **Velocidad de debugging:** Los errores que hubieran tomado horas investigar
se resolvieron en minutos.

2. **Comprensión profunda:** En lugar de solo copiar código, la IA explicó
*por qué* cada solución funcionaba.

3. **Exploración de alternativas:** La IA nos mostró múltiples enfoques
(Bluetooth clásico vs Nearby Connections).

4. **Aprendizaje continuo:** Cada interacción nos enseñó algo nuevo sobre
Android, Flutter o las APIs.

Desafíos:

- A veces la IA sugería código desactualizado
- Tuvimos que validar las respuestas con documentación oficial
- Algunos errores requerían múltiples iteraciones para resolverse

Conclusión:

La IA fue como un mentor experimentado disponible 24/7. No hizo el trabajo por
nosotros, pero nos guió en el proceso de construcción y aprendizaje. El resultado
es que no solo tenemos una app funcional, sino que entendemos profundamente
cómo funciona cada parte.
