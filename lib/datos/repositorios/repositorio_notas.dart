import 'package:shared_preferences/shared_preferences.dart';

/// Repositorio para notas personales por himno (SharedPreferences)
class RepositorioNotas {
  static const String _prefijo = 'nota_himno_';

  Future<String?> obtenerNota(int numeroHimno) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefijo$numeroHimno');
  }

  Future<void> guardarNota(int numeroHimno, String nota) async {
    final prefs = await SharedPreferences.getInstance();
    if (nota.trim().isEmpty) {
      await prefs.remove('$_prefijo$numeroHimno');
    } else {
      await prefs.setString('$_prefijo$numeroHimno', nota.trim());
    }
  }

  Future<void> eliminarNota(int numeroHimno) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefijo$numeroHimno');
  }
}