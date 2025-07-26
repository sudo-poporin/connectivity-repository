import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_repository/src/i_connectivity_repository.dart';
import 'package:flutter/foundation.dart';

/// Repositorio de conectividad para manejar la conexión a internet
class ConnectivityRepository implements IConnectivityRepository {
  /// Singleton de la clase [Connectivity]
  @visibleForTesting
  late Connectivity connectivity;

  bool _isOnline = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivityStreamSubscription;

  final List<ConnectivityResult> _onlineStates = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi,
  ];

  /// Estado de conexión
  @override
  bool get isOnline => _isOnline;

  /// Stream de conexión que emite el estado de conexión
  /// Emite `true` si hay conexión a internet, `false` en caso contrario.
  @override
  Stream<bool> get isOnlineStream => connectivity.onConnectivityChanged.map(
    (result) => result.any(_onlineStates.contains),
  );

  /// Inicializa el repositorio de conectividad.
  /// Cancela cualquier suscripción previa al stream de conectividad.
  Future<void> init() async {
    connectivity = Connectivity();

    await _connectivityStreamSubscription?.cancel();

    _connectivityStreamSubscription = connectivity.onConnectivityChanged.listen(
      change,
    );
  }

  /// Obtiene el estado de conexión
  @override
  Future<bool> hasNetworkConnection() async {
    final result = await connectivity.checkConnectivity();
    change(result);

    return _isOnline;
  }

  /// Cambia el estado de conexión
  @visibleForTesting
  void change(List<ConnectivityResult> result) {
    _isOnline = result.any(_onlineStates.contains);
  }
}
