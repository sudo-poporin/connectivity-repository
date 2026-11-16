# Changelog

Todos los cambios notables de este paquete se documentan en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/)
y este proyecto se adhiere a [Versionado Semántico](https://semver.org/lang/es/).

## [Unreleased]

## [2.0.0] - 2026-11-15

### Modificado

- **Cambio que rompe:** el SDK mínimo pasa de Dart 3.8 a Dart 3.14 y el de
  Flutter, de 1.17 a 3.50. La API pública no cambia, pero un consumidor con un
  SDK anterior deja de resolver el paquete. Para migrar, subir el consumidor a
  Flutter 3.50 o superior antes de apuntar el `ref:` a `v2.0.0`.
- `connectivity_plus` sube a `^7.3.2`.

### Eliminado

- `build_runner` sale de las dependencias de desarrollo: el paquete no genera
  código y los mocks de los tests son manuales con `mocktail`.

### Interno

- `very_good_analysis` sube a `^11.0.0`. Su única info nueva
  (`empty_container_bodies`) se corrige en el mock de los tests.
- `analysis_options.yaml` excluye `build/**`, que Flutter 3.50 agrega al
  resolver.
- El código pasa a `dart format` con el estilo de Dart 3.14.

## [1.0.10] - 2026-07-26

### Interno

- Bump de `connectivity_plus` de `^7.2.0` a `^7.3.1`.
- Bump de `build_runner` de `^2.15.0` a `^2.15.1`.

## [1.0.9] - 2026-06-28

### Interno

- Bump de `connectivity_plus` de `^7.1.1` a `^7.2.0`.
- Bump de `very_good_analysis` de `^10.2.0` a `^10.3.0`.
- Se agregan `docs/plans/` y `docs/specs/` a `.gitignore`.
