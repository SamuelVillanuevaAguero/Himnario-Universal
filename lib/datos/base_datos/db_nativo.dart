// Implementación SQLite para Android / iOS / Desktop
// Este archivo NO se compila en web.
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../modelos/modelos_chat.dart';

Database? _db;

Future<Database> _getDb() async {
  if (_db != null) return _db!;
  final ruta = p.join(await getDatabasesPath(), 'agente_hilos.db');
  _db = await openDatabase(
    ruta,
    version: 1,
    onCreate: (db, _) async {
      await db.execute('''
        CREATE TABLE threads (
          thread_id       TEXT PRIMARY KEY,
          title           TEXT NOT NULL,
          created_at      INTEGER NOT NULL,
          last_message_at INTEGER NOT NULL,
          is_pinned       INTEGER NOT NULL DEFAULT 0
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
          'CREATE INDEX idx_msg_thread ON messages(thread_id)');
    },
  );
  return _db!;
}

Future<List<ConversationThread>> listarHilos() async {
  final db = await _getDb();
  final rows = await db.query(
    'threads',
    orderBy: 'is_pinned DESC, last_message_at DESC',
  );
  return rows.map(ConversationThread.fromMap).toList();
}

Future<void> insertarHilo(ConversationThread hilo) async {
  final db = await _getDb();
  await db.insert('threads', hilo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  await _limpiarAntiguos(db);
}

Future<void> actualizarHilo(ConversationThread hilo) async {
  final db = await _getDb();
  await db.update(
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

Future<void> eliminarHilo(String threadId) async {
  final db = await _getDb();
  await db.delete('threads',
      where: 'thread_id = ?', whereArgs: [threadId]);
}

Future<List<ChatMessage>> cargarMensajes(String threadId) async {
  final db = await _getDb();
  final rows = await db.query('messages',
      where: 'thread_id = ?',
      whereArgs: [threadId],
      orderBy: 'timestamp ASC');
  return rows.map(ChatMessage.fromMap).toList();
}

Future<void> insertarMensaje(
    String threadId, ChatMessage mensaje) async {
  final db = await _getDb();
  await db.insert('messages', {...mensaje.toMap(), 'thread_id': threadId});
}

Future<void> reemplazarMensajes(
    String threadId, List<ChatMessage> mensajes) async {
  final db = await _getDb();
  await db.transaction((txn) async {
    await txn.delete('messages',
        where: 'thread_id = ?', whereArgs: [threadId]);
    for (final m in mensajes) {
      await txn
          .insert('messages', {...m.toMap(), 'thread_id': threadId});
    }
  });
}

Future<int> contarMensajes(String threadId) async {
  final db = await _getDb();
  return Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM messages WHERE thread_id = ?',
          [threadId])) ??
      0;
}

Future<void> _limpiarAntiguos(Database db) async {
  final total = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM threads')) ??
      0;
  if (total <= 30) return;
  final sobran = total - 30;
  await db.rawDelete('''
    DELETE FROM threads WHERE thread_id IN (
      SELECT thread_id FROM threads
      WHERE is_pinned = 0
      ORDER BY last_message_at ASC
      LIMIT $sobran
    )
  ''');
}