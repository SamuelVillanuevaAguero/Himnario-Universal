import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../configuracion/temas/colores_app.dart';
import '/../../nucleo/constantes/constantes_app.dart';
import '/../../presentacion/providers/provider_himnos.dart';
import 'widgets/lista_favoritos.dart';

/// Pantalla que muestra los himnos marcados como favoritos
class PantallaFavoritos extends StatelessWidget {
  const PantallaFavoritos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: esModoOscuro 
          ? ColoresApp.fondoOscuro 
          : ColoresApp.fondoPrimario,
      body: SafeArea(
        child: Column(
          children: [
            _construirEncabezado(context, esModoOscuro),
            const SizedBox(height: 20),
            const Expanded(child: ListaFavoritos()),
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
          const Icon(
            Icons.favorite,
            color: ColoresApp.favorito,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            ConstantesApp.tituloFavoritos,
            style: TextStyle(
              fontSize: 24,
              color: esModoOscuro 
                  ? ColoresApp.textoBlanco 
                  : ColoresApp.textoPrimario,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _construirContadorFavoritos(context, esModoOscuro),
        ],
      ),
    );
  }

  Widget _construirContadorFavoritos(BuildContext context, bool esModoOscuro) {
    return Consumer<ProviderHimnos>(
      builder: (context, provider, child) {
        if (!provider.estaCargado) return const SizedBox.shrink();

        final cantidadFavoritos = provider.todosLosHimnos
            .where((h) => h.esFavorito)
            .length;

        if (cantidadFavoritos == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ColoresApp.favorito.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$cantidadFavoritos',
            style: const TextStyle(
              color: ColoresApp.favorito,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}
