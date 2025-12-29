import 'package:flutter/material.dart';
import '/../../../configuracion/temas/colores_app.dart';

/// Widget que permite ajustar el tamaño de la fuente de la letra
class ControlesTamanioFuente extends StatelessWidget {
  final double tamanioActual;
  final VoidCallback alAumentar;
  final VoidCallback alDisminuir;
  final bool esModoOscuro;

  const ControlesTamanioFuente({
    Key? key,
    required this.tamanioActual,
    required this.alAumentar,
    required this.alDisminuir,
    required this.esModoOscuro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: alDisminuir,
            icon: Icon(
              Icons.text_decrease,
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.textoSecundario,
              size: 30,
            ),
            tooltip: 'Disminuir tamaño de texto',
          ),
          Text(
            '${tamanioActual.round()}',
            style: TextStyle(
              color: esModoOscuro 
                  ? ColoresApp.textoBlanco 
                  : ColoresApp.textoPrimario,
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: alAumentar,
            icon: Icon(
              Icons.text_increase,
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.textoSecundario,
              size: 30,
            ),
            tooltip: 'Aumentar tamaño de texto',
          ),
        ],
      ),
    );
  }
}
