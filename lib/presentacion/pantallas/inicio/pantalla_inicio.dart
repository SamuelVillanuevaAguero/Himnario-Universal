import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../configuracion/temas/colores_app.dart';
import '/../../nucleo/constantes/constantes_app.dart';
import '/../../presentacion/providers/provider_himnos.dart';
import 'widgets/carrusel_imagenes.dart';
import 'widgets/barra_busqueda.dart';
import 'widgets/lista_himnos.dart';

/// Pantalla principal de inicio con lista de himnos
class PantallaInicio extends StatefulWidget {
  const PantallaInicio({Key? key}) : super(key: key);

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Inicializar provider después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderHimnos>().inicializar();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido para AutomaticKeepAliveClientMixin
    
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: esModoOscuro 
          ? ColoresApp.fondoOscuro 
          : ColoresApp.fondoPrimario,
      body: SafeArea(
        child: Column(
          children: [
            const CarruselImagenes(),
            _construirTitulo(esModoOscuro),
            const BarraBusqueda(),
            const SizedBox(height: 20),
            const Expanded(child: ListaHimnos()),
          ],
        ),
      ),
    );
  }

  Widget _construirTitulo(bool esModoOscuro) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.home,
            color: esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.primario,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            ConstantesApp.tituloInicio,
            style: TextStyle(
              fontSize: 24,
              color: esModoOscuro 
                  ? ColoresApp.textoBlanco 
                  : ColoresApp.textoPrimario,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
