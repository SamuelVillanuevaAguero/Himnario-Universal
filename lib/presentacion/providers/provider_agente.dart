import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../datos/base_datos/db_hilos.dart';
import '../../datos/servicios/servicio_agente_api.dart';

export '../../datos/modelos/modelos_chat.dart';

enum EstadoChat { inactivo, consultandoHerramienta, streaming, error }

class ProviderAgente extends ChangeNotifier {
  final DbHilos _db;
  final ServicioAgenteApi _api;

  ProviderAgente({DbHilos? db, ServicioAgenteApi? api})
      : _db = db ?? DbHilos(),
        _api = api ?? ServicioAgenteApi();

  // ─── Estado ──────────────────────────────────────────────────────────────
  List<ConversationThread> _hilos = [];
  ConversationThread? _hiloActivo;
  bool _inicializado = false;
  EstadoChat _estadoChat = EstadoChat.inactivo;
  String? _errorMensaje;
  int _mensajesRestantes = 20;

  // ─── Getters ─────────────────────────────────────────────────────────────
  List<ConversationThread> get hilos => List.unmodifiable(_hilos);
  ConversationThread? get hiloActivo => _hiloActivo;
  List<ChatMessage> get mensajesActivos => _hiloActivo?.messages ?? [];
  EstadoChat get estadoChat => _estadoChat;
  String? get errorMensaje => _errorMensaje;
  int get mensajesRestantes => _mensajesRestantes;
  bool get inicializado => _inicializado;
  bool get estaActivo => _estadoChat != EstadoChat.inactivo;

  // ─── Inicialización ──────────────────────────────────────────────────────

  Future<void> inicializar() async {
    if (_inicializado) return;
    _hilos = await _db.listarHilos();
    _mensajesRestantes = await _api.verificarLimiteDiario();
    _inicializado = true;
    notifyListeners();
  }

  // ─── Gestión de hilos ────────────────────────────────────────────────────

  /// Abre un hilo: lazy-load de mensajes si están vacíos, sync servidor si
  /// tampoco hay mensajes en SQLite
  Future<void> abrirHilo(String threadId) async {
    final idx = _hilos.indexWhere((h) => h.threadId == threadId);
    if (idx < 0) return;

    var hilo = _hilos[idx];

    // Lazy load desde SQLite
    final conteo = await _db.contarMensajes(threadId);
    if (conteo > 0) {
      final msgs = await _db.cargarMensajes(threadId);
      hilo = hilo.copyWith(messages: msgs, status: ThreadStatus.idle);
    } else {
      // Fallback: intentar recuperar del servidor
      final msgs = await _api.obtenerHistorialServidor(threadId);
      if (msgs.isNotEmpty) {
        await _db.reemplazarMensajes(threadId, msgs);
        hilo = hilo.copyWith(messages: msgs, status: ThreadStatus.idle);
      }
    }

    _hilos[idx] = hilo;
    _hiloActivo = hilo;
    _estadoChat = EstadoChat.inactivo;
    _errorMensaje = null;
    notifyListeners();
  }

  /// Crea un nuevo hilo vacío y lo activa
  Future<ConversationThread> crearHilo() async {
    final ahora = DateTime.now();
    final hilo = ConversationThread(
      threadId: const Uuid().v4(),
      title: 'Nueva conversación',
      createdAt: ahora,
      lastMessageAt: ahora,
      messages: [],
    );
    await _db.insertarHilo(hilo);
    _hilos = await _db.listarHilos();
    _hiloActivo = hilo;
    _estadoChat = EstadoChat.inactivo;
    _errorMensaje = null;
    notifyListeners();
    return hilo;
  }

  /// Elimina un hilo. Si era el activo, activa el siguiente o crea uno.
  Future<void> eliminarHilo(String threadId) async {
    final eraActivo = _hiloActivo?.threadId == threadId;
    await _db.eliminarHilo(threadId);
    _hilos = await _db.listarHilos();

    if (eraActivo) {
      if (_hilos.isNotEmpty) {
        await abrirHilo(_hilos.first.threadId);
      } else {
        _hiloActivo = null;
        notifyListeners();
      }
    } else {
      notifyListeners();
    }
  }

