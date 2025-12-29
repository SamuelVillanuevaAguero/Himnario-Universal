import 'himno.dart';

/// Tipo de coincidencia en la búsqueda
enum TipoCoindicencia {
  numero,
  titulo,
  letra,
}

/// Modelo que representa un resultado de búsqueda de himnos
class ResultadoBusqueda {
  final Himno himno;
  final TipoCoindicencia? tipoCoindicencia;
  final String textoCoincidente;

  ResultadoBusqueda({
    required this.himno,
    this.tipoCoindicencia,
    this.textoCoincidente = '',
  });

  /// Obtiene una descripción legible del tipo de coincidencia
  String obtenerDescripcionCoindicencia() {
    if (tipoCoindicencia == null) return '';
    
    switch (tipoCoindicencia!) {
      case TipoCoindicencia.numero:
        return 'Coincidencia por número';
      case TipoCoindicencia.titulo:
        return 'Coincidencia en título';
      case TipoCoindicencia.letra:
        return textoCoincidente.isNotEmpty
            ? 'En la letra: "$textoCoincidente"'
            : 'Coincidencia en la letra';
    }
  }

  /// Obtiene el índice de prioridad para ordenamiento
  int get indicePrioridad => tipoCoindicencia?.index ?? 999;

  @override
  String toString() {
    return 'ResultadoBusqueda{himno: ${himno.numero}, tipo: $tipoCoindicencia}';
  }
}
