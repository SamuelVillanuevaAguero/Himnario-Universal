import 'package:flutter/material.dart';
import 'colores_app.dart';

/// Configuración de temas de la aplicación
class TemaApp {
  /// Tema claro de la aplicación
  static ThemeData get temaClaro {
    return ThemeData(
      // Configuración básica
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colores primarios
      primarySwatch: ColoresApp.crearMaterialColor(ColoresApp.primario),
      colorScheme: ColoresApp.esquemaColorClaro,
      
      // Colores de fondo
      scaffoldBackgroundColor: ColoresApp.fondoPrimario,
      
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: ColoresApp.primario,
        foregroundColor: ColoresApp.textoBlanco,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoBlanco,
        ),
      ),
      
      // Tarjetas
      cardTheme: const CardThemeData(
        color: ColoresApp.fondoSecundario,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Tema de texto
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: ColoresApp.textoPrimario,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: ColoresApp.textoSecundario,
          fontSize: 14,
        ),
        titleLarge: TextStyle(
          color: ColoresApp.textoPrimario,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: ColoresApp.textoPrimario,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Iconos
      iconTheme: const IconThemeData(
        color: ColoresApp.textoSecundario,
      ),
      
      // Divisores
      dividerColor: ColoresApp.divisor,
      dividerTheme: const DividerThemeData(
        color: ColoresApp.divisor,
        thickness: 1,
        space: 1,
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.borde),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.primario, width: 2),
        ),
        hintStyle: const TextStyle(
          color: ColoresApp.textoTerciario,
        ),
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primario,
          foregroundColor: ColoresApp.textoBlanco,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColoresApp.primario,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Barra de navegación inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColoresApp.fondoPrimario,
        selectedItemColor: ColoresApp.primario,
        unselectedItemColor: ColoresApp.textoSecundario,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColoresApp.textoPrimario,
        contentTextStyle: const TextStyle(
          color: ColoresApp.textoBlanco,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Otros
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Tema oscuro de la aplicación
  static ThemeData get temaOscuro {
    return ThemeData(
      // Configuración básica
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colores primarios
      primarySwatch: ColoresApp.crearMaterialColor(ColoresApp.primarioClaro),
      colorScheme: ColoresApp.esquemaColorOscuro,
      
      // Colores de fondo
      scaffoldBackgroundColor: ColoresApp.fondoOscuro,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.fondoTarjeta,
        foregroundColor: ColoresApp.textoBlanco,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ColoresApp.textoBlanco,
        ),
      ),
      
      // Tarjetas
      cardTheme: const CardThemeData(
        color: ColoresApp.fondoTarjeta,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Tema de texto
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: ColoresApp.textoBlanco,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: ColoresApp.textoBlancoSecundario,
          fontSize: 14,
        ),
        titleLarge: TextStyle(
          color: ColoresApp.textoBlanco,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: ColoresApp.textoBlanco,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Iconos
      iconTheme: const IconThemeData(
        color: ColoresApp.textoBlancoSecundario,
      ),
      
      // Divisores
      dividerColor: ColoresApp.bordeOscuro,
      dividerTheme: const DividerThemeData(
        color: ColoresApp.bordeOscuro,
        thickness: 1,
        space: 1,
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.bordeOscuro),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColoresApp.bordeOscuro),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColoresApp.primarioClaro,
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(
          color: ColoresApp.textoBlancoTerciario,
        ),
      ),
      
      // Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresApp.primarioClaro,
          foregroundColor: ColoresApp.fondoOscuro,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColoresApp.primarioClaro,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Barra de navegación inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColoresApp.fondoOscuro,
        selectedItemColor: ColoresApp.primarioClaro,
        unselectedItemColor: ColoresApp.textoBlancoSecundario,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColoresApp.fondoTarjeta,
        contentTextStyle: const TextStyle(
          color: ColoresApp.textoBlanco,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Otros
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
