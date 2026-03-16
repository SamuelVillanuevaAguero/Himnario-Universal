import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/modelos_chat.dart';

// Importaciones condicionales para sqflite (solo nativo)
import 'db_nativo.dart' if (dart.library.html) 'db_stub.dart'
    as db_impl;

/// Capa de acceso a datos — usa SQLite en nativo y SharedPreferences en web
class DbHilos {
  static const int _maxHilos = 30;

  // ─── Hilos ────────────────────────────────────────────────────────────────

  Future<List<ConversationThread>> listarHilos() async {
    if (kIsWeb) return _webListarHilos();
    return db_impl.listarHilos();
  }

  Future<void> insertarHilo(ConversationThread hilo) async {
    if (kIsWeb) {
      await _webInsertarHilo(hilo);
    } else {
      await db_impl.insertarHilo(hilo);
    }
  }

  Future<void> actualizarHilo(ConversationThread hilo) async {
    if (kIsWeb) {
      await _webActualizarHilo(hilo);
    } else {
      await db_impl.actualizarHilo(hilo);
    }
  }

  Future<void> eliminarHilo(String threadId) async {
    if (kIsWeb) {
      await _webEliminarHilo(threadId);
    } else {
      await db_impl.eliminarHilo(threadId);
    }
  }

  // ─── Mensajes ─────────────────────────────────────────────────────────────

  Future<List<ChatMessage>> cargarMensajes(String threadId) async {
    if (kIsWeb) return _webCargarMensajes(threadId);
    return db_impl.cargarMensajes(threadId);
  }

  Future<void> insertarMensaje(
      String threadId, ChatMessage mensaje) async {
    if (kIsWeb) {
      await _webInsertarMensaje(threadId, mensaje);
    } else {
      await db_impl.insertarMensaje(threadId, mensaje);
    }
  }

  Future<void> reemplazarMensajes(
      String threadId, List<ChatMessage> mensajes) async {
    if (kIsWeb) {
      await _webReemplazarMensajes(threadId, mensajes);
    } else {
      await db_impl.reemplazarMensajes(threadId, mensajes);
    }
  }

  Future<int> contarMensajes(String threadId) async {
    if (kIsWeb) return _webContarMensajes(threadId);
    return db_impl.contarMensajes(threadId);
  }

  // ─── Implementación Web (SharedPreferences) ───────────────────────────────

  static const String _claveHilos = 'hilos_v2_list';
  static const String _prefMensajes = 'hilos_msgs_';

  Future<List<ConversationThread>> _webListarHilos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_claveHilos);
    if (raw == null) return [];
    try {
      final lista = jsonDecode(raw) as List;
      final hilos = lista
          .map((e) => ConversationThread.fromMap(e as Map<String, dynamic>))
          .toList();
      hilos.sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.lastMessageAt.compareTo(a.lastMessageAt);
      });
      return hilos;
    } catch (_) {
      return [];
    }
  }

  Future<void> _webGuardarListaHilos(
      List<ConversationThread> hilos) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(hilos.map((h) => h.toMap()).toList());
    await prefs.setString(_claveHilos, json);
  }

  Future<void> _webInsertarHilo(ConversationThread hilo) async {
    var hilos = await _webListarHilos();
    hilos.removeWhere((h) => h.threadId == hilo.threadId);
    hilos.insert(0, hilo);
    // Límite de 30 hilos — eliminar el más antiguo no pinneado
    if (hilos.length > _maxHilos) {
      final idx = hilos.lastIndexWhere((h) => !h.isPinned);
      if (idx >= 0) hilos.removeAt(idx);
    }
    await _webGuardarListaHilos(hilos);
  }

  Future<void> _webActualizarHilo(ConversationThread hilo) async {
    final hilos = await _webListarHilos();
    final idx = hilos.indexWhere((h) => h.threadId == hilo.threadId);
    if (idx >= 0) hilos[idx] = hilo;
    await _webGuardarListaHilos(hilos);
  }

  Future<void> _webEliminarHilo(String threadId) async {
    final hilos = await _webListarHilos();
    hilos.removeWhere((h) => h.threadId == threadId);
    await _webGuardarListaHilos(hilos);
    // Borrar mensajes del hilo
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefMensajes$threadId');
  }

  Future<List<ChatMessage>> _webCargarMensajes(String threadId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefMensajes$threadId');
    if (raw == null) return [];
    try {
      final lista = jsonDecode(raw) as List;
      return lista
          .map((e) => ChatMessage.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _webInsertarMensaje(
      String threadId, ChatMessage mensaje) async {
    final msgs = await _webCargarMensajes(threadId);
    msgs.add(mensaje);
    await _webGuardarMensajes(threadId, msgs);
  }

  Future<void> _webReemplazarMensajes(
      String threadId, List<ChatMessage> mensajes) async {
    await _webGuardarMensajes(threadId, mensajes);
  }

  Future<int> _webContarMensajes(String threadId) async {
    final msgs = await _webCargarMensajes(threadId);
    return msgs.length;
  }

  Future<void> _webGuardarMensajes(
      String threadId, List<ChatMessage> msgs) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(msgs.map((m) => m.toMap()).toList());
    await prefs.setString('$_prefMensajes$threadId', json);
  }
}