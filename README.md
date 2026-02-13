# Connectivity Repository 🛜

[![style: very good analysis][vga_badge]][vga_link]
[![Flutter][flutter_badge]][flutter_link]

Un repositorio de Flutter para manejar la conectividad de red de forma sencilla y testeable.

## Características ✨

- 🔌 Verificación del estado de conexión a internet
- 📡 Stream reactivo para escuchar cambios de conectividad
- 🧪 Diseñado para ser fácilmente testeable con mocks
- 🎯 Interfaz abstracta para inyección de dependencias
- 📱 Soporta WiFi y conexión móvil como estados "online"

## Requisitos 📋

- Dart SDK: `>=3.8.0 <4.0.0`
- Flutter: `>=1.17.0`

## Instalación 💻

Añade la dependencia en tu archivo `pubspec.yaml`:

```yaml
dependencies:
  connectivity_repository:
    git:
      url: https://github.com/sudo-poporin/connectivity-repository
      ref: main
```

### Configuración de plataformas 🔧

Este paquete utiliza [`connectivity_plus`][connectivity_plus_link] internamente.
Consulta su documentación para la configuración específica de cada plataforma:

<details>
<summary>Android</summary>

Añade el permiso en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

</details>

<details>
<summary>iOS / macOS</summary>

No requiere configuración adicional.

</details>

<details>
<summary>Web</summary>

La detección de conectividad en web se basa en el evento `online`/`offline` del navegador.

</details>

---

## Uso 📖

### Ejemplo básico

```dart
import 'package:connectivity_repository/connectivity_repository.dart';

Future<void> main() async {
  final connectivityRepository = ConnectivityRepository();

  // Inicializar el repositorio de conectividad
  await connectivityRepository.init();

  // Verificar el estado de la conexión
  final hasConnection = await connectivityRepository.hasNetworkConnection();
  print('¿Tiene conexión?: $hasConnection');

  // Acceder al estado actual de forma síncrona
  print('¿Está online?: ${connectivityRepository.isOnline}');

  // Escuchar cambios en la conectividad
  connectivityRepository.isOnlineStream.listen((isOnline) {
    print('Conectividad cambiada: $isOnline');
  });
}
```

### Uso con inyección de dependencias

El paquete expone la interfaz `IConnectivityRepository` para facilitar
la inyección de dependencias y el testing:

```dart
import 'package:connectivity_repository/connectivity_repository.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<IConnectivityRepository>(
    () => ConnectivityRepository()..init(),
  );
}

// En tu código
class MyService {
  MyService(this._connectivityRepository);

  final IConnectivityRepository _connectivityRepository;

  Future<void> fetchData() async {
    if (await _connectivityRepository.hasNetworkConnection()) {
      // Realizar petición de red
    } else {
      // Manejar estado sin conexión
    }
  }
}
```

### Uso con Cubit (flutter_bloc)

```dart
import 'dart:async';

import 'package:connectivity_repository/connectivity_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivityRepository) : super(false) {
    _init();
  }

  final IConnectivityRepository _connectivityRepository;
  StreamSubscription<bool>? _subscription;

  Future<void> _init() async {
    _subscription = _connectivityRepository.isOnlineStream.listen(emit);
  }

  Future<void> checkConnection() async {
    final isOnline = await _connectivityRepository.hasNetworkConnection();
    emit(isOnline);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

---

## API 📚

### IConnectivityRepository

Interfaz que define el contrato del repositorio de conectividad:

| Miembro | Tipo | Descripción |
|---------|------|-------------|
| `isOnline` | `bool` | Estado actual de conexión (síncrono) |
| `isOnlineStream` | `Stream<bool>` | Stream que emite cambios de conectividad |
| `hasNetworkConnection()` | `Future<bool>` | Verifica y retorna el estado de conexión |

### ConnectivityRepository

Implementación concreta de `IConnectivityRepository`.

| Método | Descripción |
|--------|-------------|
| `init()` | Inicializa el repositorio y comienza a escuchar cambios |

### Estados de conexión reconocidos

El repositorio considera como "online" únicamente:

- `ConnectivityResult.wifi` - Conexión WiFi
- `ConnectivityResult.mobile` - Datos móviles

Otros estados como `ethernet`, `vpn`, `bluetooth` se consideran como "offline".
