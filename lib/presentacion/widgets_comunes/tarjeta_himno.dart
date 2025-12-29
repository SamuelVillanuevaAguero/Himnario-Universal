import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../configuracion/temas/colores_app.dart';
import '../../datos/modelos/resultado_busqueda.dart';
import '../../nucleo/constantes/constantes_app.dart';
import '../providers/provider_himnos.dart';
import '../pantallas/detalle_himno/pantalla_detalle_himno.dart';

/// Widget reutilizable para mostrar una tarjeta de himno
class TarjetaHimno extends StatelessWidget {
  final ResultadoBusqueda resultado;
  final bool esModoOscuro;
  final bool mostrarCoincidencia;

  const TarjetaHimno({
    Key? key,
    required this.resultado,
    required this.esModoOscuro,
    this.mostrarCoincidencia = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final himno = resultado.himno;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: _construirNumeroHimno(),
      title: Text(
        himno.titulo,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: esModoOscuro 
              ? ColoresApp.textoBlanco 
              : ColoresApp.textoPrimario,
        ),
      ),
      subtitle: _construirSubtitulo(),
      trailing: _construirBotonFavorito(context),
      onTap: () => _navegarADetalle(context),
    );
  }

  Widget _construirNumeroHimno() {
    final himno = resultado.himno;
    
    return SizedBox(
      width: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            himno.numero.toString(),
            style: TextStyle(
              fontSize: 16,
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.textoSecundario,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (himno.tieneAudio) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.music_note,
              size: 16,
              color: esModoOscuro 
                  ? ColoresApp.primarioClaro 
                  : ColoresApp.primario,
            ),
          ],
        ],
      ),
    );
  }

  Widget? _construirSubtitulo() {
    final himno = resultado.himno;
    final widgets = <Widget>[];

    // Mostrar audio disponible
    if (himno.tieneAudio) {
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.headphones,
              size: 14,
              color: esModoOscuro 
                  ? ColoresApp.primarioClaro 
                  : ColoresApp.primario,
            ),
            const SizedBox(width: 4),
            Text(
              ConstantesApp.textoAudioDisponible,
              style: TextStyle(
                fontSize: 12,
                color: esModoOscuro 
                    ? ColoresApp.primarioClaro 
                    : ColoresApp.primario,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar tipo de coincidencia si es búsqueda
    if (mostrarCoincidencia && resultado.tipoCoindicencia != null) {
      if (widgets.isNotEmpty) {
        widgets.add(const SizedBox(height: 2));
      }
      widgets.add(_construirInfoCoincidencia());
    }

    return widgets.isEmpty 
        ? null 
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          );
  }

  Widget _construirInfoCoincidencia() {
    return Row(
      children: [
        _construirIconoCoincidencia(),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            resultado.obtenerDescripcionCoindicencia(),
            style: TextStyle(
              fontSize: 12,
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.textoSecundario,
              fontStyle: resultado.tipoCoindicencia == TipoCoindicencia.letra
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _construirIconoCoincidencia() {
    IconData icono;
    Color color = esModoOscuro 
        ? ColoresApp.primarioClaro 
        : ColoresApp.primario;

    switch (resultado.tipoCoindicencia!) {
      case TipoCoindicencia.numero:
        icono = Icons.tag;
        break;
      case TipoCoindicencia.titulo:
        icono = Icons.book;
        break;
      case TipoCoindicencia.letra:
        icono = Icons.lyrics;
        color = Colors.orange;
        break;
    }

    return Icon(
      icono,
      size: 14,
      color: color,
    );
  }

  Widget _construirBotonFavorito(BuildContext context) {
    final himno = resultado.himno;

    return GestureDetector(
      onTap: () => _alternarFavorito(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          himno.esFavorito ? Icons.favorite : Icons.favorite_border,
          color: himno.esFavorito 
              ? ColoresApp.favorito 
              : ColoresApp.favoritoInactivo,
          size: 25,
        ),
      ),
    );
  }

  Future<void> _alternarFavorito(BuildContext context) async {
    try {
      final provider = context.read<ProviderHimnos>();
      final nuevoEstado = await provider.alternarFavorito(resultado.himno.numero);

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

  void _navegarADetalle(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaDetalleHimno(
          himno: resultado.himno,
        ),
      ),
    );
  }
}