  /// Elimina el hilo si está vacío (usuario creó pero no envió nada)
  Future<void> eliminarHiloSiVacio(String threadId) async {
    final conteo = await _db.contarMensajes(threadId);
    if (conteo == 0) await eliminarHilo(threadId);
  }

  /// Renombra un hilo
  Future<void> renombrarHilo(String threadId, String nuevoTitulo) async {
    final idx = _hilos.indexWhere((h) => h.threadId == threadId);
    if (idx < 0) return;
    _hilos[idx] = _hilos[idx].copyWith(title: nuevoTitulo);
    await _db.actualizarHilo(_hilos[idx]);
    if (_hiloActivo?.threadId == threadId) {
      _hiloActivo = _hilos[idx];
    }
    notifyListeners();
  }

  /// Alterna el pin de un hilo
  Future<void> togglePin(String threadId) async {
    final idx = _hilos.indexWhere((h) => h.threadId == threadId);
    if (idx < 0) return;
    _hilos[idx] = _hilos[idx].copyWith(isPinned: !_hilos[idx].isPinned);
    await _db.actualizarHilo(_hilos[idx]);
    // Re-ordenar: pinned primero
    _hilos.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });
    if (_hiloActivo?.threadId == threadId) {
      _hiloActivo = _hilos[idx];
    }
    notifyListeners();
  }

  // ─── Envío de mensajes ───────────────────────────────────────────────────

  Future<void> enviarMensaje(String texto) async {
    if (_estadoChat != EstadoChat.inactivo) return;
    if (_hiloActivo == null) {
      await crearHilo();
    }

    _mensajesRestantes = await _api.verificarLimiteDiario();
    if (_mensajesRestantes <= 0) {
      _errorMensaje =
          'Has alcanzado el límite de mensajes de hoy. Vuelve mañana, hermano/hermana.';
      notifyListeners();
      return;
    }
    _errorMensaje = null;

    final threadId = _hiloActivo!.threadId;
    final ahora = DateTime.now();
    final msgUsuario = ChatMessage(
      role: 'user',
      content: texto,
      timestamp: ahora,
    );

    // — Optimistic update: guardar usuario de inmediato —
    var msgs = List<ChatMessage>.from(_hiloActivo!.messages)
      ..add(msgUsuario);
    await _db.insertarMensaje(threadId, msgUsuario);

    // Asignar título automático si es el primer mensaje
    bool esPrimerMensaje = _hiloActivo!.messages.isEmpty;
    if (esPrimerMensaje) {
      final titulo = ConversationThread.generarTitulo(texto);
      final idx =
          _hilos.indexWhere((h) => h.threadId == threadId);
      if (idx >= 0) {
        _hilos[idx] = _hilos[idx].copyWith(title: titulo);
        await _db.actualizarHilo(_hilos[idx]);
      }
      _hiloActivo = _hiloActivo!.copyWith(
        title: titulo,
        messages: msgs,
      );
    } else {
      _hiloActivo = _hiloActivo!.copyWith(messages: msgs);
    }

    _actualizarHiloEnLista(_hiloActivo!);
    _estadoChat = EstadoChat.consultandoHerramienta;
    await _api.incrementarContadorDiario();
    _mensajesRestantes = await _api.verificarLimiteDiario();
    notifyListeners();

    // Placeholder del asistente para streaming
    final tsAsistente = DateTime.now();
    final placeholder = ChatMessage(
      role: 'assistant',
      content: '',
      timestamp: tsAsistente,
    );
    msgs = List<ChatMessage>.from(msgs)..add(placeholder);
    _hiloActivo = _hiloActivo!.copyWith(messages: msgs);
    notifyListeners();

    final buffer = StringBuffer();
    bool primerToken = false;

    try {
      await for (final evento
          in _api.enviarMensaje(texto, threadId)) {
        switch (evento.tipo) {
          case TipoEventoSSE.toolStart:
          case TipoEventoSSE.toolEnd:
            break;

          case TipoEventoSSE.token:
            if (!primerToken) {
              primerToken = true;
              _estadoChat = EstadoChat.streaming;
            }
            buffer.write(evento.datos as String);
            msgs = List<ChatMessage>.from(msgs);
            msgs[msgs.length - 1] = ChatMessage(
              role: 'assistant',
              content: buffer.toString(),
              timestamp: tsAsistente,
            );
            _hiloActivo = _hiloActivo!.copyWith(messages: msgs);
            notifyListeners();
            break;

          case TipoEventoSSE.done:
            // Guardar respuesta completa en SQLite
            final msgFinal = ChatMessage(
              role: 'assistant',
              content: buffer.toString(),
              timestamp: tsAsistente,
            );
            msgs = List<ChatMessage>.from(msgs);
            msgs[msgs.length - 1] = msgFinal;
            await _db.insertarMensaje(threadId, msgFinal);

            // Actualizar lastMessageAt
            final hiloFinal = _hiloActivo!.copyWith(
              messages: msgs,
              lastMessageAt: DateTime.now(),
              status: ThreadStatus.idle,
            );
            await _db.actualizarHilo(hiloFinal);
            _hiloActivo = hiloFinal;
            _actualizarHiloEnLista(hiloFinal);
            _reordenarHilos();
            _estadoChat = EstadoChat.inactivo;
            notifyListeners();
            break;

          case TipoEventoSSE.error:
            final err =
                (evento.datos as Map?)?['message'] ?? 'Error desconocido';
            _errorMensaje = err.toString();
            // Quitar placeholder vacío
            if (buffer.isEmpty) {
              msgs = List<ChatMessage>.from(msgs)..removeLast();
            } else {
              msgs = List<ChatMessage>.from(msgs);
              msgs[msgs.length - 1] = ChatMessage(
                role: 'assistant',
                content: buffer.toString(),
                timestamp: tsAsistente,
              );
              await _db.insertarMensaje(
                threadId,
                msgs.last,
              );
            }
            _hiloActivo = _hiloActivo!.copyWith(
              messages: msgs,
              status: ThreadStatus.error,
            );
            _actualizarHiloEnLista(_hiloActivo!);
            _estadoChat = EstadoChat.error;
            notifyListeners();
            break;

          default:
            break;
        }
      }
    } catch (e) {
      _errorMensaje = 'Error inesperado: $e';
      if (buffer.isEmpty && msgs.isNotEmpty) {
        msgs = List<ChatMessage>.from(msgs)..removeLast();
      }
      _hiloActivo = _hiloActivo!.copyWith(
          messages: msgs, status: ThreadStatus.error);
      _actualizarHiloEnLista(_hiloActivo!);
      _estadoChat = EstadoChat.error;
      notifyListeners();
    }
  }

  void limpiarError() {
    _errorMensaje = null;
    if (_estadoChat == EstadoChat.error) {
      _estadoChat = EstadoChat.inactivo;
      if (_hiloActivo != null) {
        _hiloActivo =
            _hiloActivo!.copyWith(status: ThreadStatus.idle);
        _actualizarHiloEnLista(_hiloActivo!);
      }
    }
    notifyListeners();
  }

  // ─── Exportar conversación ───────────────────────────────────────────────

  /// Genera texto plano con el historial completo para share_plus
  Future<String> exportarHilo(String threadId) async {
    final msgs = await _db.cargarMensajes(threadId);
    final hilo = _hilos.firstWhere((h) => h.threadId == threadId);
    final buf = StringBuffer();
    buf.writeln('=== ${hilo.title} ===');
    buf.writeln(
        'Exportado el ${DateTime.now().toString().substring(0, 16)}');
    buf.writeln('');
    for (final m in msgs) {
      final quien = m.role == 'user' ? 'Tú' : 'Asistente';
      final hora = m.timestamp.toString().substring(11, 16);
      buf.writeln('[$hora] $quien:');
      buf.writeln(m.content);
      buf.writeln('');
    }
    return buf.toString();
  }

  // ─── Helpers privados ────────────────────────────────────────────────────

  void _actualizarHiloEnLista(ConversationThread hilo) {
    final idx = _hilos.indexWhere((h) => h.threadId == hilo.threadId);
    if (idx >= 0) _hilos[idx] = hilo;
  }

  void _reordenarHilos() {
    _hilos.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });
  }
}