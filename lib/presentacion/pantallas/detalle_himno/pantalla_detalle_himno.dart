import 'package:flutter/material.dart';
import '/../../configuracion/temas/colores_app.dart';
import '/../../datos/modelos/himno.dart';
import 'widgets/encabezado_himno.dart';
import 'widgets/letra_himno.dart';
import 'widgets/controles_audio.dart';
import 'widgets/controles_tamanio_fuente.dart';

/// Pantalla de detalle que muestra un himno completo con letra y audio
class PantallaDetalleHimno extends StatefulWidget {
  final Himno himno;

  const PantallaDetalleHimno({
    Key? key,
    required this.himno,
  }) : super(key: key);

  @override
  State<PantallaDetalleHimno> createState() => _PantallaDetalleHimnoState();
}

class _PantallaDetalleHimnoState extends State<PantallaDetalleHimno> {
  double _tamanioFuente = 18.0;

  void _aumentarFuente() {
    if (_tamanioFuente < 28) {
      setState(() {
        _tamanioFuente += 2;
      });
    }
  }

  void _disminuirFuente() {
    if (_tamanioFuente > 12) {
      setState(() {
        _tamanioFuente -= 2;
      });
    }
  }

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
            EncabezadoHimno(
              himno: widget.himno,
              esModoOscuro: esModoOscuro,
            ),
            LetraHimno(
              himno: widget.himno,
              tamanioFuente: _tamanioFuente,
              esModoOscuro: esModoOscuro,
            ),
            ControlesAudio(
              himno: widget.himno,
              esModoOscuro: esModoOscuro,
            ),
            ControlesTamanioFuente(
              tamanioActual: _tamanioFuente,
              alAumentar: _aumentarFuente,
              alDisminuir: _disminuirFuente,
              esModoOscuro: esModoOscuro,
            ),
          ],
        ),
      ),
    );
  }
}
