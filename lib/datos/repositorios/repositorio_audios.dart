import 'package:flutter/services.dart';
import 'dart:convert';
import '../../nucleo/constantes/constantes_app.dart';

/// Repositorio para gestionar los audios disponibles
class RepositorioAudios {
  // Cache de audios disponibles
  Set<String>? _audiosCacheados;

  /// Obtiene el conjunto de nombres de archivos de audio disponibles
  Future<Set<String>> obtenerAudiosDisponibles() async {
    if (_audiosCacheados != null) {
      return Set.from(_audiosCacheados!);
    }

    try {
      final contenidoManifest = await rootBundle.loadString(
        ConstantesApp.manifestAssets,
      );
      final Map<String, dynamic> mapaManifest = json.decode(contenidoManifest);

      final archivosAudio = mapaManifest.keys
          .where((String ruta) =>
              ruta.startsWith(ConstantesApp.rutaAudios) &&
              ruta.endsWith(ConstantesApp.extensionAudio))
          .toList();

      _audiosCacheados = archivosAudio
          .map((ruta) => ruta.split('/').last)
          .toSet();

      print('Audios disponibles cargados: ${_audiosCacheados!.length}');
      return Set.from(_audiosCacheados!);
    } catch (e) {
      print('Error cargando audios disponibles: $e');
      return <String>{};
    }
  }

  /// Busca la ruta del audio para un himno específico
  /// Retorna la ruta relativa al asset si existe, null en caso contrario
  String? buscarRutaAudio(
    int numeroHimno,
    String tituloHimno,
    Set<String> audiosDisponibles,
  ) {
    // Buscar por coincidencia de número al inicio del nombre
    for (String archivoAudio in audiosDisponibles) {
      if (_audioCoincideConHimno(archivoAudio, numeroHimno)) {
        return 'AUDIOS/$archivoAudio';
      }
    }

    return null;
  }

  /// Verifica si un archivo de audio corresponde a un himno
  bool _audioCoincideConHimno(String nombreArchivo, int numeroHimno) {
    // Verificar si empieza con el número del himno
    if (nombreArchivo.startsWith('$numeroHimno')) {
      return true;
    }

    // Verificar con número con ceros a la izquierda (e.g., 001, 002)
    final numeroConCeros = numeroHimno.toString().padLeft(3, '0');
    if (nombreArchivo.startsWith(numeroConCeros)) {
      return true;
    }

    return false;
  }

  /// Verifica si existe audio para un himno específico
  Future<bool> tieneAudioDisponible(int numeroHimno, String titulo) async {
    final audios = await obtenerAudiosDisponibles();
    return buscarRutaAudio(numeroHimno, titulo, audios) != null;
  }

  /// Invalida el caché de audios
  void invalidarCache() {
    _audiosCacheados = null;
  }

  /// Obtiene estadísticas de audios
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final audios = await obtenerAudiosDisponibles();
    return {
      'total': audios.length,
      'audios': audios.toList()..sort(),
    };
  }
}
