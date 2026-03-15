import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../modelos/modelos_chat.dart';

/// Capa de acceso a SQLite para hilos y mensajes
class DbHilos {
  static const int _version = 1;
  static const String _dbName = 'agente_hilos.db';
  static const int _maxHilos = 30;

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _inicializar();
    return _db!;
  }

  Future<Database> _inicializar() async {
    final ruta = p.join(await getDatabasesPath(), _dbName);
    return openDatabase(
      ruta,
      version: _version,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE threads (
            thread_id   TEXT PRIMARY KEY,
            title       TEXT NOT NULL,
            created_at  INTEGER NOT NULL,
            last_message_at INTEGER NOT NULL,
            is_pinned   INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE messages (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            thread_id   TEXT NOT NULL,
            role        TEXT NOT NULL,
            content     TEXT NOT NULL,
            timestamp   INTEGER NOT NULL,
            FOREIGN KEY (thread_id) REFERENCES threads(thread_id)
              ON DELETE CASCADE
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_messages_thread ON messages(thread_id)');
      },
    );
  }

  // ─── Hilos ────────────────────────────────────────────────────────────────

  /// Lista todos los hilos ordenados: pinned primero, luego por fecha desc
  Future<List<ConversationThread>> listarHilos() async {
    final database = await db;
    final rows = await database.query(
      'threads',
      orderBy: 'is_pinned DESC, last_message_at DESC',
    );
    return rows.map(ConversationThread.fromMap).toList();
  }

  /// Inserta un hilo nuevo
  Future<void> insertarHilo(ConversationThread hilo) async {
    final database = await db;
    await database.insert(
      'threads',
      hilo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _limpiarHilosAntiguos(database);
  }

  /// Actualiza title, lastMessageAt e isPinned de un hilo
  Future<void> actualizarHilo(ConversationThread hilo) async {
    final database = await db;
    await database.update(
      'threads',
      {
        'title': hilo.title,
        'last_message_at': hilo.lastMessageAt.millisecondsSinceEpoch,
        'is_pinned': hilo.isPinned ? 1 : 0,
      },
      where: 'thread_id = ?',
      whereArgs: [hilo.threadId],
    );
  }

  /// Elimina un hilo y sus mensajes (ON DELETE CASCADE)
  Future<void> eliminarHilo(String threadId) async {
    final database = await db;
    await database.delete(
      'threads',
      where: 'thread_id = ?',
      whereArgs: [threadId],
    );
  }

  /// Limita a _maxHilos eliminando los más antiguos no pinneados
  Future<void> _limpiarHilosAntiguos(Database database) async {
    final total = Sqflite.firstIntValue(
      await database.rawQuery('SELECT COUNT(*) FROM threads'),
    )!;
    if (total <= _maxHilos) return;

    final sobran = total - _maxHilos;
    await database.rawDelete('''
      DELETE FROM threads
      WHERE thread_id IN (
        SELECT thread_id FROM threads
        WHERE is_pinned = 0
        ORDER BY last_message_at ASC
        LIMIT $sobran
      )
    ''');
  }

  // ─── Mensajes ─────────────────────────────────────────────────────────────

  /// Carga todos los mensajes de un hilo (lazy)
  Future<List<ChatMessage>> cargarMensajes(String threadId) async {
    final database = await db;
    final rows = await database.query(
      'messages',
      where: 'thread_id = ?',
      whereArgs: [threadId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(ChatMessage.fromMap).toList();
  }

  /// Inserta un mensaje
  Future<void> insertarMensaje(
      String threadId, ChatMessage mensaje) async {
    final database = await db;
    await database.insert('messages', {
      ...mensaje.toMap(),
      'thread_id': threadId,
    });
  }

  /// Reemplaza todos los mensajes de un hilo (para sync con servidor)
  Future<void> reemplazarMensajes(
      String threadId, List<ChatMessage> mensajes) async {
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('messages',
          where: 'thread_id = ?', whereArgs: [threadId]);
      for (final m in mensajes) {
        await txn.insert('messages', {
          ...m.toMap(),
          'thread_id': threadId,
        });
      }
    });
  }

  /// Cuántos mensajes tiene un hilo (sin cargarlos)
  Future<int> contarMensajes(String threadId) async {
    final database = await db;
    return Sqflite.firstIntValue(
          await database.rawQuery(
            'SELECT COUNT(*) FROM messages WHERE thread_id = ?',
            [threadId],
          ),
        ) ??
        0;
  }
}