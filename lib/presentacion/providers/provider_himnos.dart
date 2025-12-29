import 'package:flutter/foundation.dart';
import '../../datos/modelos/himno.dart';
import '../../datos/modelos/resultado_busqueda.dart';
import '../../datos/repositorios/repositorio_himnos.dart';
import '../../datos/repositorios/repositorio_favoritos.dart';

/// Estado de carga de datos
enum EstadoCarga {
  inicial,
  cargando,
  cargado,
  error,
}

/// Provider para gestionar el estado de los himnos
class ProviderHimnos extends ChangeNotifier {
  final RepositorioHimnos _repositorioHimnos;
  final RepositorioFavoritos _repositorioFavoritos;

  // Estado
  EstadoCarga _estado = EstadoCarga.inicial;
  List<Himno> _todosLosHimnos = [];
  List<ResultadoBusqueda> _resultadosBusqueda = [];
  String _terminoBusqueda = '';
  String? _mensajeError;
  Set<int> _numerosFavoritos = {};

  ProviderHimnos({
    required RepositorioHimnos repositorioHimnos,
    required RepositorioFavoritos repositorioFavoritos,
  })  : _repositorioHimnos = repositorioHimnos,
        _repositorioFavoritos = repositorioFavoritos;

  // Getters
  EstadoCarga get estado => _estado;
  List<Himno> get todosLosHimnos => List.unmodifiable(_todosLosHimnos);
  List<ResultadoBusqueda> get resultadosBusqueda =>
      List.unmodifiable(_resultadosBusqueda);
  String get terminoBusqueda => _terminoBusqueda;
  String? get mensajeError => _mensajeError;
  bool get estaCargando => _estado == EstadoCarga.cargando;
  bool get tieneError => _estado == EstadoCarga.error;
  bool get estaCargado => _estado == EstadoCarga.cargado;

  /// Inicializa cargando himnos y favoritos
  Future<void> inicializar() async {
    if (_estado == EstadoCarga.cargado) return;

    _cambiarEstado(EstadoCarga.cargando);

    try {
      // Cargar favoritos primero
      _numerosFavoritos = await _repositorioFavoritos.cargarFavoritos();

      // Cargar himnos
      _todosLosHimnos = await _repositorioHimnos.obtenerTodosLosHimnos();

      // Aplicar estado de favoritos
      _aplicarFavoritos();

      // Inicializar resultados de búsqueda con todos los himnos
      _resultadosBusqueda = _todosLosHimnos
          .map((h) => ResultadoBusqueda(himno: h))
          .toList();

      _cambiarEstado(EstadoCarga.cargado);
    } catch (e) {
      _mensajeError = 'Error al cargar himnos: $e';
      _cambiarEstado(EstadoCarga.error);
      print('Error en inicializar: $e');
    }
  }

  /// Busca himnos según un término
  Future<void> buscar(String termino) async {
    _terminoBusqueda = termino;

    if (!estaCargado) {
      await inicializar();
    }

    try {
      _resultadosBusqueda = await _repositorioHimnos.buscarHimnos(termino);
      notifyListeners();
    } catch (e) {
      print('Error al buscar: $e');
    }
  }

  /// Limpia la búsqueda actual
  void limpiarBusqueda() {
    _terminoBusqueda = '';
    _resultadosBusqueda = _todosLosHimnos
        .map((h) => ResultadoBusqueda(himno: h))
        .toList();
    notifyListeners();
  }

  /// Alterna el estado de favorito de un himno
  Future<bool> alternarFavorito(int numeroHimno) async {
    try {
      final nuevoEstado = await _repositorioFavoritos.alternarFavorito(
        numeroHimno,
      );

      if (nuevoEstado) {
        _numerosFavoritos.add(numeroHimno);
      } else {
        _numerosFavoritos.remove(numeroHimno);
      }

      _aplicarFavoritos();
      notifyListeners();

      return nuevoEstado;
    } catch (e) {
      print('Error al alternar favorito: $e');
      rethrow;
    }
  }

  /// Obtiene un himno por su número
  Himno? obtenerHimnoPorNumero(int numero) {
    try {
      return _todosLosHimnos.firstWhere((h) => h.numero == numero);
    } catch (e) {
      return null;
    }
  }

  /// Recarga todos los datos
  Future<void> recargar() async {
    _repositorioHimnos.invalidarCache();
    _repositorioFavoritos.invalidarCache();
    _estado = EstadoCarga.inicial;
    await inicializar();
  }

  // ========== MÉTODOS PRIVADOS ==========

  void _cambiarEstado(EstadoCarga nuevoEstado) {
    _estado = nuevoEstado;
    notifyListeners();
  }

  void _aplicarFavoritos() {
    for (final himno in _todosLosHimnos) {
      himno.esFavorito = _numerosFavoritos.contains(himno.numero);
    }
    for (final resultado in _resultadosBusqueda) {
      resultado.himno.esFavorito = _numerosFavoritos.contains(
        resultado.himno.numero,
      );
    }
  }
}
