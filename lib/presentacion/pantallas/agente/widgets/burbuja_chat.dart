import 'package:flutter/material.dart';
import '../../../../configuracion/temas/colores_app.dart';
import '../../../../datos/modelos/modelos_chat.dart';
import '../../../../datos/repositorios/repositorio_himnos.dart';
import '../../../../datos/repositorios/repositorio_audios.dart';
import '../../../pantallas/detalle_himno/pantalla_detalle_himno.dart';

class BurbujaChat extends StatelessWidget {
  final ChatMessage mensaje;
  final bool esModoOscuro;

  const BurbujaChat({
    super.key,
    required this.mensaje,
    required this.esModoOscuro,
  });

  bool get esUsuario => mensaje.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esUsuario) _avatar(),
          if (!esUsuario) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esUsuario
                    ? (esModoOscuro
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF1976D2))
                    : (esModoOscuro
                        ? const Color(0xFF1E1E1E)
                        : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: esUsuario
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: esUsuario
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextoConFormato(context),
                  const SizedBox(height: 4),
                  Text(
                    _hora(),
                    style: TextStyle(
                      fontSize: 11,
                      color: esUsuario
                          ? Colors.white.withOpacity(0.65)
                          : (esModoOscuro
                              ? ColoresApp.textoBlancoTerciario
                              : ColoresApp.textoTerciario),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (esUsuario) const SizedBox(width: 8),
          if (esUsuario) _avatarUsuario(),
        ],
      ),
    );
  }

  // ─── Parser de texto ────────────────────────────────────────────────────────
  //
  // Orden de prioridad del regex (3 grupos):
  //   Grupo 1 → **Himno #NNN**  → link con negrita   (ej: **Himno #412**)
  //   Grupo 2 → **cualquier texto**  → solo negrita  (ej: **Tono:**)
  //   Grupo 3 → Himno #NNN sin asteriscos → link plano
  //
  Widget _buildTextoConFormato(BuildContext context) {
    final Color colorBase = esUsuario
        ? Colors.white
        : (esModoOscuro ? Colors.white : ColoresApp.textoPrimario);

    final Color colorLink = esUsuario
        ? Colors.lightBlue.shade200
        : (esModoOscuro ? ColoresApp.primarioClaro : ColoresApp.primario);

    final List<InlineSpan> spans = [];

    // Regex unificado — el orden importa: primero el caso más específico
    final regex = RegExp(
      r'\*\*(Himno\s+#(\d+).*?)\*\*'   // grupo 1+2: **Himno #NNN...** (bold link)
      r'|\*\*(.+?)\*\*'                 // grupo 3:   **texto** (solo bold)
      r'|(Himno\s+#(\d+))',             // grupo 4+5: Himno #NNN sin asteriscos
      caseSensitive: false,
    );

    int ultimo = 0;
    for (final match in regex.allMatches(mensaje.content)) {
      // Texto plano antes del match
      if (match.start > ultimo) {
        spans.add(TextSpan(text: mensaje.content.substring(ultimo, match.start)));
      }

      if (match.group(1) != null) {
        // Caso: **Himno #NNN...** → link con negrita
        final numeroHimno = int.parse(match.group(2)!);
        // Extraer la parte "Himno #NNN" del texto completo del grupo 1
        final textoCompleto = match.group(1)!;
        // Mostrar solo "Himno #NNN" como chip, el resto como negrita normal
        final himnoPart = RegExp(r'Himno\s+#\d+', caseSensitive: false)
            .firstMatch(textoCompleto)!
            .group(0)!;
        final restoPart = textoCompleto.substring(himnoPart.length);

        spans.add(_chipHimno(context, himnoPart, numeroHimno, colorLink));

        if (restoPart.isNotEmpty) {
          spans.add(TextSpan(
            text: restoPart,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));
        }
      } else if (match.group(3) != null) {
        // Caso: **texto** → solo negrita
        spans.add(TextSpan(
          text: match.group(3),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(4) != null) {
        // Caso: Himno #NNN sin asteriscos → link plano
        final numeroHimno = int.parse(match.group(5)!);
        spans.add(_chipHimno(
            context, match.group(4)!, numeroHimno, colorLink));
      }

      ultimo = match.end;
    }

    if (ultimo < mensaje.content.length) {
      spans.add(TextSpan(text: mensaje.content.substring(ultimo)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 15, height: 1.45, color: colorBase),
        children: spans,
      ),
    );
  }

  /// Chip tappable para un himno
  WidgetSpan _chipHimno(
    BuildContext context,
    String etiqueta,
    int numero,
    Color colorLink,
  ) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () => _navegarAHimno(context, numero),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: colorLink.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colorLink.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 13, color: colorLink),
              const SizedBox(width: 3),
              Text(
                etiqueta,
                style: TextStyle(
                  color: colorLink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: colorLink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Navegación ─────────────────────────────────────────────────────────────

  Future<void> _navegarAHimno(BuildContext context, int numero) async {
    final repo = RepositorioHimnos(repositorioAudios: RepositorioAudios());
    final himno = await repo.obtenerHimnoPorNumero(numero);
    if (himno == null || !context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PantallaDetalleHimno(himno: himno)),
    );
  }

  // ─── Avatares y hora ────────────────────────────────────────────────────────

  Widget _avatar() => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: esModoOscuro
                ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                : [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
          ),
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
      );

  Widget _avatarUsuario() => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: esModoOscuro
              ? const Color(0xFF333333)
              : const Color(0xFFE0E0E0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          size: 15,
          color: esModoOscuro
              ? ColoresApp.textoBlancoSecundario
              : ColoresApp.textoSecundario,
        ),
      );

  String _hora() {
    final t = mensaje.timestamp;
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }
}