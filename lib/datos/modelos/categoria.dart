/// Modelo que representa una categoría de himnos
class Categoria {
  final String nombre;
  final String nombreArchivo;
  final List<int> numerosHimnos;
  final int cantidadHimnos;

  Categoria({
    required this.nombre,
    required this.nombreArchivo,
    required this.numerosHimnos,
  }) : cantidadHimnos = numerosHimnos.length;

  /// Verifica si la categoría contiene un himno específico
  bool contieneHimno(int numeroHimno) {
    return numerosHimnos.contains(numeroHimno);
  }

  /// Obtiene la posición de un himno en la categoría
  int obtenerPosicionHimno(int numeroHimno) {
    return numerosHimnos.indexOf(numeroHimno);
  }

  @override
  String toString() {
    return 'Categoria{nombre: $nombre, nombreArchivo: $nombreArchivo, cantidadHimnos: $cantidadHimnos}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Categoria &&
          runtimeType == other.runtimeType &&
          nombre == other.nombre &&
          nombreArchivo == other.nombreArchivo;

  @override
  int get hashCode => nombre.hashCode ^ nombreArchivo.hashCode;
}
