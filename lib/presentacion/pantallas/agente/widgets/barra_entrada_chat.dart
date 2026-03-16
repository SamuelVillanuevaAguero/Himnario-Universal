import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configuracion/temas/colores_app.dart';
import '../../../providers/provider_agente.dart';

class BarraEntradaChat extends StatefulWidget {
  final bool esModoOscuro;
  final Future<void> Function(String) onEnviar;

  const BarraEntradaChat(
      {Key? key, required this.esModoOscuro, required this.onEnviar})
      : super(key: key);

  @override
  State<BarraEntradaChat> createState() => _BarraEntradaChatState();
}

class _BarraEntradaChatState extends State<BarraEntradaChat> {
  final _ctrl = TextEditingController();
  bool _tieneTexto = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final t = _ctrl.text.trim().isNotEmpty;
      if (t != _tieneTexto) setState(() => _tieneTexto = t);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;
    _ctrl.clear();
    setState(() => _tieneTexto = false);
    await widget.onEnviar(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderAgente>(
      builder: (_, provider, __) {
        final bloqueado =
            provider.estaActivo || provider.mensajesRestantes <= 0;
        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: widget.esModoOscuro
                ? ColoresApp.fondoOscuro
                : ColoresApp.fondoPrimario,
            border: Border(
              top: BorderSide(
                  color: widget.esModoOscuro
                      ? ColoresApp.bordeOscuro
                      : ColoresApp.borde),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: widget.esModoOscuro
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    enabled: !bloqueado,
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.esModoOscuro
                          ? Colors.white
                          : ColoresApp.textoPrimario,
                    ),
                    decoration: InputDecoration(
                      hintText: provider.mensajesRestantes <= 0
                          ? 'Límite diario alcanzado'
                          : 'Pregunta sobre himnos...',
                      hintStyle: TextStyle(
                          color: widget.esModoOscuro
                              ? ColoresApp.textoBlancoSecundario
                              : ColoresApp.textoSecundario,
                          fontSize: 15),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (!bloqueado && _tieneTexto)
                      ? (widget.esModoOscuro
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario)
                      : (widget.esModoOscuro
                          ? const Color(0xFF333333)
                          : const Color(0xFFE0E0E0)),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: (!bloqueado && _tieneTexto) ? _enviar : null,
                    child: provider.estaActivo
                        ? Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.esModoOscuro
                                    ? Colors.white
                                    : ColoresApp.primario,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            size: 19,
                            color: (!bloqueado && _tieneTexto)
                                ? Colors.white
                                : (widget.esModoOscuro
                                    ? ColoresApp.textoBlancoSecundario
                                    : ColoresApp.textoSecundario),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}