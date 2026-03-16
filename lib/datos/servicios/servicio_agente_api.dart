import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/modelos_chat.dart';

export '../modelos/modelos_chat.dart';

import 'fetch_client_web.dart'
    if (dart.library.io) '_http_client_stub.dart' as platform_client;

enum TipoEventoSSE { metadata, toolStart, toolEnd, token, done, error }

class EventoSSE {
  final TipoEventoSSE tipo;
  final dynamic datos;
  EventoSSE({required this.tipo, required this.datos});
}

class ServicioAgenteApi {
  static const String _baseUrl =
      'https://agente-eclesi-stico-production.up.railway.app';
  static const String _apiKey = 'HHVOu0xoGF7yphcvj2hZ0CHdf7FpbuFyBzoWgfwitNGd7IzX';

  static const String _claveMensajesDiarios = 'daily_message_count';
  static const String _claveUltimoReset = 'last_reset_date';
  static const int _limiteDiario = 10;
  static const int _maxReintentos = 2;
  static const Duration _esperaReintento = Duration(seconds: 3);

  // ─── Límite diario ────────────────────────────────────────────────────────

  Future<int> verificarLimiteDiario() async {
    final prefs = await SharedPreferences.getInstance();
    final hoy = _fechaHoy();
    if (prefs.getString(_claveUltimoReset) != hoy) {
      await prefs.setInt(_claveMensajesDiarios, 0);
      await prefs.setString(_claveUltimoReset, hoy);
    }
    return _limiteDiario - (prefs.getInt(_claveMensajesDiarios) ?? 0);
  }

  Future<void> incrementarContadorDiario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_claveMensajesDiarios,
        (prefs.getInt(_claveMensajesDiarios) ?? 0) + 1);
  }

  // ─── Streaming SSE ────────────────────────────────────────────────────────

  Stream<EventoSSE> enviarMensaje(String mensaje, String threadId) async* {
    for (int intento = 0; intento <= _maxReintentos; intento++) {
      // Usar FetchClient en web, http.Client en nativo
      final client = platform_client.crearCliente();
      try {
        final request = http.Request(
          'POST',
          Uri.parse('$_baseUrl/api/v1/chat/stream'),
        );
        request.headers.addAll({
          'X-API-Key': _apiKey,
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        });
        request.body = jsonEncode({
          'message': mensaje,
          'thread_id': threadId,
        });

        final response = await client.send(request);

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        // Buffer para manejar líneas que llegan partidas entre chunks
        final lineBuffer = StringBuffer();

        await for (final chunk in response.stream.transform(utf8.decoder)) {
          lineBuffer.write(chunk);
          final contenido = lineBuffer.toString();
          lineBuffer.clear();

          final lineas = contenido.split('\n');

          // Procesar todas las líneas completas
          for (int i = 0; i < lineas.length - 1; i++) {
            final evento = _procesarLinea(lineas[i].trim());
            if (evento != null) {
              yield evento;
              if (evento.tipo == TipoEventoSSE.done ||
                  evento.tipo == TipoEventoSSE.error) {
                client.close();
                return;
              }
            }
          }

          // Guardar fragmento incompleto para el próximo chunk
          if (lineas.last.isNotEmpty) {
            lineBuffer.write(lineas.last);
          }
        }

        // Procesar cualquier remanente
        final resto = lineBuffer.toString().trim();
        if (resto.isNotEmpty) {
          final evento = _procesarLinea(resto);
          if (evento != null) yield evento;
        }

        client.close();
        return;
      } catch (e) {
        client.close();
        if (intento < _maxReintentos) {
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

  // ─── Historial servidor (fallback) ────────────────────────────────────────

  Future<List<ChatMessage>> obtenerHistorialServidor(String threadId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/v1/chat/$threadId/history'),
            headers: {'X-API-Key': _apiKey},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return (json['messages'] as List)
            .map((m) => ChatMessage(
                  role: m['role'],
                  content: m['content'],
                  timestamp: DateTime.now(),
                ))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  EventoSSE? _procesarLinea(String linea) {
    if (!linea.startsWith('data: ')) return null;
    final jsonStr = linea.substring(6).trim();
    if (jsonStr.isEmpty) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return _parsear(json);
    } catch (_) {
      return null;
    }
  }

  EventoSSE? _parsear(Map<String, dynamic> json) {
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
        return EventoSSE(
            tipo: TipoEventoSSE.token, datos: datos as String? ?? '');
      case 'done':
        return EventoSSE(tipo: TipoEventoSSE.done, datos: datos);
      case 'error':
        return EventoSSE(tipo: TipoEventoSSE.error, datos: datos);
      default:
        return null;
    }
  }

  String _fechaHoy() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }
}