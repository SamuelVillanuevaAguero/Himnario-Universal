import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../presentacion/providers/provider_categorias.dart';
import '/../../../presentacion/widgets_comunes/indicador_carga.dart';
import '/../../../presentacion/widgets_comunes/estado_vacio.dart';
import 'tarjeta_categoria.dart';

/// Widget que muestra la lista de categorías
class ListaCategorias extends StatelessWidget {
  const ListaCategorias({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProviderCategorias>(
      builder: (context, provider, child) {
        // Estado de carga
        if (provider.estaCargando) {
          return IndicadorCarga(
            mensaje: 'Cargando categorías...',
            esModoOscuro: esModoOscuro,
          );
        }

        // Error
        if (provider.tieneError) {
          return EstadoVacio(
            icono: Icons.error_outline,
            titulo: 'Error al cargar categorías',
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

        // Sin categorías
        if (provider.todasCategorias.isEmpty) {
          return EstadoVacio(
            icono: Icons.folder_outlined,
            titulo: 'No se encontraron categorías',
            subtitulo: 'Agrega archivos .txt en la carpeta\n'
                'assets/CATEGORIAS/ con los números\n'
                'de himnos de cada categoría',
            esModoOscuro: esModoOscuro,
            mensajeInformativo: 'Ejemplo: Categoria 1.txt',
          );
        }

        // Sin resultados de búsqueda
        if (provider.categoriasFiltradas.isEmpty && 
            provider.terminoBusqueda.isNotEmpty) {
          return EstadoVacio(
            icono: Icons.search_off,
            titulo: 'No se encontraron categorías',
            subtitulo: 'Intenta con otros términos de búsqueda',
            esModoOscuro: esModoOscuro,
            mensajeInformativo: 
                'Buscando en ${provider.todasCategorias.length} categorías',
          );
        }

        // Lista de categorías
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: provider.categoriasFiltradas.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: esModoOscuro 
                ? ColoresApp.bordeOscuro 
                : ColoresApp.divisor,
          ),
          itemBuilder: (context, index) {
            final categoria = provider.categoriasFiltradas[index];
            return TarjetaCategoria(
              categoria: categoria,
              esModoOscuro: esModoOscuro,
            );
          },
        );
      },
    );
  }
}
