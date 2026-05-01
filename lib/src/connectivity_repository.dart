import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_repository/src/i_connectivity_repository.dart';
import 'package:flutter/foundation.dart';

/// Repositorio de conectividad para manejar la conexión a internet
class ConnectivityRepository implements IConnectivityRepository {
  /// Singleton de la clase [Connectivity]
  @visibleForTesting
  Connectivity connectivity = Connectivity();

  bool _isOnline = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivityStreamSubscription;

  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  static const List<ConnectivityResult> _onlineStates = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
    ConnectivityResult.ethernet,
    ConnectivityResult.vpn,
  ];

  /// Estado de conexión
  @override
  bool get isOnline => _isOnline;

  /// Stream de conexión que emite el estado de conexión.
  /// Emite el valor actual al suscribirse y luego cada cambio.
  /// `true` si hay conexión a internet, `false` en caso contrario.
  @override
  Stream<bool> get isOnlineStream async* {
    yield _isOnline;
    yield* _onlineController.stream;
  }

  /// Inicializa el repositorio de conectividad.
  /// Cancela cualquier suscripción previa al stream de conectividad.
  Future<void> init() async {
    await _connectivityStreamSubscription?.cancel();

    _change(await connectivity.checkConnectivity());

    _connectivityStreamSubscription = connectivity.onConnectivityChanged.listen(
      _change,
      onError: (Object _, StackTrace _) {},
    );
  }

  /// Refresca el estado consultando la plataforma y devuelve el resultado.
  @override
  Future<bool> hasNetworkConnection() async {
    final result = await connectivity.checkConnectivity();
    _change(result);

    return _isOnline;
  }

  /// Libera recursos: cancela la suscripción y cierra el stream interno.
  @override
  Future<void> dispose() async {
    await _connectivityStreamSubscription?.cancel();
    _connectivityStreamSubscription = null;
    await _onlineController.close();
  }

  void _change(List<ConnectivityResult> result) {
    final newValue = result.any(_onlineStates.contains);
    if (newValue == _isOnline) return;
    _isOnline = newValue;
    _onlineController.add(_isOnline);
  }

  /// Hook de test para forzar un cambio de estado.
  @visibleForTesting
  void debugChange(List<ConnectivityResult> result) => _change(result);
}
