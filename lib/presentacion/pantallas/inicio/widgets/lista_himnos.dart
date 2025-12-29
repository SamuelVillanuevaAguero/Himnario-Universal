import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../nucleo/constantes/constantes_app.dart';
import '/../../../presentacion/providers/provider_himnos.dart';
import '/../../../presentacion/widgets_comunes/indicador_carga.dart';
import '/../../../presentacion/widgets_comunes/estado_vacio.dart';
import '/../../../presentacion/widgets_comunes/tarjeta_himno.dart';

/// Widget que muestra la lista de himnos con búsqueda
class ListaHimnos extends StatelessWidget {
  const ListaHimnos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProviderHimnos>(
      builder: (context, provider, child) {
        // Estado de carga
        if (provider.estaCargando) {
          return IndicadorCarga(
            mensaje: ConstantesApp.textoCargandoHimnos,
            esModoOscuro: esModoOscuro,
          );
        }

        // Error
        if (provider.tieneError) {
          return EstadoVacio(
            icono: Icons.error_outline,
            titulo: 'Error al cargar himnos',
            subtitulo: provider.mensajeError ?? 
                'Ha ocurrido un error inesperado',
            esModoOscuro: esModoOscuro,
            accionPersonalizada: ElevatedButton.icon(
              onPressed: () => provider.recargar(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          );
        }

        // Sin himnos
        if (provider.todosLosHimnos.isEmpty) {
          return EstadoVacio(
            icono: Icons.library_music_outlined,
            titulo: ConstantesApp.textoNoHimnosEncontrados,
            subtitulo: 'Verifique que los archivos .txt estén\n'
                'en la carpeta assets/HIMNOS/',
            esModoOscuro: esModoOscuro,
          );
        }

        // Sin resultados de búsqueda
        if (provider.resultadosBusqueda.isEmpty && 
            provider.terminoBusqueda.isNotEmpty) {
          return EstadoVacio(
            icono: Icons.search_off,
            titulo: ConstantesApp.textoNoResultadosBusqueda,
            subtitulo: 'Intenta buscar por:\n'
                '• Número del himno\n'
                '• Título del himno\n'
                '• Palabras de la letra',
            esModoOscuro: esModoOscuro,
          );
        }

        // Lista de himnos
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: provider.resultadosBusqueda.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: esModoOscuro 
                ? ColoresApp.bordeOscuro 
                : ColoresApp.divisor,
          ),
          itemBuilder: (context, index) {
            final resultado = provider.resultadosBusqueda[index];
            return TarjetaHimno(
              resultado: resultado,
              esModoOscuro: esModoOscuro,
              mostrarCoincidencia: provider.terminoBusqueda.isNotEmpty,
            );
          },
        );
      },
    );
  }
}
