import 'package:flutter/material.dart';
import '../../configuracion/temas/colores_app.dart';

/// Widget reutilizable para mostrar un indicador de carga
class IndicadorCarga extends StatelessWidget {
  final String? mensaje;
  final bool esModoOscuro;

  const IndicadorCarga({
    Key? key,
    this.mensaje,
    this.esModoOscuro = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.primario,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(
              mensaje!,
              style: TextStyle(
                fontSize: 16,
                color: esModoOscuro
                    ? ColoresApp.textoBlancoSecundario
                    : ColoresApp.textoSecundario,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
