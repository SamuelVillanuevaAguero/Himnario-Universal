import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar la aceptación de términos y condiciones
class ServicioTerminosCondiciones {
  static const String _claveTerminosAceptados = 'terminos_condiciones_aceptados';
  static const String _claveVersionTerminos = 'version_terminos_aceptados';
  static const String _versionActual = '1.0.0';

  /// Verifica si el usuario ha aceptado los términos y condiciones
  Future<bool> haAceptadoTerminos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final aceptados = prefs.getBool(_claveTerminosAceptados) ?? false;
      final version = prefs.getString(_claveVersionTerminos) ?? '';

      // Verificar que haya aceptado y que sea la versión actual
      return aceptados && version == _versionActual;
    } catch (e) {
      print('Error verificando términos aceptados: $e');
      return false;
    }
  }

  /// Guarda que el usuario ha aceptado los términos
  Future<void> guardarAceptacionTerminos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_claveTerminosAceptados, true);
      await prefs.setString(_claveVersionTerminos, _versionActual);
      print('Términos y condiciones aceptados y guardados');
    } catch (e) {
      print('Error guardando aceptación de términos: $e');
      rethrow;
    }
  }

  /// Limpia la aceptación de términos (útil para pruebas o reseteo)
  Future<void> limpiarAceptacionTerminos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_claveTerminosAceptados);
      await prefs.remove(_claveVersionTerminos);
      print('Aceptación de términos limpiada');
    } catch (e) {
      print('Error limpiando aceptación de términos: $e');
      rethrow;
    }
  }

  /// Obtiene la versión actual de los términos
  String get versionActual => _versionActual;
}