import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_repository/connectivity_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('ConnectivityRepository Tests', () {
    late ConnectivityRepository connectivityRepository;

    setUp(() {
      WidgetsFlutterBinding.ensureInitialized();
      connectivityRepository = ConnectivityRepository()
        ..connectivity = MockConnectivity();
    });

    group('.init()', () {
      test('inicializa el stream de conectividad', () async {
        expect(connectivityRepository.init(), completes);
      });
    });

    group('.change(List<ConnectivityResult> result)', () {
      test(' isOnline es true cuando hay conexión a internet ', () {
        connectivityRepository.change([
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
        ]);

        expect(connectivityRepository.isOnline, isTrue);
      });

      test('isOnline es false cuando no hay conexión a internet', () {
        connectivityRepository.change([ConnectivityResult.none]);
        expect(connectivityRepository.isOnline, isFalse);
      });
    });

    group('.hasNetworkConnection()', () {
      test('devuelve true cuando hay conexión a internet', () async {
        when(
          () => connectivityRepository.isOnlineStream,
        ).thenAnswer((_) => Stream.value(true));
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        final result = await connectivityRepository.hasNetworkConnection();

        expect(result, isTrue);
        expect(connectivityRepository.isOnline, isTrue);
      });

      test('devuelve false cuando no hay conexión a internet', () async {
        when(
          () => connectivityRepository.isOnlineStream,
        ).thenAnswer((_) => Stream.value(false));
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);

        final result = await connectivityRepository.hasNetworkConnection();

        expect(result, isFalse);
        expect(connectivityRepository.isOnline, isFalse);
      });
    });
  });
}
