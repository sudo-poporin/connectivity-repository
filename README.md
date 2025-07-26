# Connectivity Repository 🛜

Paquete para controlar la conectividad de red.

## Instalación 💻

Instalar a través del archivo `pubspec.yaml` añadiendo la dependencia:

```yaml
dependencies:
  connectivity_repository:
    git:
      url: https://github.com/sudo-poporin/connectivity-repository
      ref: main
```

---

## Uso 📖

Este paquete proporciona una interfaz para manejar la conectividad de red en aplicaciones Flutter. Permite verificar el estado de la conexión a internet y escuchar cambios en la conectividad.

### Ejemplo de uso

```dart
import 'package:connectivity_repository/connectivity_repository.dart';

Future<void> main() async {
    final connectivityRepository = ConnectivityRepository();

    // Inicializar el repositorio de conectividad
    await connectivityRepository.init();

    // Verificar el estado de la conexión
    final hasConnection = await connectivityRepository.hasNetworkConnection();
    log('Estado de la conexión: $hasConnection');

    // Escuchar cambios en la conectividad
    connectivityRepository.isOnlineStream.listen((isOnline) {
        log('Conectividad cambiada: $isOnline');
    });
}
```
