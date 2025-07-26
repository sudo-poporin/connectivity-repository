/// Interfaz que define el contrato que debe cumplir el repositorio
/// de conectividad.
abstract interface class IConnectivityRepository {
  /// Variable que indica si el dispositivo tiene conexión a internet.
  bool get isOnline;

  /// Stream que indica si el dispositivo tiene conexión a internet.
  Stream<bool> get isOnlineStream;

  /// Obtiene el estado de conexión.
  Future<bool> hasNetworkConnection();
}
