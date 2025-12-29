import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../nucleo/constantes/constantes_app.dart';
import '/../../../datos/modelos/himno.dart';
import '/../../../presentacion/providers/provider_reproductor_audio.dart';

/// Widget que muestra los controles de reproducción de audio
class ControlesAudio extends StatelessWidget {
  final Himno himno;
  final bool esModoOscuro;

  const ControlesAudio({
    Key? key,
    required this.himno,
    required this.esModoOscuro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!himno.tieneAudio) {
      return _construirAudioNoDisponible();
    }

    return Consumer<ProviderReproductorAudio>(
      builder: (context, reproductor, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: esModoOscuro 
                ? ColoresApp.fondoTarjeta 
                : ColoresApp.superficie,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: esModoOscuro 
                  ? ColoresApp.bordeOscuro 
                  : ColoresApp.borde,
            ),
          ),
          child: Column(
            children: [
              _construirEncabezadoAudio(),
              const SizedBox(height: 15),
              _construirBarraProgreso(reproductor),
              const SizedBox(height: 10),
              _construirBotonesControl(context, reproductor),
            ],
          ),
        );
      },
    );
  }

  Widget _construirEncabezadoAudio() {
    return Row(
      children: [
        Icon(
          Icons.music_note,
          color: esModoOscuro 
              ? ColoresApp.primarioClaro 
              : ColoresApp.notaMusical,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          ConstantesApp.textoAudioDisponible,
          style: TextStyle(
            color: esModoOscuro 
                ? ColoresApp.textoBlanco 
                : ColoresApp.textoPrimario,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _construirBarraProgreso(ProviderReproductorAudio reproductor) {
    return Row(
      children: [
        Text(
          reproductor.posicionFormateada,
          style: TextStyle(
            color: esModoOscuro 
                ? ColoresApp.textoBlancoSecundario 
                : ColoresApp.textoSecundario,
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Slider(
            value: reproductor.progreso,
            onChanged: (valor) => reproductor.buscarPosicion(valor),
            activeColor: esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.sliderActivo,
            inactiveColor: esModoOscuro
                ? ColoresApp.textoBlancoTerciario.withOpacity(0.3)
                : ColoresApp.sliderInactivo,
          ),
        ),
        Text(
          reproductor.duracionFormateada,
          style: TextStyle(
            color: esModoOscuro 
                ? ColoresApp.textoBlancoSecundario 
                : ColoresApp.textoSecundario,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _construirBotonesControl(
    BuildContext context,
    ProviderReproductorAudio reproductor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => reproductor.detener(),
          icon: Icon(
            Icons.stop,
            color: esModoOscuro 
                ? ColoresApp.textoBlanco 
                : ColoresApp.textoPrimario,
            size: 30,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.primario,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () => reproductor.reproducirPausar(himno.rutaAudio!),
            icon: Icon(
              reproductor.estaReproduciendo ? Icons.pause : Icons.play_arrow,
              color: esModoOscuro 
                  ? ColoresApp.fondoOscuro 
                  : ColoresApp.textoBlanco,
              size: 40,
            ),
          ),
        ),
        Icon(
          Icons.volume_up,
          color: esModoOscuro 
              ? ColoresApp.textoBlancoTerciario 
              : ColoresApp.textoTerciario,
          size: 30,
        ),
      ],
    );
  }

  Widget _construirAudioNoDisponible() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? ColoresApp.fondoTarjeta 
            : ColoresApp.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: esModoOscuro 
              ? ColoresApp.bordeOscuro 
              : ColoresApp.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.music_off,
            color: esModoOscuro 
                ? ColoresApp.textoBlancoSecundario 
                : ColoresApp.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            ConstantesApp.mensajeAudioNoDisponible,
            style: TextStyle(
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.error,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
