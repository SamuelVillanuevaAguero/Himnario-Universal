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
  static const String tituloAcercaDe = 'Acerca de';

  // Navegación
  static const String labelNavHimnos = 'Himnos';
  static const String labelNavFavoritos = 'Favoritos';
  static const String labelNavCategorias = 'Categorías';
  static const String labelNavAcercaDe = 'Acerca de';

  // Información de la aplicación
  static const String nombreApp = 'Himnario Universal';
  static const String versionApp = '1.0.0';
  static const String fechaActualizacion = 'Diciembre 2024';
  static const String descripcionApp = 
      'Himnario Universal es una aplicación móvil diseñada para llevar la alabanza '
      'y adoración a donde quiera que vayas, esta app te permite acceder fácilmente a las letras, escuchar '
      'los audios disponibles y organizar tus himnos favoritos.';
  static const String propostoApp =
      'El propósito de esta aplicación es solo ser una herramienta de apoyo, '
      'pedimos encarecidamente que no sea utilizada como sustituto del himnario fisico de la iglesia universal.';
  static const String telefonoContacto = '+52 734 155 3474';

  // Versículo del carrusel
  static const String versiculoTexto =
      'Así que, ofrezcamos siempre a Dios, por medio de él, sacrificio de alabanza, es decir, fruto de labios que confiesan su nombre';
  static const String versiculoReferencia = 'Hebreos 13:15';

  /// No permitir instanciación
  ConstantesApp._();
}