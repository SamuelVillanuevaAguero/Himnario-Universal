/// Modelo de un mensaje de chat
class ChatMessage {
  final String role; // "user" | "assistant"
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        role: m['role'],
        content: m['content'],
        timestamp:
            DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
      );
}

/// Estado visual de un hilo
enum ThreadStatus { idle, streaming, error }

/// Modelo de un hilo de conversación
class ConversationThread {
  final String threadId; // UUID — se envía a la API
  String title;
  List<ChatMessage> messages; // vacío hasta lazy-load
  final DateTime createdAt;
  DateTime lastMessageAt;
  bool isPinned;
  ThreadStatus status;

  ConversationThread({
    required this.threadId,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    this.messages = const [],
    this.isPinned = false,
    this.status = ThreadStatus.idle,
  });

  /// Preview del último mensaje (máx 60 chars)
  String get lastMessagePreview {
    if (messages.isEmpty) return 'Sin mensajes';
    final last = messages.last.content;
    return last.length > 60 ? '${last.substring(0, 60)}...' : last;
  }

  /// Genera el título a partir del primer mensaje del usuario
  static String generarTitulo(String primerMensaje) {
    final texto = primerMensaje.trim();
    final palabras = texto.split(' ');
    if (palabras.length <= 5) return texto;

    // Cortar en la última palabra completa dentro de 40 chars
    if (texto.length <= 40) return texto;
    final recortado = texto.substring(0, 40);
    final ultimoEspacio = recortado.lastIndexOf(' ');
    return ultimoEspacio > 0
        ? '${recortado.substring(0, ultimoEspacio)}...'
        : '$recortado...';
  }

  ConversationThread copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? lastMessageAt,
    bool? isPinned,
    ThreadStatus? status,
  }) =>
      ConversationThread(
        threadId: threadId,
        title: title ?? this.title,
        createdAt: createdAt,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        messages: messages ?? this.messages,
        isPinned: isPinned ?? this.isPinned,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'thread_id': threadId,
        'title': title,
        'created_at': createdAt.millisecondsSinceEpoch,
        'last_message_at': lastMessageAt.millisecondsSinceEpoch,
        'is_pinned': isPinned ? 1 : 0,
      };

  factory ConversationThread.fromMap(Map<String, dynamic> m) =>
      ConversationThread(
        threadId: m['thread_id'],
        title: m['title'],
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(m['created_at'] as int),
        lastMessageAt:
            DateTime.fromMillisecondsSinceEpoch(m['last_message_at'] as int),
        isPinned: (m['is_pinned'] as int) == 1,
      );
}