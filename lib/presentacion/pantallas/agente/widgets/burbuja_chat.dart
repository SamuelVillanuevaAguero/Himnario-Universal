import 'package:flutter/material.dart';
import '../../../../configuracion/temas/colores_app.dart';
import '../../../../datos/modelos/modelos_chat.dart';

class BurbujaChat extends StatelessWidget {
  final ChatMessage mensaje;
  final bool esModoOscuro;

  const BurbujaChat(
      {Key? key, required this.mensaje, required this.esModoOscuro})
      : super(key: key);

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
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
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
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: esUsuario
                          ? Colors.white
                          : (esModoOscuro
                              ? Colors.white
                              : ColoresApp.textoPrimario),
                    ),
                  ),
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
        child: Icon(Icons.person,
            size: 15,
            color: esModoOscuro
                ? ColoresApp.textoBlancoSecundario
                : ColoresApp.textoSecundario),
      );

  String _hora() {
    final t = mensaje.timestamp;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}