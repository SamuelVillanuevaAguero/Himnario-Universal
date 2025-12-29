/// Constantes de la aplicación
class ConstantesApp {
  // Rutas de assets
  static const String rutaHimnos = 'assets/HIMNOS/';
  static const String rutaAudios = 'assets/AUDIOS/';
  static const String rutaCategorias = 'assets/CATEGORIAS/';
  static const String rutaImagenes = 'assets/imagenes/';
  static const String manifestAssets = 'AssetManifest.json';

  // Extensiones de archivo
  static const String extensionTexto = '.txt';
  static const String extensionAudio = '.mp3';
  static const List<String> extensionesImagen = ['.jpg', '.jpeg', '.png'];

  // Configuración de audio
  static const int duracionCarruselSegundos = 5;
  static const int duracionSnackbarSegundos = 2;

  // Tamaños de fuente
  static const double tamanioFuenteMinimo = 12.0;
  static const double tamanioFuenteMaximo = 28.0;
  static const double tamanioFuentePorDefecto = 18.0;
  static const double incrementoFuente = 2.0;

  // Configuración de UI
  static const double alturaCarrusel = 280.0;
  static const double espaciadoVertical = 20.0;
  static const double espaciadoHorizontal = 20.0;
  static const double bordeRadiusTarjeta = 15.0;
  static const double bordeRadiusBusqueda = 25.0;

  // Claves de SharedPreferences
  static const String claveFavoritos = 'hymn_favorites';

  // Mensajes
  static const String mensajeHimnoAgregadoFavoritos = 'Himno agregado a favoritos';
  static const String mensajeHimnoRemovidoFavoritos = 'Himno removido de favoritos';
  static const String mensajeErrorActualizarFavoritos = 'Error al actualizar favoritos';
  static const String mensajeAudioNoDisponible = 'Audio no disponible para este himno';
  static const String mensajeErrorReproducirAudio = 'Error al reproducir el audio';

  // Textos de UI
  static const String textoCargandoHimnos = 'Cargando himnos...';
  static const String textoCargandoCategorias = 'Cargando categorías...';
  static const String textoCargandoFavoritos = 'Cargando favoritos...';
  static const String textoNoHimnosEncontrados = 'No se encontraron himnos';
  static const String textoNoCategoriasEncontradas = 'No se encontraron categorías';
  static const String textoNoResultadosBusqueda = 'No se encontraron resultados';
  static const String textoAudioDisponible = 'Audio disponible';

  // Hints de búsqueda
  static const String hintBusquedaHimnos = 'Buscar por título, número o letra...';
  static const String hintBusquedaCategorias = 'Buscar categorías...';

  // Títulos de pantallas
  static const String tituloInicio = 'Himnos | Universal';
  static const String tituloFavoritos = 'Mis Favoritos';
  static const String tituloCategorias = 'Categorías';

  // Navegación
  static const String labelNavHimnos = 'Himnos';
  static const String labelNavFavoritos = 'Favoritos';
  static const String labelNavCategorias = 'Categorías';

  // Versículo del carrusel
  static const String versiculoTexto =
      'Así que, ofrezcamos siempre a Dios, por medio de él, sacrificio de alabanza, es decir, fruto de labios que confiesan su nombre';
  static const String versiculoReferencia = 'Hebreos 13:15';

  /// No permitir instanciación
  ConstantesApp._();
}
