import 'package:flutter/foundation.dart';
import '../../datos/modelos/categoria.dart';
import '../../datos/modelos/himno.dart';
import '../../datos/repositorios/repositorio_categorias.dart';
import '../../datos/repositorios/repositorio_himnos.dart';

/// Estados de carga
enum EstadoCargaCategorias {
  inicial,
  cargando,
  cargado,
  error,
}

/// Provider para gestionar el estado de las categorías
class ProviderCategorias extends ChangeNotifier {
  final RepositorioCategorias _repositorioCategorias;
  final RepositorioHimnos _repositorioHimnos;

  // Estado
  EstadoCargaCategorias _estado = EstadoCargaCategorias.inicial;
  List<Categoria> _todasCategorias = [];
  List<Categoria> _categoriasFiltradas = [];
  String _terminoBusqueda = '';
  String? _mensajeError;

  ProviderCategorias({
    required RepositorioCategorias repositorioCategorias,
    required RepositorioHimnos repositorioHimnos,
  })  : _repositorioCategorias = repositorioCategorias,
        _repositorioHimnos = repositorioHimnos;

  // Getters
  EstadoCargaCategorias get estado => _estado;
  List<Categoria> get todasCategorias => List.unmodifiable(_todasCategorias);
  List<Categoria> get categoriasFiltradas => List.unmodifiable(_categoriasFiltradas);
  String get terminoBusqueda => _terminoBusqueda;
  String? get mensajeError => _mensajeError;
  bool get estaCargando => _estado == EstadoCargaCategorias.cargando;
  bool get tieneError => _estado == EstadoCargaCategorias.error;
  bool get estaCargado => _estado == EstadoCargaCategorias.cargado;

  /// Inicializa cargando las categorías
  Future<void> inicializar() async {
    if (_estado == EstadoCargaCategorias.cargado) return;

    _cambiarEstado(EstadoCargaCategorias.cargando);

    try {
      _todasCategorias = await _repositorioCategorias.obtenerTodasCategorias();
      _categoriasFiltradas = List.from(_todasCategorias);
      _cambiarEstado(EstadoCargaCategorias.cargado);
    } catch (e) {
      _mensajeError = 'Error al cargar categorías: $e';
      _cambiarEstado(EstadoCargaCategorias.error);
      print('Error en inicializar categorías: $e');
    }
  }

  /// Busca categorías según un término
  Future<void> buscar(String termino) async {
    _terminoBusqueda = termino;

    if (!estaCargado) {
      await inicializar();
    }

    try {
      _categoriasFiltradas = await _repositorioCategorias.buscarCategorias(termino);
      notifyListeners();
    } catch (e) {
      print('Error al buscar categorías: $e');
    }
  }

  /// Limpia la búsqueda actual
  void limpiarBusqueda() {
    _terminoBusqueda = '';
    _categoriasFiltradas = List.from(_todasCategorias);
    notifyListeners();
  }

  /// Obtiene los himnos de una categoría específica
  Future<List<Himno>> obtenerHimnosCategoria(Categoria categoria) async {
    try {
      final todosHimnos = await _repositorioHimnos.obtenerTodosLosHimnos();
      return _repositorioCategorias.filtrarHimnosPorCategoria(
        todosHimnos,
        categoria,
      );
    } catch (e) {
      print('Error al obtener himnos de categoría: $e');
      return [];
    }
  }

  /// Recarga todas las categorías
  Future<void> recargar() async {
    _repositorioCategorias.invalidarCache();
    _estado = EstadoCargaCategorias.inicial;
    await inicializar();
  }

  void _cambiarEstado(EstadoCargaCategorias nuevoEstado) {
    _estado = nuevoEstado;
    notifyListeners();
  }
}
