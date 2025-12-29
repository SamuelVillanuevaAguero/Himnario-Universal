import 'package:flutter/services.dart';
import 'dart:convert';
import '../modelos/himno.dart';
import '../modelos/resultado_busqueda.dart';
import '../../nucleo/constantes/constantes_app.dart';
import '../../nucleo/utilidades/normalizador_texto.dart';
import 'repositorio_audios.dart';

/// Repositorio para gestionar los himnos
/// Centraliza toda la lógica de carga y búsqueda de himnos
class RepositorioHimnos {
  final RepositorioAudios _repositorioAudios;
  
  // Cache de himnos en memoria
  List<Himno>? _himnosCacheados;
  
  RepositorioHimnos({
    required RepositorioAudios repositorioAudios,
  }) : _repositorioAudios = repositorioAudios;

  /// Obtiene todos los himnos disponibles
  /// Utiliza caché si está disponible
  Future<List<Himno>> obtenerTodosLosHimnos() async {
    if (_himnosCacheados != null) {
      return List.from(_himnosCacheados!);
    }

    try {
      final himnos = await _cargarHimnosDesdeAssets();
      _himnosCacheados = himnos;
      return List.from(himnos);
    } catch (e) {
      print('Error al obtener himnos: $e');
      throw Exception('No se pudieron cargar los himnos: $e');
    }
  }

  /// Obtiene un himno por su número
  Future<Himno?> obtenerHimnoPorNumero(int numero) async {
    final himnos = await obtenerTodosLosHimnos();
    try {
      return himnos.firstWhere((himno) => himno.numero == numero);
    } catch (e) {
      return null;
    }
  }

  /// Busca himnos según un término de búsqueda
  /// Retorna una lista de ResultadoBusqueda ordenada por relevancia
  Future<List<ResultadoBusqueda>> buscarHimnos(String termino) async {
    if (termino.isEmpty) {
      final himnos = await obtenerTodosLosHimnos();
      return himnos.map((h) => ResultadoBusqueda(himno: h)).toList();
    }

    final himnos = await obtenerTodosLosHimnos();
    final List<ResultadoBusqueda> resultados = [];

    for (final himno in himnos) {
      TipoCoindicencia? tipoCoindicencia;
      String textoCoincidente = '';

      // Buscar por número
      if (himno.numero.toString().contains(termino.trim())) {
        tipoCoindicencia = TipoCoindicencia.numero;
        textoCoincidente = 'Himno #${himno.numero}';
      }
      // Buscar por título
      else if (NormalizadorTexto.contieneIgnorandoDiacriticos(
          himno.titulo, termino)) {
        tipoCoindicencia = TipoCoindicencia.titulo;
        textoCoincidente = himno.titulo;
      }
      // Buscar en las letras
      else if (NormalizadorTexto.contieneIgnorandoDiacriticos(
          himno.letra, termino)) {
        tipoCoindicencia = TipoCoindicencia.letra;
        textoCoincidente = _encontrarLineaCoincidente(himno.letra, termino);
      }

      if (tipoCoindicencia != null) {
        resultados.add(ResultadoBusqueda(
          himno: himno,
          tipoCoindicencia: tipoCoindicencia,
          textoCoincidente: textoCoincidente,
        ));
      }
    }

    // Ordenar por relevancia
    resultados.sort((a, b) {
      if (a.indicePrioridad != b.indicePrioridad) {
        return a.indicePrioridad.compareTo(b.indicePrioridad);
      }
      return a.himno.numero.compareTo(b.himno.numero);
    });

    return resultados;
  }

  /// Obtiene himnos por una lista de números
  Future<List<Himno>> obtenerHimnosPorNumeros(List<int> numeros) async {
    final todosHimnos = await obtenerTodosLosHimnos();
    return todosHimnos
        .where((himno) => numeros.contains(himno.numero))
        .toList();
  }

  /// Invalida el caché forzando una recarga en la próxima petición
  void invalidarCache() {
    _himnosCacheados = null;
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Carga todos los himnos desde los assets
  Future<List<Himno>> _cargarHimnosDesdeAssets() async {
    try {
      final contenidoManifest = await rootBundle.loadString(
        ConstantesApp.manifestAssets,
      );
      final Map<String, dynamic> mapaManifest = json.decode(contenidoManifest);

      final archivosHimnos = mapaManifest.keys
          .where((String ruta) =>
              ruta.startsWith(ConstantesApp.rutaHimnos) &&
              ruta.endsWith(ConstantesApp.extensionTexto))
          .toList();

      final List<Himno> himnosCargados = [];
      final audiosDisponibles = await _repositorioAudios.obtenerAudiosDisponibles();

      for (String rutaArchivo in archivosHimnos) {
        try {
          final contenido = await rootBundle.loadString(rutaArchivo);
          final himno = _parsearArchivoHimno(
            contenido,
            rutaArchivo,
            audiosDisponibles,
          );
          
          if (himno != null) {
            himnosCargados.add(himno);
          }
        } catch (e) {
          print('Error cargando archivo $rutaArchivo: $e');
        }
      }

      // Ordenar por número
      himnosCargados.sort((a, b) => a.numero.compareTo(b.numero));

      print('Himnos cargados exitosamente: ${himnosCargados.length}');
      return himnosCargados;
    } catch (e) {
      print('Error en _cargarHimnosDesdeAssets: $e');
      rethrow;
    }
  }

  /// Parsea el contenido de un archivo de himno
  Himno? _parsearArchivoHimno(
    String contenido,
    String rutaArchivo,
    Set<String> audiosDisponibles,
  ) {
    try {
      final lineas = contenido.split('\n');

      if (lineas.length < 5) {
        print('Archivo $rutaArchivo tiene líneas insuficientes');
        return null;
      }

      final titulo = lineas[0].trim();
      final tonoSugerido = lineas.length > 2 ? lineas[2].trim() : '';
      final lineasLetra = lineas.skip(4).toList();
      final letra = lineasLetra.join('\n').trim();

      final nombreArchivo = rutaArchivo.split('/').last;
      final coincidenciaNumero = RegExp(r'\d+').firstMatch(nombreArchivo);
      final numero = coincidenciaNumero != null
          ? int.parse(coincidenciaNumero.group(0)!)
          : 0;

      final rutaAudio = _repositorioAudios.buscarRutaAudio(
        numero,
        titulo,
        audiosDisponibles,
      );

      return Himno(
        numero: numero,
        titulo: titulo,
        tipo: '',
        tonoSugerido: tonoSugerido,
        letra: letra,
        nombreArchivo: nombreArchivo,
        rutaAudio: rutaAudio,
        esFavorito: false,
      );
    } catch (e) {
      print('Error parseando archivo $rutaArchivo: $e');
      return null;
    }
  }

  /// Encuentra una línea que coincide con el término de búsqueda
  String _encontrarLineaCoincidente(String letra, String termino) {
    final lineas = letra.split('\n');
    final terminoNormalizado = NormalizadorTexto.normalizar(termino);

    for (final linea in lineas) {
      final lineaNormalizada = NormalizadorTexto.normalizar(linea);
      if (lineaNormalizada.contains(terminoNormalizado) &&
          linea.trim().isNotEmpty) {
        return linea.trim();
      }
    }
    return '';
  }
}
