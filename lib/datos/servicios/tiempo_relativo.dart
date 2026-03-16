import 'package:intl/intl.dart';

/// Formatea una fecha como tiempo relativo en español
class TiempoRelativo {
  static String formatear(DateTime fecha) {
    final ahora = DateTime.now();
    final diff = ahora.difference(fecha);

    if (diff.inSeconds < 60) return 'Ahora mismo';
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} ${diff.inMinutes == 1 ? 'minuto' : 'minutos'}';
    }
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
    }
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    if (diff.inDays < 30) {
      final semanas = (diff.inDays / 7).floor();
      return 'Hace $semanas ${semanas == 1 ? 'semana' : 'semanas'}';
    }
    return DateFormat('d MMM yyyy', 'es').format(fecha);
  }
}