import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../configuracion/temas/colores_app.dart';
import '../../providers/provider_agente.dart';
import 'widgets/burbuja_chat.dart';
import 'widgets/indicador_escribiendo.dart';
import 'widgets/barra_entrada_chat.dart';

/// Pantalla del asistente eclesiástico con chat SSE
class PantallaAgente extends StatefulWidget {
  const PantallaAgente({Key? key}) : super(key: key);

  @override
  State<PantallaAgente> createState() => _PantallaAgenteState();
}

class _PantallaAgenteState extends State<PantallaAgente>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderAgente>().inicializar();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          esModoOscuro ? ColoresApp.fondoOscuro : ColoresApp.fondoPrimario,
      body: SafeArea(
        child: Column(
          children: [
            _construirEncabezado(esModoOscuro),
            Expanded(
              child: Consumer<ProviderAgente>(
                builder: (context, provider, _) {
                  // Auto-scroll cuando llegan mensajes nuevos
                  if (provider.estaActivo) _scrollAlFinal();

                  return Column(
                    children: [
                      Expanded(
                        child: _construirListaMensajes(provider, esModoOscuro),
                      ),
                      // Indicador de herramienta en uso
                      if (provider.estado ==
                          EstadoAgente.consultandoHerramienta)
                        IndicadorEscribiendo(esModoOscuro: esModoOscuro),
                      // Error
                      if (provider.mensajeError != null)
                        _construirBannerError(provider, esModoOscuro),
                    ],
                  );
                },
              ),
            ),
            BarraEntradaChat(
              esModoOscuro: esModoOscuro,
              onEnviar: (texto) async {
                await context.read<ProviderAgente>().enviarMensaje(texto);
                _scrollAlFinal();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezado(bool esModoOscuro) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color:
            esModoOscuro ? ColoresApp.fondoOscuro : ColoresApp.fondoPrimario,
        border: Border(
          bottom: BorderSide(
            color: esModoOscuro ? ColoresApp.bordeOscuro : ColoresApp.borde,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: esModoOscuro
                    ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                    : [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente Eclesiástico',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: esModoOscuro
                        ? ColoresApp.textoBlanco
                        : ColoresApp.textoPrimario,
                    letterSpacing: 0.2,
                  ),
                ),
                Consumer<ProviderAgente>(
                  builder: (context, provider, _) {
                    final restantes = provider.mensajesRestantes;
                    return Text(
                      restantes > 0
                          ? '$restantes mensajes disponibles hoy'
                          : 'Límite diario alcanzado',
                      style: TextStyle(
                        fontSize: 12,
                        color: restantes > 5
                            ? (esModoOscuro
                                ? ColoresApp.textoBlancoSecundario
                                : ColoresApp.textoSecundario)
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Consumer<ProviderAgente>(
            builder: (context, provider, _) => IconButton(
              onPressed: () => _mostrarDialogoLimpiar(context, provider),
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: esModoOscuro
                    ? ColoresApp.textoBlancoSecundario
                    : ColoresApp.textoSecundario,
                size: 22,
              ),
              tooltip: 'Limpiar conversación',
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirListaMensajes(
      ProviderAgente provider, bool esModoOscuro) {
    if (!provider.inicializado) {
      return Center(
        child: CircularProgressIndicator(
          color: esModoOscuro ? ColoresApp.primarioClaro : ColoresApp.primario,
        ),
      );
    }

    if (provider.mensajes.isEmpty) {
      return _construirEstadoVacio(esModoOscuro);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: provider.mensajes.length,
      itemBuilder: (context, index) {
        final msg = provider.mensajes[index];
        return BurbujaChat(
          mensaje: msg,
          esModoOscuro: esModoOscuro,
        );
      },
    );
  }

  Widget _construirEstadoVacio(bool esModoOscuro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (esModoOscuro
                        ? ColoresApp.primarioClaro
                        : ColoresApp.primario)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.church_outlined,
                size: 40,
                color: esModoOscuro
                    ? ColoresApp.primarioClaro
                    : ColoresApp.primario,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '¡Paz de Dios, hermano/hermana!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: esModoOscuro
                    ? ColoresApp.textoBlanco
                    : ColoresApp.textoPrimario,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Pregúntame sobre himnos para ocasiones especiales, '
              'fiestas, temas específicos o busca la letra de un himno.',
              style: TextStyle(
                fontSize: 14,
                color: esModoOscuro
                    ? ColoresApp.textoBlancoSecundario
                    : ColoresApp.textoSecundario,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _construirSugerencias(esModoOscuro),
          ],
        ),
      ),
    );
  }

  Widget _construirSugerencias(bool esModoOscuro) {
    final sugerencias = [
      '¿Qué himnos puedo cantar en Navidad?',
      'Necesito un himno para un funeral',
      '¿Hay himnos sobre la esperanza?',
    ];

    return Column(
      children: sugerencias.map((s) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => context.read<ProviderAgente>().enviarMensaje(s),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: (esModoOscuro
                        ? ColoresApp.primarioClaro
                        : ColoresApp.primario)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (esModoOscuro
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario)
                      .withOpacity(0.3),
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 13,
                  color: esModoOscuro
                      ? ColoresApp.primarioClaro
                      : ColoresApp.primario,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _construirBannerError(
      ProviderAgente provider, bool esModoOscuro) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.mensajeError!,
              style: const TextStyle(
                  color: Colors.red, fontSize: 13, height: 1.3),
            ),
          ),
          if (provider.estado == EstadoAgente.error)
            TextButton(
              onPressed: provider.limpiarError,
              child: const Text('OK',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  void _mostrarDialogoLimpiar(
      BuildContext context, ProviderAgente provider) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            esModoOscuro ? ColoresApp.fondoTarjeta : Colors.white,
        title: Text(
          'Limpiar conversación',
          style: TextStyle(
              color: esModoOscuro
                  ? ColoresApp.textoBlanco
                  : ColoresApp.textoPrimario),
        ),
        content: Text(
          '¿Deseas eliminar el historial local de esta conversación?',
          style: TextStyle(
              color: esModoOscuro
                  ? ColoresApp.textoBlancoSecundario
                  : ColoresApp.textoSecundario),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar',
                style: TextStyle(
                    color: esModoOscuro
                        ? ColoresApp.textoBlancoSecundario
                        : ColoresApp.textoSecundario)),
          ),
          TextButton(
            onPressed: () {
              provider.limpiarHistorial();
              Navigator.pop(context);
            },
            child: const Text('Limpiar',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}