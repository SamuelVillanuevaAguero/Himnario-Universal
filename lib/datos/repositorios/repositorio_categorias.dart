import 'package:flutter/services.dart';
import 'dart:convert';
import '../modelos/categoria.dart';
import '../modelos/himno.dart';
import '../../nucleo/constantes/constantes_app.dart';
import '../../nucleo/utilidades/normalizador_texto.dart';

/// Repositorio para gestionar las categorías de himnos
class RepositorioCategorias {
  // Cache de categorías en memoria
  List<Categoria>? _categoriasCacheadas;

  /// Obtiene todas las categorías disponibles
  Future<List<Categoria>> obtenerTodasCategorias() async {
    if (_categoriasCacheadas != null) {
      return List.from(_categoriasCacheadas!);
    }

    try {
      final categorias = await _cargarCategoriasDesdeAssets();
      _categoriasCacheadas = categorias;
      return List.from(categorias);
    } catch (e) {
      print('Error al obtener categorías: $e');
      throw Exception('No se pudieron cargar las categorías: $e');
    }
  }

  /// Busca categorías por nombre
  Future<List<Categoria>> buscarCategorias(String termino) async {
    if (termino.isEmpty) {
      return obtenerTodasCategorias();
    }

    final categorias = await obtenerTodasCategorias();
    final terminoNormalizado = NormalizadorTexto.normalizar(termino);

    final categoriasFiltradas = categorias.where((categoria) {
      final nombreNormalizado = NormalizadorTexto.normalizar(categoria.nombre);
      return nombreNormalizado.contains(terminoNormalizado);
    }).toList();

    // Ordenar por relevancia: primero las que empiezan con el término
    categoriasFiltradas.sort((a, b) {
      final aNormalizado = NormalizadorTexto.normalizar(a.nombre);
      final bNormalizado = NormalizadorTexto.normalizar(b.nombre);

      final aEmpieza = aNormalizado.startsWith(terminoNormalizado);
      final bEmpieza = bNormalizado.startsWith(terminoNormalizado);

      if (aEmpieza && !bEmpieza) return -1;
      if (!aEmpieza && bEmpieza) return 1;

      return aNormalizado.compareTo(bNormalizado);
    });

    return categoriasFiltradas;
  }

  /// Obtiene una categoría por su nombre
  Future<Categoria?> obtenerCategoriaPorNombre(String nombre) async {
    final categorias = await obtenerTodasCategorias();
    try {
      return categorias.firstWhere((cat) => cat.nombre == nombre);
    } catch (e) {
      return null;
    }
  }

  /// Filtra himnos que pertenecen a una categoría específica
  List<Himno> filtrarHimnosPorCategoria(
    List<Himno> himnos,
    Categoria categoria,
  ) {
    final himnosFiltrados = himnos
        .where((himno) => categoria.contieneHimno(himno.numero))
        .toList();

    // Ordenar según el orden de la categoría
    himnosFiltrados.sort((a, b) {
      final indiceA = categoria.obtenerPosicionHimno(a.numero);
      final indiceB = categoria.obtenerPosicionHimno(b.numero);
      return indiceA.compareTo(indiceB);
    });

    return himnosFiltrados;
  }

  /// Obtiene estadísticas de las categorías
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final categorias = await obtenerTodasCategorias();
    
    int totalHimnos = 0;
    int himnoPorCategoriaMin = 999999;
    int himnoPorCategoriaMax = 0;

    for (final categoria in categorias) {
      totalHimnos += categoria.cantidadHimnos;
      if (categoria.cantidadHimnos < himnoPorCategoriaMin) {
        himnoPorCategoriaMin = categoria.cantidadHimnos;
      }
      if (categoria.cantidadHimnos > himnoPorCategoriaMax) {
        himnoPorCategoriaMax = categoria.cantidadHimnos;
      }
    }

    final promedio = categorias.isNotEmpty 
        ? (totalHimnos / categorias.length).round()
        : 0;

    return {
      'totalCategorias': categorias.length,
      'totalHimnos': totalHimnos,
      'promedioHimnosPorCategoria': promedio,
      'minHimnosPorCategoria': himnoPorCategoriaMin,
      'maxHimnosPorCategoria': himnoPorCategoriaMax,
    };
  }

  /// Invalida el caché forzando una recarga
  void invalidarCache() {
    _categoriasCacheadas = null;
  }

  // ========== MÉTODOS PRIVADOS ==========

  /// Carga todas las categorías desde los assets
  Future<List<Categoria>> _cargarCategoriasDesdeAssets() async {
    try {
      final contenidoManifest = await rootBundle.loadString(
        ConstantesApp.manifestAssets,
      );
      final Map<String, dynamic> mapaManifest = json.decode(contenidoManifest);

      final archivosCategorias = mapaManifest.keys
          .where((String ruta) =>
              ruta.startsWith(ConstantesApp.rutaCategorias) &&
              ruta.endsWith(ConstantesApp.extensionTexto))
          .toList();

      final List<Categoria> categoriasCargadas = [];

      for (String rutaArchivo in archivosCategorias) {
        try {
          final contenido = await rootBundle.loadString(rutaArchivo);
          final categoria = _parsearArchivoCategoria(contenido, rutaArchivo);
          
          if (categoria != null) {
            categoriasCargadas.add(categoria);
          }
        } catch (e) {
          print('Error cargando archivo categoría $rutaArchivo: $e');
        }
      }

      // Ordenar alfabéticamente
      categoriasCargadas.sort((a, b) => a.nombre.compareTo(b.nombre));

      print('Categorías cargadas exitosamente: ${categoriasCargadas.length}');
      return categoriasCargadas;
    } catch (e) {
      print('Error en _cargarCategoriasDesdeAssets: $e');
      rethrow;
    }
  }

  /// Parsea el contenido de un archivo de categoría
  Categoria? _parsearArchivoCategoria(String contenido, String rutaArchivo) {
    try {
      final lineas = contenido.split('\n');
      final nombreArchivo = rutaArchivo.split('/').last;

      // El nombre de la categoría es el nombre del archivo sin extensión
      final nombreCategoria = nombreArchivo.replaceAll(
        ConstantesApp.extensionTexto,
        '',
      );

      // Parsear los números de himnos
      final List<int> numerosHimnos = [];

      for (String linea in lineas) {
        final lineaLimpia = linea.trim();
        if (lineaLimpia.isNotEmpty) {
          // Buscar todos los números en la línea
          final coincidenciasNumeros = RegExp(r'\d+').allMatches(lineaLimpia);
          for (RegExpMatch coincidencia in coincidenciasNumeros) {
            final numero = int.tryParse(coincidencia.group(0)!);
            if (numero != null && !numerosHimnos.contains(numero)) {
              numerosHimnos.add(numero);
            }
          }
        }
      }

      if (numerosHimnos.isEmpty) {
        print('No se encontraron números de himnos en: $rutaArchivo');
        return null;
      }

      return Categoria(
        nombre: nombreCategoria,
        nombreArchivo: nombreArchivo,
        numerosHimnos: numerosHimnos,
      );
    } catch (e) {
      print('Error parseando archivo categoría $rutaArchivo: $e');
      return null;
    }
  }
}
