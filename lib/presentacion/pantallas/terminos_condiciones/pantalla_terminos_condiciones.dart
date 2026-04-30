import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../configuracion/temas/colores_app.dart';
import '../../../nucleo/constantes/constantes_app.dart';

/// Pantalla de términos y condiciones mostrada al iniciar por primera vez
class PantallaTerminosCondiciones extends StatefulWidget {
  final VoidCallback alAceptar;

  const PantallaTerminosCondiciones({
    Key? key,
    required this.alAceptar,
  }) : super(key: key);

  @override
  State<PantallaTerminosCondiciones> createState() =>
      _PantallaTerminosCondicionesState();
}

class _PantallaTerminosCondicionesState
    extends State<PantallaTerminosCondiciones> {
  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: esModoOscuro
          ? ColoresApp.fondoOscuro.withOpacity(0.95)
          : Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: esModoOscuro ? ColoresApp.fondoTarjeta : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _construirEncabezado(esModoOscuro),
              _construirContenido(esModoOscuro),
              _construirBotonAceptar(esModoOscuro),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEncabezado(bool esModoOscuro) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      child: Column(
        children: [
          // Icono de la app
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (esModoOscuro
                      ? ColoresApp.primarioClaro
                      : ColoresApp.primario)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 45,
              color: esModoOscuro
                  ? ColoresApp.primarioClaro
                  : ColoresApp.primario,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${ConstantesApp.nombreApp} actualizará sus Términos y Condiciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: esModoOscuro
                    ? ColoresApp.textoBlanco
                    : ColoresApp.textoPrimario,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirContenido(bool esModoOscuro) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: esModoOscuro
                      ? ColoresApp.textoBlancoSecundario
                      : ColoresApp.textoSecundario,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Las actualizaciones clave',
                    style: TextStyle(
                      color: esModoOscuro
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' incluyen más información sobre lo siguiente:',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _construirPunto(
              esModoOscuro: esModoOscuro,
              texto: 'Esta aplicación es únicamente una herramienta de apoyo '
                  'y NO sustituye el himnario físico oficial de la Iglesia Universal.',
            ),
            const SizedBox(height: 16),

            _construirPunto(
              esModoOscuro: esModoOscuro,
              texto: 'El uso de esta aplicación debe complementar, no reemplazar, '
                  'la participación activa en los servicios religiosos.',
            ),
            const SizedBox(height: 16),

            // ── Punto 4 corregido ──
            _construirPunto(
              esModoOscuro: esModoOscuro,
              texto: 'Las letras e himnos son obras de dominio público. '
                  'Las grabaciones de audio son producción original del equipo de desarrollo.',
            ),
            const SizedBox(height: 16),

            _construirPunto(
              esModoOscuro: esModoOscuro,
              texto: 'Esta aplicación no recopila ni comparte información personal. '
                  'Los datos se guardan únicamente en tu dispositivo.',
            ),
            const SizedBox(height: 24),

            // ── Nota final con enlaces a T&C y Privacidad ──
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: esModoOscuro
                        ? ColoresApp.textoBlancoSecundario
                        : ColoresApp.textoSecundario,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Al seleccionar "Aceptar", aceptas los '),
                    TextSpan(
                      text: 'Términos y Condiciones',
                      style: TextStyle(
                        color: esModoOscuro
                            ? ColoresApp.primarioClaro
                            : ColoresApp.primario,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _abrirUrl(
                              context,
                              ConstantesApp.urlTerminosCondiciones,
                            ),
                    ),
                    const TextSpan(text: ' y la '),
                    TextSpan(
                      text: 'Política de Privacidad',
                      style: TextStyle(
                        color: esModoOscuro
                            ? ColoresApp.primarioClaro
                            : ColoresApp.primario,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _abrirUrl(
                              context,
                              ConstantesApp.urlPoliticaPrivacidad,
                            ),
                    ),
                    const TextSpan(
                        text: '. Para más información contáctanos al '),
                    TextSpan(
                      text: ConstantesApp.telefonoContacto,
                      style: TextStyle(
                        color: esModoOscuro
                            ? ColoresApp.primarioClaro
                            : ColoresApp.primario,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _construirBotonAceptar(bool esModoOscuro) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.alAceptar,
          style: ElevatedButton.styleFrom(
            backgroundColor: esModoOscuro
                ? ColoresApp.primarioClaro
                : ColoresApp.primario,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Aceptar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _construirPunto({
    required bool esModoOscuro,
    required String texto,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: esModoOscuro
                ? ColoresApp.textoBlancoSecundario
                : ColoresApp.textoSecundario,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 14,
              color: esModoOscuro
                  ? ColoresApp.textoBlancoSecundario
                  : ColoresApp.textoSecundario,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _abrirUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo abrir el enlace')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}