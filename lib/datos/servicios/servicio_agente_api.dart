import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Modelo de un mensaje de chat
class MensajeChat {
  final String rol; // 'user' o 'assistant'
  final String contenido;
  final DateTime timestamp;
  final bool esStreaming;

  MensajeChat({
    required this.rol,
    required this.contenido,
    required this.timestamp,
    this.esStreaming = false,
  });

  Map<String, dynamic> toJson() => {
        'role': rol,
        'content': contenido,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MensajeChat.fromJson(Map<String, dynamic> json) => MensajeChat(
        rol: json['role'],
        contenido: json['content'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Eventos SSE del agente
enum TipoEventoSSE { metadata, toolStart, toolEnd, token, done, error }

class EventoSSE {
  final TipoEventoSSE tipo;
  final dynamic datos;

  EventoSSE({required this.tipo, required this.datos});
}

/// Servicio principal para comunicarse con el Agente Eclesiástico
class ServicioAgenteApi {
  static const String _baseUrl =
      'https://agente-eclesi-stico-production.up.railway.app';
  // NOTA: En producción, mueve esto a variables de entorno o flutter_dotenv
  static const String _apiKey = 'HHVOu0xoGF7yphcvj2hZ0CHdf7FpbuFyBzoWgfwitNGd7IzX';

  static const String _claveThreadId = 'user_thread_id';
  static const String _claveMensajesDiarios = 'daily_message_count';
  static const String _claveUltimoReset = 'last_reset_date';
  static const String _claveHistorialLocal = 'local_chat_history';
  static const int _limiteDiario = 20;
  static const int _maxHistorialLocal = 50;
  static const int _maxReintentos = 2;
  static const Duration _esperaReintento = Duration(seconds: 3);

  String? _threadId;

  /// Inicializa o recupera el thread_id único del dispositivo
  Future<String> obtenerThreadId() async {
    if (_threadId != null) return _threadId!;

    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_claveThreadId);

    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_claveThreadId, id);
    }

    _threadId = id;
    return id;
  }

  /// Verifica y actualiza el límite diario de mensajes
  /// Retorna [mensajesRestantes] o -1 si se superó el límite
  Future<int> verificarLimiteDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = _fechaHoy();
    final ultimoReset = prefs.getString(_claveUltimoReset) ?? '';

    if (ultimoReset != hoy) {
      await prefs.setInt(_claveMensajesDiarios, 0);
      await prefs.setString(_claveUltimoReset, hoy);
    }

    final conteo = prefs.getInt(_claveMensajesDiarios) ?? 0;
    return _limiteDiario - conteo;
  }

  /// Incrementa el contador diario de mensajes
  Future<void> incrementarContadorDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final conteo = prefs.getInt(_claveMensajesDiarios) ?? 0;
    await prefs.setInt(_claveMensajesDiarios, conteo + 1);
  }

  /// Envía un mensaje al agente con streaming SSE
  /// Retorna un Stream de EventoSSE
  Stream<EventoSSE> enviarMensaje(String mensaje) async* {
    final threadId = await obtenerThreadId();

    for (int intento = 0; intento <= _maxReintentos; intento++) {
      try {
        final request = http.Request(
          'POST',
          Uri.parse('$_baseUrl/api/v1/chat/stream'),
        );

        request.headers.addAll({
          'X-API-Key': _apiKey,
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        });

        request.body = jsonEncode({
          'message': mensaje,
          'thread_id': threadId,
        });

        final client = http.Client();
        final response = await client.send(request).timeout(
          const Duration(seconds: 60),
        );

        if (response.statusCode != 200) {
          throw Exception('Error HTTP ${response.statusCode}');
        }

        // Leer el stream SSE línea por línea
        final buffer = StringBuffer();
        await for (final chunk in response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())) {
          final linea = chunk.trim();

          if (linea.startsWith('data: ')) {
            final jsonStr = linea.substring(6);
            if (jsonStr.isNotEmpty) {
              try {
                final json = jsonDecode(jsonStr) as Map<String, dynamic>;
                final evento = _parsearEvento(json);
                if (evento != null) {
                  yield evento;
                  if (evento.tipo == TipoEventoSSE.done ||
                      evento.tipo == TipoEventoSSE.error) {
                    client.close();
                    return;
                  }
                }
              } catch (_) {
                // Ignorar líneas mal formadas
              }
            }
          }
        }

        client.close();
        return; // Éxito, salir del loop de reintentos
      } catch (e) {
        if (intento < _maxReintentos) {
          yield EventoSSE(
            tipo: TipoEventoSSE.token,
            datos: '', // No mostrar nada, solo esperar
          );
          await Future.delayed(_esperaReintento);
        } else {
          yield EventoSSE(
            tipo: TipoEventoSSE.error,
            datos: {'message': 'Error de conexión: $e'},
          );
        }
      }
    }
  }

  EventoSSE? _parsearEvento(Map<String, dynamic> json) {
    final tipo = json['type'] as String?;
    final datos = json['data'];

    switch (tipo) {
      case 'metadata':
        return EventoSSE(tipo: TipoEventoSSE.metadata, datos: datos);
      case 'tool_start':
        return EventoSSE(tipo: TipoEventoSSE.toolStart, datos: datos);
      case 'tool_end':
        return EventoSSE(tipo: TipoEventoSSE.toolEnd, datos: datos);
      case 'token':
        return EventoSSE(tipo: TipoEventoSSE.token, datos: datos as String? ?? '');
      case 'done':
        return EventoSSE(tipo: TipoEventoSSE.done, datos: datos);
      case 'error':
        return EventoSSE(tipo: TipoEventoSSE.error, datos: datos);
      default:
        return null;
    }
  }

  // ─── Historial local ───────────────────────────────────────────────────────

  /// Carga el historial local guardado en SharedPreferences
  Future<List<MensajeChat>> cargarHistorialLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_claveHistorialLocal);
    if (jsonStr == null) return [];

    try {
      final lista = jsonDecode(jsonStr) as List;
      return lista.map((e) => MensajeChat.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Guarda el historial local (máximo 50 mensajes, FIFO)
  Future<void> guardarHistorialLocal(List<MensajeChat> mensajes) async {
    final prefs = await SharedPreferences.getInstance();
    var lista = mensajes;
    if (lista.length > _maxHistorialLocal) {
      lista = lista.sublist(lista.length - _maxHistorialLocal);
    }
    final jsonStr = jsonEncode(lista.map((m) => m.toJson()).toList());
    await prefs.setString(_claveHistorialLocal, jsonStr);
  }

  /// Obtiene historial del servidor (fallback)
  Future<List<MensajeChat>> obtenerHistorialServidor() async {
    final threadId = await obtenerThreadId();
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/chat/$threadId/history'),
        headers: {'X-API-Key': _apiKey},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final mensajes = (json['messages'] as List)
            .map((m) => MensajeChat(
                  rol: m['role'],
                  contenido: m['content'],
                  timestamp: DateTime.now(),
                ))
            .toList();
        return mensajes;
      }
    } catch (_) {}
    return [];
  }

  String _fechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}