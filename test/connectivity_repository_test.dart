import 'dart:async';

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
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        when(
          () => connectivityRepository.connectivity.onConnectivityChanged,
        ).thenAnswer((_) => const Stream.empty());

        expect(connectivityRepository.init(), completes);
      });

      test(
        'isOnline true tras init si checkConnectivity inicial es wifi',
        () async {
          when(
            () => connectivityRepository.connectivity.checkConnectivity(),
          ).thenAnswer((_) async => [ConnectivityResult.wifi]);
          when(
            () => connectivityRepository.connectivity.onConnectivityChanged,
          ).thenAnswer((_) => const Stream.empty());

          await connectivityRepository.init();

          expect(connectivityRepository.isOnline, isTrue);
        },
      );
    });

    group('.isOnlineStream', () {
      test('emite valor inicial al suscribirse tras init', () async {
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);
        when(
          () => connectivityRepository.connectivity.onConnectivityChanged,
        ).thenAnswer((_) => const Stream.empty());

        await connectivityRepository.init();

        expect(connectivityRepository.isOnlineStream.first, completion(isTrue));
      });

      test('emite cuando debugChange() actualiza estado', () async {
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        when(
          () => connectivityRepository.connectivity.onConnectivityChanged,
        ).thenAnswer((_) => const Stream.empty());

        await connectivityRepository.init();

        final values = <bool>[];
        final sub = connectivityRepository.isOnlineStream.listen(values.add);
        await Future<void>.delayed(Duration.zero);

        connectivityRepository.debugChange([ConnectivityResult.wifi]);
        await Future<void>.delayed(Duration.zero);

        await sub.cancel();
        expect(values, [false, true]);
      });
    });

    group('init() reentrante', () {
      test('llamar dos veces no duplica eventos del upstream', () async {
        final upstream = StreamController<List<ConnectivityResult>>.broadcast();
        addTearDown(upstream.close);
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        when(
          () => connectivityRepository.connectivity.onConnectivityChanged,
        ).thenAnswer((_) => upstream.stream);

        await connectivityRepository.init();
        await connectivityRepository.init();

        final values = <bool>[];
        final sub = connectivityRepository.isOnlineStream.listen(values.add);
        await Future<void>.delayed(Duration.zero);

        upstream.add([ConnectivityResult.wifi]);
        await Future<void>.delayed(Duration.zero);

        await sub.cancel();
        expect(values, [false, true]);
      });
    });

    group('manejo de errores upstream', () {
      test('error de upstream no rompe isOnlineStream', () async {
        final upstream = StreamController<List<ConnectivityResult>>.broadcast();
        addTearDown(upstream.close);
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        when(
          () => connectivityRepository.connectivity.onConnectivityChanged,
        ).thenAnswer((_) => upstream.stream);

        await connectivityRepository.init();

        final values = <bool>[];
        final errors = <Object>[];
        final sub = connectivityRepository.isOnlineStream.listen(
          values.add,
          onError: errors.add,
        );
        await Future<void>.delayed(Duration.zero);

        upstream.addError(Exception('platform error'));
        await Future<void>.delayed(Duration.zero);

        upstream.add([ConnectivityResult.wifi]);
        await Future<void>.delayed(Duration.zero);

        await sub.cancel();
        expect(errors, isEmpty);
        expect(values, [false, true]);
      });
    });

    group('.dispose()', () {
      test('cierra stream y cancela suscripción', () async {
        final controller = StreamController<List<ConnectivityResult>>();
        addTearDown(controller.close);
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.none]);
        when(
          () => connectivityRepository.connectivity.onConnectivityChanged,
        ).thenAnswer((_) => controller.stream);

        await connectivityRepository.init();
        await connectivityRepository.dispose();

        expect(
          connectivityRepository.isOnlineStream,
          emitsInOrder([false, emitsDone]),
        );
      });
    });

    group('.debugChange(List<ConnectivityResult> result)', () {
      test(' isOnline es true cuando hay conexión a internet ', () {
        connectivityRepository.debugChange([
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
        ]);

        expect(connectivityRepository.isOnline, isTrue);
      });

      test('isOnline es false cuando no hay conexión a internet', () {
        connectivityRepository.debugChange([ConnectivityResult.none]);
        expect(connectivityRepository.isOnline, isFalse);
      });

      test('isOnline es true con ethernet', () {
        connectivityRepository.debugChange([ConnectivityResult.ethernet]);
        expect(connectivityRepository.isOnline, isTrue);
      });

      test('isOnline es true con vpn', () {
        connectivityRepository.debugChange([ConnectivityResult.vpn]);
        expect(connectivityRepository.isOnline, isTrue);
      });

      test('isOnline es false con bluetooth', () {
        connectivityRepository.debugChange([ConnectivityResult.bluetooth]);
        expect(connectivityRepository.isOnline, isFalse);
      });
    });

    group('.hasNetworkConnection()', () {
      test('devuelve true cuando hay conexión a internet', () async {
        when(
          () => connectivityRepository.connectivity.checkConnectivity(),
        ).thenAnswer((_) async => [ConnectivityResult.wifi]);

        final result = await connectivityRepository.hasNetworkConnection();

        expect(result, isTrue);
        expect(connectivityRepository.isOnline, isTrue);
      });

      test('devuelve false cuando no hay conexión a internet', () async {
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
