import 'package:flutter/material.dart';

/// Clase centralizada de colores de la aplicación
/// Soporta temas claro y oscuro
class ColoresApp {
  // ========== COLORES PRIMARIOS ==========
  static const Color primario = Color(0xFF2196F3);
  static const Color primarioOscuro = Color(0xFF1976D2);
  static const Color primarioClaro = Color(0xFF64B5F6);

  // ========== COLORES DE FONDO ==========
  static const Color fondoPrimario = Color(0xFFF1F4F8);
  static const Color fondoSecundario = Colors.white;
  static const Color fondoOscuro = Colors.black;
  static const Color fondoTarjeta = Color(0xFF212121);
  static const Color fondoControlAudio = Color(0xFF424242);

  // ========== COLORES DE TEXTO ==========
  static const Color textoPrimario = Color.fromARGB(221, 88, 88, 88);
  static const Color textoSecundario = Color(0xFF757575);
  static const Color textoTerciario = Color(0xFF9E9E9E);
  static const Color textoBlanco = Colors.white;
  static const Color textoBlancoSecundario = Color(0xE6FFFFFF);
  static const Color textoBlancoTerciario = Color(0xB3FFFFFF);

  // ========== COLORES DE ESTADO ==========
  static const Color exito = Colors.green;
  static const Color error = Colors.red;
  static const Color advertencia = Colors.orange;
  static const Color informacion = Colors.blue;

  // ========== COLORES FUNCIONALES ==========
  static const Color favorito = Colors.red;
  static const Color favoritoInactivo = Color(0xFFBDBDBD);
  static const Color audioDisponible = Colors.green;
  static const Color audioNoDisponible = Color(0xFFBDBDBD);
  static const Color notaMusical = Colors.blue;

  // ========== COLORES DE BORDES ==========
  static const Color borde = Color(0xFFE0E0E0);
  static const Color bordeClaro = Color(0xFFEEEEEE);
  static const Color bordeOscuro = Color(0xFF616161);
  static const Color divisor = Color(0xFFEEEEEE);

  // ========== COLORES DE SUPERFICIE ==========
  static const Color superficie = Color(0xFFF5F5F5);
  static const Color superficieOscura = Color(0xFF303030);

  // ========== COLORES DE OVERLAY ==========
  static const Color overlayClaro = Color(0x4D000000);
  static const Color overlayOscuro = Color(0xB3000000);

  // ========== COLORES DE CONTROLES ==========
  static const Color sliderActivo = Colors.blue;
  static const Color sliderInactivo = Color(0x4DFFFFFF);

  // ========== COLORES DE SNACKBAR ==========
  static const Color snackbarExito = Colors.red;
  static const Color snackbarError = Color(0xFF616161);

  // ========== MÉTODOS DE UTILIDAD ==========

  /// Aplica opacidad a un color
  static Color conOpacidad(Color color, double opacidad) {
    return color.withOpacity(opacidad);
  }

  /// Crea un MaterialColor a partir de un color
  static MaterialColor crearMaterialColor(Color color) {
    final int rojo = color.red;
    final int verde = color.green;
    final int azul = color.blue;

    final Map<int, Color> tonos = {
      50: Color.fromRGBO(rojo, verde, azul, .1),
      100: Color.fromRGBO(rojo, verde, azul, .2),
      200: Color.fromRGBO(rojo, verde, azul, .3),
      300: Color.fromRGBO(rojo, verde, azul, .4),
      400: Color.fromRGBO(rojo, verde, azul, .5),
      500: Color.fromRGBO(rojo, verde, azul, .6),
      600: Color.fromRGBO(rojo, verde, azul, .7),
      700: Color.fromRGBO(rojo, verde, azul, .8),
      800: Color.fromRGBO(rojo, verde, azul, .9),
      900: Color.fromRGBO(rojo, verde, azul, 1),
    };

    return MaterialColor(color.value, tonos);
  }

  // ========== ESQUEMAS DE COLOR ==========

  /// Esquema de colores para tema claro
  static ColorScheme get esquemaColorClaro => ColorScheme.light(
        primary: primario,
        secondary: primarioClaro,
        surface: fondoSecundario,
        error: error,
        onPrimary: textoBlanco,
        onSecondary: textoPrimario,
        onSurface: textoPrimario,
        onError: textoBlanco,
      );

  /// Esquema de colores para tema oscuro
  static ColorScheme get esquemaColorOscuro => ColorScheme.dark(
        primary: primarioClaro,
        secondary: primario,
        surface: fondoTarjeta,
        error: error,
        onPrimary: textoPrimario,
        onSecondary: textoBlanco,
        onSurface: textoBlanco,
        onError: textoBlanco,
      );

  /// No permitir instanciación
  ColoresApp._();
}

// ========== CLASES DE CONTEXTO ESPECÍFICO ==========

/// Colores para el componente de búsqueda
class ColoresBusqueda {
  static const Color fondo = Color(0xFFF5F5F5);
  static const Color borde = Color(0xFFE0E0E0);
  static const Color icono = Color(0xFF757575);
  static const Color hint = Color(0xFF9E9E9E);

  ColoresBusqueda._();
}

/// Colores para la lista de himnos
class ColoresListaHimnos {
  static const Color textoNumero = Color(0xFF757575);
  static const Color textoTitulo = Color.fromARGB(221, 88, 88, 88);
  static const Color textoSubtitulo = Color(0xFF757575);
  static const Color indicadorAudio = Colors.green;
  static const Color iconoMusica = Colors.blue;

  ColoresListaHimnos._();
}

/// Colores para el carrusel de imágenes
class ColoresCarrusel {
  static const Color placeholder = Color(0xFFE0E0E0);
  static const Color iconoPlaceholder = Color(0xFF757575);
  static const Color overlaySuperior = Color(0x4D000000);
  static const Color overlayInferior = Color(0xB3000000);
  static const Color textoOverlay = Colors.white;
  static const Color indicadorActivo = Colors.white;
  static const Color indicadorInactivo = Color(0x66FFFFFF);

  ColoresCarrusel._();
}

/// Colores para estados de carga y vacío
class ColoresCarga {
  static const Color indicador = Colors.blue;
  static const Color texto = Color(0xFF757575);
  static const Color iconoEstadoVacio = Color(0xFFBDBDBD);
  static const Color tituloEstadoVacio = Color(0xFF757575);
  static const Color subtituloEstadoVacio = Color(0xFF9E9E9E);

  ColoresCarga._();
}
