/// Utilidad para formatear duraciones de tiempo
class FormateadorDuracion {
  /// Formatea una duración en formato MM:SS
  /// 
  /// Ejemplo:
  /// ```dart
  /// final duracion = Duration(minutes: 3, seconds: 45);
  /// FormateadorDuracion.formatearMMSS(duracion) // retorna "03:45"
  /// ```
  static String formatearMMSS(Duration duracion) {
    String dosDigitos(int n) => n.toString().padLeft(2, '0');
    final minutos = dosDigitos(duracion.inMinutes.remainder(60));
    final segundos = dosDigitos(duracion.inSeconds.remainder(60));
    return '$minutos:$segundos';
  }

  /// Formatea una duración en formato HH:MM:SS si tiene horas
  static String formatearCompleto(Duration duracion) {
    if (duracion.inHours > 0) {
      String dosDigitos(int n) => n.toString().padLeft(2, '0');
      final horas = dosDigitos(duracion.inHours);
      final minutos = dosDigitos(duracion.inMinutes.remainder(60));
      final segundos = dosDigitos(duracion.inSeconds.remainder(60));
      return '$horas:$minutos:$segundos';
    }
    return formatearMMSS(duracion);
  }

  /// Convierte milisegundos a Duration
  static Duration desdeMilisegundos(int milisegundos) {
    return Duration(milliseconds: milisegundos);
  }

  /// Convierte segundos a Duration
  static Duration desdeSegundos(int segundos) {
    return Duration(seconds: segundos);
  }
}
