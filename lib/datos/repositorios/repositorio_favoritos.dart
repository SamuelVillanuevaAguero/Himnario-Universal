import 'package:shared_preferences/shared_preferences.dart';
import '../../nucleo/constantes/constantes_app.dart';

/// Repositorio para gestionar los himnos favoritos
/// Utiliza SharedPreferences para persistencia local
class RepositorioFavoritos {
  // Cache en memoria de favoritos
  Set<int>? _favoritosCacheados;

  /// Carga los números de himnos marcados como favoritos
  Future<Set<int>> cargarFavoritos() async {
    if (_favoritosCacheados != null) {
      return Set.from(_favoritosCacheados!);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritosJson = prefs.getStringList(ConstantesApp.claveFavoritos) ?? [];
      _favoritosCacheados = favoritosJson.map((e) => int.parse(e)).toSet();
      
      print('Favoritos cargados: ${_favoritosCacheados!.length}');
      return Set.from(_favoritosCacheados!);
    } catch (e) {
      print('Error cargando favoritos: $e');
      return <int>{};
    }
  }

  /// Guarda el conjunto de favoritos
  Future<void> guardarFavoritos(Set<int> favoritos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritosJson = favoritos.map((e) => e.toString()).toList();
      await prefs.setStringList(ConstantesApp.claveFavoritos, favoritosJson);
      
      // Actualizar cache
      _favoritosCacheados = Set.from(favoritos);
      
      print('Favoritos guardados: ${favoritos.length}');
    } catch (e) {
      print('Error guardando favoritos: $e');
      rethrow;
    }
  }

  /// Agrega un himno a favoritos
  Future<void> agregarFavorito(int numeroHimno) async {
    final favoritos = await cargarFavoritos();
    favoritos.add(numeroHimno);
    await guardarFavoritos(favoritos);
  }

  /// Remueve un himno de favoritos
  Future<void> removerFavorito(int numeroHimno) async {
    final favoritos = await cargarFavoritos();
    favoritos.remove(numeroHimno);
    await guardarFavoritos(favoritos);
  }

  /// Verifica si un himno es favorito
  Future<bool> esFavorito(int numeroHimno) async {
    final favoritos = await cargarFavoritos();
    return favoritos.contains(numeroHimno);
  }

  /// Alterna el estado de favorito de un himno
  /// Retorna true si ahora es favorito, false si no
  Future<bool> alternarFavorito(int numeroHimno) async {
    final favoritos = await cargarFavoritos();
    final eraFavorito = favoritos.contains(numeroHimno);

    if (eraFavorito) {
      favoritos.remove(numeroHimno);
    } else {
      favoritos.add(numeroHimno);
    }

    await guardarFavoritos(favoritos);
    return !eraFavorito;
  }

  /// Obtiene la cantidad total de favoritos
  Future<int> obtenerCantidadFavoritos() async {
    final favoritos = await cargarFavoritos();
    return favoritos.length;
  }

  /// Limpia todos los favoritos
  Future<void> limpiarTodosFavoritos() async {
    await guardarFavoritos(<int>{});
  }

  /// Invalida el caché de favoritos
  void invalidarCache() {
    _favoritosCacheados = null;
  }

  /// Obtiene estadísticas de favoritos
  Future<Map<String, dynamic>> obtenerEstadisticas() async {
    final favoritos = await cargarFavoritos();
    return {
      'total': favoritos.length,
      'numeros': favoritos.toList()..sort(),
    };
  }

  /// Exporta los favoritos como lista ordenada
  Future<List<int>> exportarFavoritos() async {
    final favoritos = await cargarFavoritos();
    final lista = favoritos.toList();
    lista.sort();
    return lista;
  }

  /// Importa favoritos desde una lista
  Future<void> importarFavoritos(List<int> numeros) async {
    await guardarFavoritos(numeros.toSet());
  }
}
