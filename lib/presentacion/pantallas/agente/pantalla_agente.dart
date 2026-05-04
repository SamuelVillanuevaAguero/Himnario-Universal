import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../configuracion/temas/colores_app.dart';
import '../../providers/provider_agente.dart';
import 'widgets/burbuja_chat.dart';
import 'widgets/indicador_escribiendo.dart';
import 'widgets/barra_entrada_chat.dart';
import 'widgets/drawer_hilos.dart';

class PantallaAgente extends StatefulWidget {
  const PantallaAgente({super.key});

  @override
  State<PantallaAgente> createState() => _PantallaAgenteState();
}

class _PantallaAgenteState extends State<PantallaAgente>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _scroll = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProviderAgente>();
      await provider.inicializar();
      // Si no hay hilos o ninguno activo, crear uno
      if (provider.hiloActivo == null) {
        if (provider.hilos.isNotEmpty) {
          await provider.abrirHilo(provider.hilos.first.threadId);
        } else {
          await provider.crearHilo();
        }
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor:
          dark ? ColoresApp.fondoOscuro : ColoresApp.fondoPrimario,
      drawer: const DrawerHilos(),
      body: SafeArea(
        child: Column(
          children: [
            _Encabezado(
              scaffoldKey: _scaffoldKey,
              dark: dark,
            ),
            Expanded(
              child: Consumer<ProviderAgente>(
                builder: (ctx, provider, _) {
                  if (provider.estaActivo) _scrollAlFinal();
                  return Column(
                    children: [
                      Expanded(
                          child: _CuerpoChat(
                              scroll: _scroll, dark: dark)),
                      if (provider.estadoChat ==
                          EstadoChat.consultandoHerramienta)
                        IndicadorEscribiendo(esModoOscuro: dark),
                      if (provider.errorMensaje != null)
                        _BannerError(dark: dark),
                    ],
                  );
                },
              ),
            ),
            BarraEntradaChat(
              esModoOscuro: dark,
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
}

// ─── Encabezado ───────────────────────────────────────────────────────────────

class _Encabezado extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool dark;
  const _Encabezado({required this.scaffoldKey, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? ColoresApp.fondoOscuro : ColoresApp.fondoPrimario,
        border: Border(
          bottom: BorderSide(
              color: dark ? ColoresApp.bordeOscuro : ColoresApp.borde),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
            icon: Icon(Icons.menu_rounded,
                color: dark ? Colors.white : ColoresApp.textoPrimario),
          ),
          Expanded(
            child: Consumer<ProviderAgente>(
              builder: (_, provider, __) {
                final titulo =
                    provider.hiloActivo?.title ?? 'Asistente';
                return GestureDetector(
                  onTap: () => scaffoldKey.currentState?.openDrawer(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: dark
                                  ? ColoresApp.primarioClaro
                                  : ColoresApp.primario,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              titulo,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: dark
                                    ? Colors.white
                                    : ColoresApp.textoPrimario,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.keyboard_arrow_down,
                              size: 15,
                              color: dark
                                  ? ColoresApp.textoBlancoSecundario
                                  : ColoresApp.textoSecundario),
                        ],
                      ),
                      Text(
                        provider.mensajesRestantes > 0
                            ? '${provider.mensajesRestantes} mensajes hoy'
                            : 'Límite alcanzado',
                        style: TextStyle(
                          fontSize: 11,
                          color: provider.mensajesRestantes > 5
                              ? (dark
                                  ? ColoresApp.textoBlancoSecundario
                                  : ColoresApp.textoSecundario)
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Nueva conversación rápida
          IconButton(
            onPressed: () async {
              await context.read<ProviderAgente>().crearHilo();
            },
            icon: Icon(Icons.add_comment_outlined,
                size: 20,
                color: dark
                    ? ColoresApp.textoBlancoSecundario
                    : ColoresApp.textoSecundario),
            tooltip: 'Nueva conversación',
          ),
        ],
      ),
    );
  }
}

// ─── Cuerpo del chat ──────────────────────────────────────────────────────────

class _CuerpoChat extends StatelessWidget {
  final ScrollController scroll;
  final bool dark;
  const _CuerpoChat({required this.scroll, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderAgente>(
      builder: (_, provider, __) {
        if (!provider.inicializado) {
          return Center(
            child: CircularProgressIndicator(
              color: dark
                  ? ColoresApp.primarioClaro
                  : ColoresApp.primario,
            ),
          );
        }

        if (provider.mensajesActivos.isEmpty) {
          return _EstadoVacio(dark: dark);
        }

        return ListView.builder(
          controller: scroll,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          itemCount: provider.mensajesActivos.length,
          itemBuilder: (_, i) => BurbujaChat(
            mensaje: provider.mensajesActivos[i],
            esModoOscuro: dark,
          ),
        );
      },
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EstadoVacio extends StatelessWidget {
  final bool dark;
  const _EstadoVacio({required this.dark});

  static const _sugerencias = [
    '¿Qué himnos puedo cantar en Navidad?',
    'Necesito un himno para un funeral',
    '¿Hay himnos sobre la esperanza?',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: (dark
                      ? ColoresApp.primarioClaro
                      : ColoresApp.primario)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.church_outlined,
                size: 34,
                color: dark
                    ? ColoresApp.primarioClaro
                    : ColoresApp.primario),
          ),
          const SizedBox(height: 16),
          Text(
            '¡Paz de Dios, hermano/hermana!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: dark ? Colors.white : ColoresApp.textoPrimario,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Pregúntame sobre himnos para ocasiones especiales, '
            'fiestas, o busca la letra de un himno.',
            style: TextStyle(
              fontSize: 13,
              color: dark
                  ? ColoresApp.textoBlancoSecundario
                  : ColoresApp.textoSecundario,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          ..._sugerencias.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () =>
                    context.read<ProviderAgente>().enviarMensaje(s),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (dark
                            ? ColoresApp.primarioClaro
                            : ColoresApp.primario)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (dark
                              ? ColoresApp.primarioClaro
                              : ColoresApp.primario)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 13,
                      color: dark
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner de error ──────────────────────────────────────────────────────────

class _BannerError extends StatelessWidget {
  final bool dark;
  const _BannerError({required this.dark});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderAgente>(
      builder: (_, provider, __) {
        if (provider.errorMensaje == null) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.red, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(provider.errorMensaje!,
                    style: const TextStyle(
                        color: Colors.red, fontSize: 13, height: 1.3)),
              ),
              TextButton(
                onPressed: provider.limpiarError,
                child: const Text('OK',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }
}