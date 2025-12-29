import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../nucleo/constantes/constantes_app.dart';
import '/../../../datos/modelos/himno.dart';
import '/../../../presentacion/providers/provider_himnos.dart';

/// Widget que muestra el encabezado con información del himno
class EncabezadoHimno extends StatelessWidget {
  final Himno himno;
  final bool esModoOscuro;

  const EncabezadoHimno({
    Key? key,
    required this.himno,
    required this.esModoOscuro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            esModoOscuro 
                ? ColoresApp.fondoOscuro 
                : ColoresApp.fondoPrimario,
            esModoOscuro 
                ? ColoresApp.fondoOscuro 
                : ColoresApp.fondoPrimario,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: esModoOscuro 
                  ? ColoresApp.textoBlanco 
                  : ColoresApp.textoSecundario,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No. ${himno.numero}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: esModoOscuro 
                        ? ColoresApp.textoBlanco 
                        : ColoresApp.textoPrimario,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  himno.titulo,
                  style: TextStyle(
                    fontSize: 18,
                    color: esModoOscuro 
                        ? ColoresApp.textoBlancoSecundario 
                        : ColoresApp.textoPrimario,
                  ),
                ),
                if (himno.tonoSugerido.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tono: ${himno.tonoSugerido}',
                    style: TextStyle(
                      fontSize: 14,
                      color: esModoOscuro 
                          ? ColoresApp.textoBlancoSecundario 
                          : ColoresApp.textoSecundario,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _construirBotonFavorito(context),
        ],
      ),
    );
  }

  Widget _construirBotonFavorito(BuildContext context) {
    return Consumer<ProviderHimnos>(
      builder: (context, provider, child) {
        return IconButton(
          onPressed: () => _alternarFavorito(context, provider),
          icon: Icon(
            himno.esFavorito ? Icons.favorite : Icons.favorite_border,
            color: himno.esFavorito 
                ? ColoresApp.favorito 
                : ColoresApp.favoritoInactivo,
            size: 28,
          ),
        );
      },
    );
  }

  Future<void> _alternarFavorito(
    BuildContext context,
    ProviderHimnos provider,
  ) async {
    try {
      final nuevoEstado = await provider.alternarFavorito(himno.numero);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nuevoEstado
                  ? ConstantesApp.mensajeHimnoAgregadoFavoritos
                  : ConstantesApp.mensajeHimnoRemovidoFavoritos,
            ),
            duration: const Duration(
              seconds: ConstantesApp.duracionSnackbarSegundos,
            ),
            backgroundColor: nuevoEstado 
                ? ColoresApp.snackbarExito 
                : ColoresApp.snackbarError,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ConstantesApp.mensajeErrorActualizarFavoritos}: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }
}
