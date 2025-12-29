import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba1/configuracion/temas/colores_app.dart';
import '../../../nucleo/constantes/constantes_app.dart';
import '../../providers/provider_categorias.dart';
import 'widgets/barra_busqueda_categorias.dart';
import 'widgets/lista_categorias.dart';

/// Pantalla que muestra las categorías de himnos disponibles
class PantallaCategorias extends StatefulWidget {
  const PantallaCategorias({Key? key}) : super(key: key);

  @override
  State<PantallaCategorias> createState() => _PantallaCategoriasState();
}

class _PantallaCategoriasState extends State<PantallaCategorias>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Inicializar provider después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderCategorias>().inicializar();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: esModoOscuro 
          ? ColoresApp.fondoOscuro 
          : ColoresApp.fondoPrimario,
      body: SafeArea(
        child: Column(
          children: [
            _construirEncabezado(context, esModoOscuro),
            const BarraBusquedaCategorias(),
            const SizedBox(height: 16),
            const Expanded(child: ListaCategorias()),
          ],
        ),
      ),
    );
  }

  Widget _construirEncabezado(BuildContext context, bool esModoOscuro) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.primario,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            ConstantesApp.tituloCategorias,
            style: TextStyle(
              fontSize: 24,
              color: esModoOscuro 
                  ? ColoresApp.textoBlanco 
                  : ColoresApp.textoPrimario,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _construirContadorCategorias(context, esModoOscuro),
        ],
      ),
    );
  }

  Widget _construirContadorCategorias(
    BuildContext context,
    bool esModoOscuro,
  ) {
    return Consumer<ProviderCategorias>(
      builder: (context, provider, child) {
        if (!provider.estaCargado || provider.categoriasFiltradas.isEmpty) {
          return const SizedBox.shrink();
        }

        final mostrarTotal = provider.terminoBusqueda.isNotEmpty &&
            provider.categoriasFiltradas.length != provider.todasCategorias.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (esModoOscuro 
                    ? ColoresApp.primarioClaro 
                    : ColoresApp.primario)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            mostrarTotal
                ? '${provider.categoriasFiltradas.length}/${provider.todasCategorias.length}'
                : '${provider.categoriasFiltradas.length}',
            style: TextStyle(
              color: esModoOscuro 
                  ? ColoresApp.primarioClaro 
                  : ColoresApp.primario,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}
