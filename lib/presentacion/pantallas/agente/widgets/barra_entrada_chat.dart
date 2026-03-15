import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configuracion/temas/colores_app.dart';
import '../../../providers/provider_agente.dart';

/// Barra inferior de entrada de texto para el chat
class BarraEntradaChat extends StatefulWidget {
  final bool esModoOscuro;
  final Future<void> Function(String texto) onEnviar;

  const BarraEntradaChat({
    Key? key,
    required this.esModoOscuro,
    required this.onEnviar,
  }) : super(key: key);

  @override
  State<BarraEntradaChat> createState() => _BarraEntradaChatState();
}

class _BarraEntradaChatState extends State<BarraEntradaChat> {
  final TextEditingController _controlador = TextEditingController();
  bool _tieneTexto = false;

  @override
  void initState() {
    super.initState();
    _controlador.addListener(() {
      final tiene = _controlador.text.trim().isNotEmpty;
      if (tiene != _tieneTexto) {
        setState(() => _tieneTexto = tiene);
      }
    });
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    _controlador.clear();
    setState(() => _tieneTexto = false);
    await widget.onEnviar(texto);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderAgente>(
      builder: (context, provider, _) {
        final bloqueado = provider.estaActivo || provider.mensajesRestantes <= 0;

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
                    : ColoresApp.borde,
                width: 1,
              ),
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
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controlador,
                    maxLines: null,
                    enabled: !bloqueado,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: bloqueado ? null : (_) => _enviar(),
                    decoration: InputDecoration(
                      hintText: provider.mensajesRestantes <= 0
                          ? 'Límite diario alcanzado'
                          : 'Pregunta sobre himnos...',
                      hintStyle: TextStyle(
                        color: widget.esModoOscuro
                            ? ColoresApp.textoBlancoSecundario
                            : ColoresApp.textoSecundario,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    style: TextStyle(
                      fontSize: 15,
                      color: widget.esModoOscuro
                          ? ColoresApp.textoBlanco
                          : ColoresApp.textoPrimario,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (!bloqueado && _tieneTexto)
                      ? (widget.esModoOscuro
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario)
                      : (widget.esModoOscuro
                          ? const Color(0xFF424242)
                          : const Color(0xFFE0E0E0)),
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(23),
                    onTap: (!bloqueado && _tieneTexto) ? _enviar : null,
                    child: provider.estaActivo
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
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
                            color: (!bloqueado && _tieneTexto)
                                ? Colors.white
                                : (widget.esModoOscuro
                                    ? ColoresApp.textoBlancoSecundario
                                    : ColoresApp.textoSecundario),
                            size: 20,
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