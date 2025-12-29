import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../nucleo/utilidades/formateador_duracion.dart';

/// Estados del reproductor de audio
enum EstadoReproductor {
  detenido,
  reproduciendo,
  pausado,
  cargando,
  error,
}

/// Provider para gestionar la reproducción de audio
class ProviderReproductorAudio extends ChangeNotifier {
  final AudioPlayer _reproductorAudio;

  // Estado
  EstadoReproductor _estado = EstadoReproductor.detenido;
  Duration _duracion = Duration.zero;
  Duration _posicion = Duration.zero;
  String? _rutaAudioActual;
  String? _mensajeError;

  ProviderReproductorAudio() : _reproductorAudio = AudioPlayer() {
    _configurarReproductor();
  }

  // Getters
  EstadoReproductor get estado => _estado;
  Duration get duracion => _duracion;
  Duration get posicion => _posicion;
  String? get rutaAudioActual => _rutaAudioActual;
  String? get mensajeError => _mensajeError;
  
  bool get estaReproduciendo => _estado == EstadoReproductor.reproduciendo;
  bool get estaPausado => _estado == EstadoReproductor.pausado;
  bool get estaDetenido => _estado == EstadoReproductor.detenido;
  bool get estaCargando => _estado == EstadoReproductor.cargando;
  bool get tieneError => _estado == EstadoReproductor.error;

  /// Obtiene el progreso como valor entre 0 y 1
  double get progreso {
    if (_duracion.inMilliseconds > 0) {
      return _posicion.inMilliseconds / _duracion.inMilliseconds;
    }
    return 0.0;
  }

  /// Obtiene la posición formateada como string MM:SS
  String get posicionFormateada => FormateadorDuracion.formatearMMSS(_posicion);

  /// Obtiene la duración formateada como string MM:SS
  String get duracionFormateada => FormateadorDuracion.formatearMMSS(_duracion);

  /// Reproduce o pausa el audio
  Future<void> reproducirPausar(String rutaAudio) async {
    try {
      if (_estado == EstadoReproductor.reproduciendo) {
        await pausar();
      } else if (_estado == EstadoReproductor.pausado &&
          rutaAudio == _rutaAudioActual) {
        await reanudar();
      } else {
        await reproducir(rutaAudio);
      }
    } catch (e) {
      _manejarError('Error al reproducir/pausar: $e');
    }
  }

  /// Reproduce un audio desde el inicio
  Future<void> reproducir(String rutaAudio) async {
    try {
      _cambiarEstado(EstadoReproductor.cargando);
      _rutaAudioActual = rutaAudio;

      await _reproductorAudio.play(AssetSource(rutaAudio));
      _cambiarEstado(EstadoReproductor.reproduciendo);
    } catch (e) {
      _manejarError('Error al reproducir: $e');
    }
  }

  /// Pausa la reproducción actual
  Future<void> pausar() async {
    try {
      await _reproductorAudio.pause();
      _cambiarEstado(EstadoReproductor.pausado);
    } catch (e) {
      _manejarError('Error al pausar: $e');
    }
  }

  /// Reanuda la reproducción pausada
  Future<void> reanudar() async {
    try {
      await _reproductorAudio.resume();
      _cambiarEstado(EstadoReproductor.reproduciendo);
    } catch (e) {
      _manejarError('Error al reanudar: $e');
    }
  }

  /// Detiene la reproducción
  Future<void> detener() async {
    try {
      await _reproductorAudio.stop();
      _cambiarEstado(EstadoReproductor.detenido);
      _posicion = Duration.zero;
      notifyListeners();
    } catch (e) {
      _manejarError('Error al detener: $e');
    }
  }

  /// Busca una posición específica en el audio
  Future<void> buscarPosicion(double valorProgreso) async {
    try {
      final nuevaPosicion = Duration(
        milliseconds: (valorProgreso * _duracion.inMilliseconds).round(),
      );
      await _reproductorAudio.seek(nuevaPosicion);
    } catch (e) {
      print('Error al buscar posición: $e');
    }
  }

  /// Avanza o retrocede una cantidad de segundos
  Future<void> saltar(int segundos) async {
    final nuevaPosicion = _posicion + Duration(seconds: segundos);
    
    if (nuevaPosicion < Duration.zero) {
      await buscarPosicion(0.0);
    } else if (nuevaPosicion > _duracion) {
      await buscarPosicion(1.0);
    } else {
      final progreso = nuevaPosicion.inMilliseconds / _duracion.inMilliseconds;
      await buscarPosicion(progreso);
    }
  }

  /// Avanza 10 segundos
  Future<void> avanzar() => saltar(10);

  /// Retrocede 10 segundos
  Future<void> retroceder() => saltar(-10);

  // ========== MÉTODOS PRIVADOS ==========

  void _configurarReproductor() {
    _reproductorAudio.onDurationChanged.listen((duracion) {
      _duracion = duracion;
      notifyListeners();
    });

    _reproductorAudio.onPositionChanged.listen((posicion) {
      _posicion = posicion;
      notifyListeners();
    });

    _reproductorAudio.onPlayerComplete.listen((event) {
      _cambiarEstado(EstadoReproductor.detenido);
      _posicion = Duration.zero;
      notifyListeners();
    });

    _reproductorAudio.onPlayerStateChanged.listen((estado) {
      // Manejar cambios de estado si es necesario
    });
  }

  void _cambiarEstado(EstadoReproductor nuevoEstado) {
    _estado = nuevoEstado;
    if (nuevoEstado != EstadoReproductor.error) {
      _mensajeError = null;
    }
    notifyListeners();
  }

  void _manejarError(String mensaje) {
    _mensajeError = mensaje;
    _cambiarEstado(EstadoReproductor.error);
    print(mensaje);
  }

  @override
  void dispose() {
    _reproductorAudio.dispose();
    super.dispose();
  }
}
