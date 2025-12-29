/// Modelo que representa un himno del himnario
class Himno {
  final int numero;
  final String titulo;
  final String tipo;
  final String tonoSugerido;
  final String letra;
  final String nombreArchivo;
  final String? rutaAudio;
  bool esFavorito;

  Himno({
    required this.numero,
    required this.titulo,
    required this.tipo,
    required this.tonoSugerido,
    required this.letra,
    required this.nombreArchivo,
    this.rutaAudio,
    this.esFavorito = false,
  });

  /// Crea una copia del himno con los campos especificados modificados
  Himno copiarCon({
    int? numero,
    String? titulo,
    String? tipo,
    String? tonoSugerido,
    String? letra,
    String? nombreArchivo,
    String? rutaAudio,
    bool? esFavorito,
  }) {
    return Himno(
      numero: numero ?? this.numero,
      titulo: titulo ?? this.titulo,
      tipo: tipo ?? this.tipo,
      tonoSugerido: tonoSugerido ?? this.tonoSugerido,
      letra: letra ?? this.letra,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
      rutaAudio: rutaAudio ?? this.rutaAudio,
      esFavorito: esFavorito ?? this.esFavorito,
    );
  }

  /// Verifica si el himno tiene audio disponible
  bool get tieneAudio => rutaAudio != null && rutaAudio!.isNotEmpty;

  @override
  String toString() {
    return 'Himno{numero: $numero, titulo: $titulo, tieneAudio: $tieneAudio, esFavorito: $esFavorito}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Himno &&
          runtimeType == other.runtimeType &&
          numero == other.numero;

  @override
  int get hashCode => numero.hashCode;
}
