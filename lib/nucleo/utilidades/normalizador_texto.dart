/// Utilidad para normalización de texto
/// Útil para búsquedas sin distinción de acentos
class NormalizadorTexto {
  /// Caracteres con acentos y diacríticos
  static const String _conDiacriticos =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽz';

  /// Equivalentes sin acentos
  static const String _sinDiacriticos =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  /// Normaliza un texto removiendo acentos y convirtiendo a minúsculas
  /// 
  /// Ejemplo:
  /// ```dart
  /// NormalizadorTexto.normalizar('Ángel') // retorna 'angel'
  /// ```
  static String normalizar(String texto) {
    String textoNormalizado = texto.toLowerCase();

    for (int i = 0; i < _conDiacriticos.length; i++) {
      textoNormalizado = textoNormalizado.replaceAll(
        _conDiacriticos[i],
        _sinDiacriticos[i],
      );
    }

    return textoNormalizado;
  }

  /// Compara dos textos ignorando acentos y mayúsculas
  static bool compararIgnorandoDiacriticos(String texto1, String texto2) {
    return normalizar(texto1) == normalizar(texto2);
  }

  /// Verifica si un texto contiene otro ignorando acentos y mayúsculas
  static bool contieneIgnorandoDiacriticos(String texto, String busqueda) {
    return normalizar(texto).contains(normalizar(busqueda));
  }
}
