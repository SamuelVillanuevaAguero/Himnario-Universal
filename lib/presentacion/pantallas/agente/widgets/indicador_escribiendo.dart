import 'package:flutter/material.dart';
import '../../../../configuracion/temas/colores_app.dart';

/// Indicador animado de "Consultando el himnario..." o "Escribiendo..."
class IndicadorEscribiendo extends StatefulWidget {
  final bool esModoOscuro;

  const IndicadorEscribiendo({Key? key, required this.esModoOscuro})
      : super(key: key);

  @override
  State<IndicadorEscribiendo> createState() => _IndicadorEscribiendoState();
}

class _IndicadorEscribiendoState extends State<IndicadorEscribiendo>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: -6).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    // Iniciar con delays escalonados
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar del asistente
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.esModoOscuro
                    ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                    : [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 15),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.esModoOscuro
                  ? const Color(0xFF2C2C2C)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Consultando el himnario',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.esModoOscuro
                        ? ColoresApp.textoBlancoSecundario
                        : ColoresApp.textoSecundario,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    return AnimatedBuilder(
                      animation: _animations[i],
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _animations[i].value),
                        child: Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: widget.esModoOscuro
                                ? ColoresApp.primarioClaro
                                : ColoresApp.primario,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}