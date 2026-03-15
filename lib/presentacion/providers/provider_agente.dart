import 'package:flutter/foundation.dart';
import '../../datos/servicios/servicio_agente_api.dart';

enum EstadoAgente { inactivo, consultandoHerramienta, streaming, error }

class ProviderAgente extends ChangeNotifier {
  final ServicioAgenteApi _servicio;

  ProviderAgente({ServicioAgenteApi? servicio})
      : _servicio = servicio ?? ServicioAgenteApi();

  List<MensajeChat> _mensajes = [];
  EstadoAgente _estado = EstadoAgente.inactivo;
  String? _mensajeError;
  int _mensajesRestantes = 20;
  bool _inicializado = false;

  List<MensajeChat> get mensajes => List.unmodifiable(_mensajes);
  EstadoAgente get estado => _estado;
  String? get mensajeError => _mensajeError;
  int get mensajesRestantes => _mensajesRestantes;
  bool get estaActivo => _estado != EstadoAgente.inactivo;
  bool get inicializado => _inicializado;

  /// Inicializa: carga historial y verifica límite
  Future<void> inicializar() async {
    if (_inicializado) return;

    // Cargar historial local primero
    final historialLocal = await _servicio.cargarHistorialLocal();

    if (historialLocal.isNotEmpty) {
      _mensajes = historialLocal;
    } else {
      // Fallback: obtener del servidor
      final historialServidor = await _servicio.obtenerHistorialServidor();
      _mensajes = historialServidor;
      if (_mensajes.isNotEmpty) {
        await _servicio.guardarHistorialLocal(_mensajes);
      }
    }

    await _actualizarContador();
    _inicializado = true;
    notifyListeners();
  }

  Future<void> _actualizarContador() async {
    _mensajesRestantes = await _servicio.verificarLimiteDiario();
    notifyListeners();
  }

  /// Envía un mensaje y procesa el stream SSE
  Future<void> enviarMensaje(String texto) async {
    if (_estado != EstadoAgente.inactivo) return;

    // Verificar límite diario
    await _actualizarContador();
    if (_mensajesRestantes <= 0) {
      _mensajeError =
          'Has alcanzado el límite de mensajes de hoy. Vuelve mañana, hermano/hermana.';
      notifyListeners();
      return;
    }

    _mensajeError = null;

    // Agregar mensaje del usuario
    final msgUsuario = MensajeChat(
      rol: 'user',
      contenido: texto,
      timestamp: DateTime.now(),
    );
    _mensajes.add(msgUsuario);
    notifyListeners();

    // Incrementar contador
    await _servicio.incrementarContadorDiario();
    await _actualizarContador();

    // Placeholder para el mensaje del asistente (streaming)
    final msgAsistente = MensajeChat(
      rol: 'assistant',
      contenido: '',
      timestamp: DateTime.now(),
      esStreaming: true,
    );
    _mensajes.add(msgAsistente);
    _estado = EstadoAgente.consultandoHerramienta;
    notifyListeners();

    final buffer = StringBuffer();
    bool primerToken = false;

    try {
      await for (final evento in _servicio.enviarMensaje(texto)) {
        switch (evento.tipo) {
          case TipoEventoSSE.toolStart:
            _estado = EstadoAgente.consultandoHerramienta;
            notifyListeners();
            break;

          case TipoEventoSSE.toolEnd:
            // Herramienta terminó, próximamente vendrán tokens
            break;

          case TipoEventoSSE.token:
            if (!primerToken) {
              primerToken = true;
              _estado = EstadoAgente.streaming;
            }
            buffer.write(evento.datos as String);
            // Actualizar el último mensaje (asistente)
            _mensajes[_mensajes.length - 1] = MensajeChat(
              rol: 'assistant',
              contenido: buffer.toString(),
              timestamp: msgAsistente.timestamp,
              esStreaming: true,
            );
            notifyListeners();
            break;

          case TipoEventoSSE.done:
            _mensajes[_mensajes.length - 1] = MensajeChat(
              rol: 'assistant',
              contenido: buffer.toString(),
              timestamp: msgAsistente.timestamp,
              esStreaming: false,
            );
            _estado = EstadoAgente.inactivo;
            await _servicio.guardarHistorialLocal(_mensajes);
            notifyListeners();
            break;

          case TipoEventoSSE.error:
            final errMsg = (evento.datos as Map?)?['message'] ?? 'Error desconocido';
            _mensajeError = errMsg.toString();
            // Quitar el placeholder vacío si no hubo tokens
            if (buffer.isEmpty) {
              _mensajes.removeLast();
            } else {
              _mensajes[_mensajes.length - 1] = MensajeChat(
                rol: 'assistant',
                contenido: buffer.toString(),
                timestamp: msgAsistente.timestamp,
                esStreaming: false,
              );
            }
            _estado = EstadoAgente.error;
            await _servicio.guardarHistorialLocal(_mensajes);
            notifyListeners();
            break;

          default:
            break;
        }
      }
    } catch (e) {
      _mensajeError = 'Error inesperado: $e';
      if (buffer.isEmpty) _mensajes.removeLast();
      _estado = EstadoAgente.error;
      notifyListeners();
    }
  }

  void limpiarError() {
    _mensajeError = null;
    if (_estado == EstadoAgente.error) {
      _estado = EstadoAgente.inactivo;
    }
    notifyListeners();
  }

  /// Limpia el historial local (no borra el del servidor)
  Future<void> limpiarHistorial() async {
    _mensajes.clear();
    await _servicio.guardarHistorialLocal([]);
    notifyListeners();
  }
}