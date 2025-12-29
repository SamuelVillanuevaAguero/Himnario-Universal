import 'package:flutter/material.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../datos/modelos/himno.dart';

/// Widget que muestra la letra del himno con scroll
class LetraHimno extends StatelessWidget {
  final Himno himno;
  final double tamanioFuente;
  final bool esModoOscuro;

  const LetraHimno({
    Key? key,
    required this.himno,
    required this.tamanioFuente,
    required this.esModoOscuro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Center(
            child: Text(
              himno.letra,
              style: TextStyle(
                fontSize: tamanioFuente,
                color: esModoOscuro 
                    ? ColoresApp.textoBlanco 
                    : ColoresApp.textoPrimario,
                height: 1.6,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
