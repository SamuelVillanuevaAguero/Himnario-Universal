// Stub vacío para web — nunca se llama porque db_hilos.dart
// desvía todo a la implementación SharedPreferences cuando kIsWeb == true.
// Existe solo para que el compilador web no intente importar sqflite.
import '../modelos/modelos_chat.dart';

Future<List<ConversationThread>> listarHilos() async => [];
Future<void> insertarHilo(ConversationThread hilo) async {}
Future<void> actualizarHilo(ConversationThread hilo) async {}
Future<void> eliminarHilo(String threadId) async {}
Future<List<ChatMessage>> cargarMensajes(String threadId) async => [];
Future<void> insertarMensaje(String threadId, ChatMessage m) async {}
Future<void> reemplazarMensajes(
    String threadId, List<ChatMessage> ms) async {}
Future<int> contarMensajes(String threadId) async => 0;