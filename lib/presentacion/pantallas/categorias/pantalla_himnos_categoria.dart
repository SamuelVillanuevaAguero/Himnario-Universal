import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../configuracion/temas/colores_app.dart';
import '../../../datos/modelos/categoria.dart';
import '../../../datos/modelos/himno.dart';
import '../../../datos/modelos/resultado_busqueda.dart';
import '../../providers/provider_categorias.dart';
import '../../providers/provider_himnos.dart';
import '../../widgets_comunes/estado_vacio.dart';
import '../../widgets_comunes/indicador_carga.dart';
import '../../widgets_comunes/tarjeta_himno.dart';

/// Pantalla que muestra los himnos de una categoría específica
class PantallaHimnosCategoria extends StatefulWidget {
  final Categoria categoria;

  const PantallaHimnosCategoria({
    Key? key,
    required this.categoria,
  }) : super(key: key);

  @override
  State<PantallaHimnosCategoria> createState() =>
      _PantallaHimnosCategoriaState();
}

class _PantallaHimnosCategoriaState extends State<PantallaHimnosCategoria> {
  List<Himno>? _himnosCategoria;
  bool _estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarHimnosCategoria();
  }

  Future<void> _cargarHimnosCategoria() async {
    try {
      final provider = context.read<ProviderCategorias>();
      final himnos = await provider.obtenerHimnosCategoria(widget.categoria);

      if (mounted) {
        setState(() {
          _himnosCategoria = himnos;
          _estaCargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _estaCargando = false;
        });
      }
      print('Error cargando himnos de categoría: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: esModoOscuro 
          ? ColoresApp.fondoOscuro 
          : ColoresApp.fondoPrimario,
      appBar: AppBar(
        backgroundColor: esModoOscuro 
            ? ColoresApp.fondoOscuro 
            : ColoresApp.fondoPrimario,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: esModoOscuro 
                ? ColoresApp.textoBlanco 
                : ColoresApp.textoPrimario,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoria.nombre,
              style: TextStyle(
                color: esModoOscuro 
                    ? ColoresApp.textoBlanco 
                    : ColoresApp.textoPrimario,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${widget.categoria.cantidadHimnos} himnos',
              style: TextStyle(
                color: esModoOscuro 
                    ? ColoresApp.textoBlancoSecundario 
                    : ColoresApp.textoSecundario,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: _construirCuerpo(esModoOscuro),
    );
  }

  Widget _construirCuerpo(bool esModoOscuro) {
    if (_estaCargando) {
      return IndicadorCarga(
        mensaje: 'Cargando himnos de la categoría...',
        esModoOscuro: esModoOscuro,
      );
    }

    if (_himnosCategoria == null || _himnosCategoria!.isEmpty) {
      return EstadoVacio(
        icono: Icons.library_music_outlined,
        titulo: 'No se encontraron himnos',
        subtitulo: 'Esta categoría no contiene himnos\n'
            'o los archivos no están disponibles',
        esModoOscuro: esModoOscuro,
      );
    }

    return Consumer<ProviderHimnos>(
      builder: (context, providerHimnos, child) {
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: _himnosCategoria!.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: esModoOscuro 
                ? ColoresApp.bordeOscuro 
                : ColoresApp.divisor,
          ),
          itemBuilder: (context, index) {
            final himno = _himnosCategoria![index];
            final resultado = ResultadoBusqueda(himno: himno);

            return Container(
              decoration: BoxDecoration(
                color: esModoOscuro
                    ? ColoresApp.fondoTarjeta.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TarjetaHimno(
                resultado: resultado,
                esModoOscuro: esModoOscuro,
              ),
            );
          },
        );
      },
    );
  }
}
