import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../presentacion/providers/provider_himnos.dart';
import '/../../../presentacion/widgets_comunes/indicador_carga.dart';
import '/../../../presentacion/widgets_comunes/estado_vacio.dart';
import '/../../../presentacion/widgets_comunes/tarjeta_himno.dart';
import '/../../../datos/modelos/resultado_busqueda.dart';

/// Widget que muestra la lista de himnos favoritos
class ListaFavoritos extends StatelessWidget {
  const ListaFavoritos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProviderHimnos>(
      builder: (context, provider, child) {
        // Estado de carga
        if (provider.estaCargando) {
          return IndicadorCarga(
            mensaje: 'Cargando favoritos...',
            esModoOscuro: esModoOscuro,
          );
        }

        // Filtrar solo favoritos
        final himnosFavoritos = provider.todosLosHimnos
            .where((h) => h.esFavorito)
            .toList();

        // Sin favoritos
        if (himnosFavoritos.isEmpty) {
          return EstadoVacio(
            icono: Icons.favorite_border,
            titulo: 'No tienes himnos favoritos',
            subtitulo: 'Marca tus himnos favoritos desde la\n'
                'lista principal para verlos aquí',
            esModoOscuro: esModoOscuro,
            mensajeInformativo: 'Toca el corazón para agregar favoritos',
          );
        }

        // Lista de favoritos
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: himnosFavoritos.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: esModoOscuro 
                ? ColoresApp.bordeOscuro 
                : ColoresApp.divisor,
          ),
          itemBuilder: (context, index) {
            final himno = himnosFavoritos[index];
            final resultado = ResultadoBusqueda(himno: himno);
            
            return TarjetaHimno(
              resultado: resultado,
              esModoOscuro: esModoOscuro,
            );
          },
        );
      },
    );
  }
}
