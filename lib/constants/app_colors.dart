import 'package:flutter/material.dart';

class AppColors {
  // Colores primarios de la aplicación
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Colores de fondo
  static const Color backgroundPrimary = Color(0xFFF1F4F8);
  static const Color backgroundSecondary = Colors.white;
  static const Color backgroundDark = Colors.black;
  static const Color backgroundCard = Color(0xFF212121);
  static const Color backgroundAudioControl = Color(0xFF424242);

  // Colores de texto
  static const Color textPrimary = Color.fromARGB(221, 88, 88, 88);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textWhite = Colors.white;
  static const Color textWhiteSecondary = Color(
    0xE6FFFFFF,
  );
  static const Color textWhiteTertiary = Color(
    0xB3FFFFFF,
  );

  // Colores de estado
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Colores específicos de funcionalidades
  static const Color favorite = Colors.red;
  static const Color favoriteInactive = Color(0xFFBDBDBD);
  static const Color audioAvailable = Colors.green;
  static const Color audioUnavailable = Color(0xFFBDBDBD);
  static const Color musicNote = Colors.blue;

  // Colores de borde y divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFF616161);
  static const Color divider = Color(0xFFEEEEEE);

  // Colores de superficie
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF303030);

  // Colores de overlay y sombra
  static const Color overlayLight = Color(0x4D000000);
  static const Color overlayDark = Color(0xB3000000);

  // Colores para slider y controles de audio
  static const Color sliderActive = Colors.blue;
  static const Color sliderInactive = Color(
    0x4DFFFFFF,
  ); // White with 30% opacity

  // Colores específicos para snackbar
  static const Color snackBarSuccess = Colors.red;
  static const Color snackBarError = Color(0xFF616161);

  // Métodos helper para colores con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Método para obtener un MaterialColor personalizado
  static MaterialColor createMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }

  // Tema de colores claro
  static ColorScheme get lightColorScheme => ColorScheme.light(
    primary: primary,
    secondary: primaryLight,
    surface: backgroundSecondary,
    background: backgroundPrimary,
    error: error,
    onPrimary: textWhite,
    onSecondary: textPrimary,
    onSurface: textPrimary,
    onBackground: textPrimary,
    onError: textWhite,
  );

  // Tema de colores oscuro
  static ColorScheme get darkColorScheme => ColorScheme.dark(
    primary: primaryLight,
    secondary: primary,
    surface: backgroundCard,
    background: backgroundDark,
    error: error,
    onPrimary: textPrimary,
    onSecondary: textWhite,
    onSurface: textWhite,
    onBackground: textWhite,
    onError: textWhite,
  );
}

// Colores específicos para diferentes contextos
class Search {
  static const Color background = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);
  static const Color icon = Color(0xFF757575);
  static const Color hint = Color(0xFF9E9E9E);
}

class HymnList {
  static const Color numberText = Color(0xFF757575);
  static const Color titleText = Color.fromARGB(221, 88, 88, 88);
  static const Color subtitleText = Color(0xFF757575);
  static const Color audioIndicator = Colors.green;
  static const Color musicIcon = Colors.blue;
}

class HymnDetail {
  static const Color standarGrey =  Color(0xFF757575);

  static const Color headerBackground = Color(0xFFF1F4F8);
  static const Color headerBackgroundGradient = Color(0xFFF1F4F8);


  static const Color backIcon = standarGrey;
  static const Color numberText = standarGrey;
  static const Color titleText = standarGrey;
  static const Color toneText = standarGrey;
  static const Color lyricsText = standarGrey;

  static const Color audioControlBackground = standarGrey;
  static const Color audioControlBorder = Color.fromARGB(255, 0, 0, 0);

  static const Color audioUnavailableBackground = Color.fromARGB(255, 255, 75, 75);
  static const Color audioUnavailableBorder = Color.fromARGB(255, 0, 0, 0);
  static const Color audioUnavailableIcon = Color.fromARGB(255, 255, 255, 255);
  
  static const Color fontSizeIcon = standarGrey; // Iconos de abajo del audio
}

class Carousel {
  static const Color placeholder = Color(0xFFE0E0E0);
  static const Color placeholderIcon = Color(0xFF757575);
  static const Color overlayTop = Color(0x4D000000);
  static const Color overlayBottom = Color(
    0xB3000000,
  );
  static const Color textOverlay = Colors.white;
  static const Color indicatorActive = Colors.white;
  static const Color indicatorInactive = Color(
    0x66FFFFFF,
  );
}

class Loading {
  static const Color indicator = Colors.blue;
  static const Color text = Color(0xFF757575);
  static const Color emptyStateIcon = Color(0xFFBDBDBD);
  static const Color emptyStateTitle = Color(0xFF757575);
  static const Color emptyStateSubtitle = Color(0xFF9E9E9E);
}
