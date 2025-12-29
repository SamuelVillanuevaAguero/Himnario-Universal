import 'package:flutter/material.dart';
import '../../configuracion/temas/colores_app.dart';

/// Widget reutilizable para mostrar un estado vacío
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final String? mensajeInformativo;
  final Widget? accionPersonalizada;
  final bool esModoOscuro;

  const EstadoVacio({
    Key? key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.mensajeInformativo,
    this.accionPersonalizada,
    this.esModoOscuro = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 64,
              color: (esModoOscuro
                      ? ColoresApp.textoBlancoSecundario
                      : ColoresApp.textoSecundario)
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 20,
                color: esModoOscuro
                    ? ColoresApp.textoBlanco
                    : ColoresApp.textoPrimario,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitulo!,
                style: TextStyle(
                  fontSize: 16,
                  color: esModoOscuro
                      ? ColoresApp.textoBlancoSecundario
                      : ColoresApp.textoSecundario,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (mensajeInformativo != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: (esModoOscuro
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (esModoOscuro
                            ? ColoresApp.primarioClaro
                            : ColoresApp.primario)
                        .withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: esModoOscuro
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        mensajeInformativo!,
                        style: TextStyle(
                          fontSize: 14,
                          color: esModoOscuro
                              ? ColoresApp.primarioClaro
                              : ColoresApp.primario,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (accionPersonalizada != null) ...[
              const SizedBox(height: 24),
              accionPersonalizada!,
            ],
          ],
        ),
      ),
    );
  }
}
