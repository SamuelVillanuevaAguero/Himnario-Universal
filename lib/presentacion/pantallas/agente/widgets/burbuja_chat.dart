import 'package:flutter/material.dart';
import '../../../../configuracion/temas/colores_app.dart';
import '../../../../datos/servicios/servicio_agente_api.dart';

/// Burbuja de chat para mensajes del usuario y del asistente
class BurbujaChat extends StatelessWidget {
  final MensajeChat mensaje;
  final bool esModoOscuro;

  const BurbujaChat({
    Key? key,
    required this.mensaje,
    required this.esModoOscuro,
  }) : super(key: key);

  bool get esUsuario => mensaje.rol == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!esUsuario) _construirAvatarAsistente(),
          if (!esUsuario) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esUsuario ? _colorUsuario() : _colorAsistente(),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft:
                      esUsuario ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight:
                      esUsuario ? const Radius.circular(4) : const Radius.circular(18),
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
                  _construirTexto(),
                  const SizedBox(height: 4),
                  _construirHora(),
                ],
              ),
            ),
          ),
          if (esUsuario) const SizedBox(width: 8),
          if (esUsuario) _construirAvatarUsuario(),
        ],
      ),
    );
  }

  Color _colorUsuario() {
    return esModoOscuro ? const Color(0xFF1565C0) : const Color(0xFF1976D2);
  }

  Color _colorAsistente() {
    return esModoOscuro ? const Color(0xFF2C2C2C) : Colors.white;
  }

  Widget _construirTexto() {
    final texto = mensaje.contenido;

    if (texto.isEmpty && mensaje.esStreaming) {
      // Cursor parpadeante cuando no hay texto aún
      return _CursorParpadeo(esModoOscuro: esModoOscuro, esUsuario: esUsuario);
    }

    return Text(
      texto,
      style: TextStyle(
        fontSize: 15,
        height: 1.45,
        color: esUsuario
            ? Colors.white
            : (esModoOscuro
                ? ColoresApp.textoBlanco
                : ColoresApp.textoPrimario),
      ),
    );
  }

  Widget _construirHora() {
    final hora =
        '${mensaje.timestamp.hour.toString().padLeft(2, '0')}:${mensaje.timestamp.minute.toString().padLeft(2, '0')}';
    return Text(
      hora,
      style: TextStyle(
        fontSize: 11,
        color: esUsuario
            ? Colors.white.withOpacity(0.65)
            : (esModoOscuro
                ? ColoresApp.textoBlancoTerciario
                : ColoresApp.textoTerciario),
      ),
    );
  }

  Widget _construirAvatarAsistente() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: esModoOscuro
              ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
              : [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
    );
  }

  Widget _construirAvatarUsuario() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: esModoOscuro ? const Color(0xFF424242) : const Color(0xFFE0E0E0),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color:
            esModoOscuro ? ColoresApp.textoBlancoSecundario : ColoresApp.textoSecundario,
        size: 17,
      ),
    );
  }
}

/// Cursor parpadeante mientras se espera streaming
class _CursorParpadeo extends StatefulWidget {
  final bool esModoOscuro;
  final bool esUsuario;

  const _CursorParpadeo(
      {required this.esModoOscuro, required this.esUsuario});

  @override
  State<_CursorParpadeo> createState() => _CursorParpadeoState();
}

class _CursorParpadeoState extends State<_CursorParpadeo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 16,
        decoration: BoxDecoration(
          color: widget.esUsuario
              ? Colors.white
              : (widget.esModoOscuro
                  ? ColoresApp.textoBlanco
                  : ColoresApp.textoPrimario),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}