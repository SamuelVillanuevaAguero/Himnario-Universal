import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/../../configuracion/temas/colores_app.dart';
import '/../../nucleo/constantes/constantes_app.dart';

/// Pantalla que muestra información acerca de la aplicación
class PantallaAcercaDe extends StatelessWidget {
  const PantallaAcercaDe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: esModoOscuro 
          ? ColoresApp.fondoOscuro 
          : ColoresApp.fondoPrimario,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _construirEncabezado(context, esModoOscuro),
              const SizedBox(height: 30),
              _construirContenido(context, esModoOscuro),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEncabezado(BuildContext context, bool esModoOscuro) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.primario,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            ConstantesApp.tituloAcercaDe,
            style: TextStyle(
              fontSize: 24,
              color: esModoOscuro 
                  ? ColoresApp.textoBlanco 
                  : ColoresApp.textoPrimario,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirContenido(BuildContext context, bool esModoOscuro) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirTarjetaLogo(esModoOscuro),
          const SizedBox(height: 30),
          _construirTarjetaInformacion(esModoOscuro),
          const SizedBox(height: 20),
          _construirTarjetaContacto(context, esModoOscuro),
          const SizedBox(height: 20),
          _construirTarjetaVersion(esModoOscuro),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _construirTarjetaLogo(bool esModoOscuro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? ColoresApp.superficieOscura 
            : ColoresApp.fondoSecundario,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: esModoOscuro 
              ? ColoresApp.bordeOscuro 
              : ColoresApp.borde,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 80,
            color: esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.primario,
          ),
          const SizedBox(height: 15),
          Text(
            ConstantesApp.nombreApp,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: esModoOscuro 
                  ? ColoresApp.textoBlanco 
                  : ColoresApp.textoPrimario,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaInformacion(bool esModoOscuro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? ColoresApp.fondoTarjeta 
            : ColoresApp.fondoSecundario,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: esModoOscuro 
              ? ColoresApp.bordeOscuro 
              : ColoresApp.borde,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: esModoOscuro 
                    ? ColoresApp.primarioClaro 
                    : ColoresApp.primario,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Acerca de la Aplicación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: esModoOscuro 
                      ? ColoresApp.textoBlanco 
                      : ColoresApp.textoPrimario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            ConstantesApp.descripcionApp,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.textoSecundario,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 15),
          Text(
            ConstantesApp.propostoApp,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.textoSecundario,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaContacto(BuildContext context, bool esModoOscuro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? ColoresApp.fondoTarjeta 
            : ColoresApp.fondoSecundario,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: esModoOscuro 
              ? ColoresApp.bordeOscuro 
              : ColoresApp.borde,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_phone_outlined,
                color: esModoOscuro 
                    ? ColoresApp.primarioClaro 
                    : ColoresApp.primario,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Contacto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: esModoOscuro 
                      ? ColoresApp.textoBlanco 
                      : ColoresApp.textoPrimario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Para más información, sugerencias o reportar algún problema, puede contactarnos a través de:',
            style: TextStyle(
              fontSize: 14,
              color: esModoOscuro 
                  ? ColoresApp.textoBlancoSecundario 
                  : ColoresApp.textoSecundario,
            ),
          ),
          const SizedBox(height: 15),
          InkWell(
            onTap: () => _llamarTelefono(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: (esModoOscuro 
                        ? ColoresApp.primarioClaro 
                        : ColoresApp.primario)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: esModoOscuro 
                      ? ColoresApp.primarioClaro 
                      : ColoresApp.primario,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: esModoOscuro 
                        ? ColoresApp.primarioClaro 
                        : ColoresApp.primario,
                    size: 24,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teléfono',
                        style: TextStyle(
                          fontSize: 12,
                          color: esModoOscuro 
                              ? ColoresApp.textoBlancoSecundario 
                              : ColoresApp.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ConstantesApp.telefonoContacto,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: esModoOscuro 
                              ? ColoresApp.primarioClaro 
                              : ColoresApp.primario,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: esModoOscuro 
                        ? ColoresApp.primarioClaro 
                        : ColoresApp.primario,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _enviarWhatsApp(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF25D366),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF25D366),
                    size: 24,
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhatsApp',
                        style: TextStyle(
                          fontSize: 12,
                          color: esModoOscuro 
                              ? ColoresApp.textoBlancoSecundario 
                              : ColoresApp.textoSecundario,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ConstantesApp.telefonoContacto,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF25D366),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF25D366),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirTarjetaVersion(bool esModoOscuro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? ColoresApp.fondoTarjeta 
            : ColoresApp.fondoSecundario,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: esModoOscuro 
              ? ColoresApp.bordeOscuro 
              : ColoresApp.borde,
        ),
      ),
      child: Column(
        children: [
          _construirItemVersion(
            icono: Icons.apps,
            titulo: 'Versión',
            valor: ConstantesApp.versionApp,
            esModoOscuro: esModoOscuro,
          ),
          const SizedBox(height: 15),
          Divider(
            color: esModoOscuro 
                ? ColoresApp.bordeOscuro 
                : ColoresApp.divisor,
          ),
          const SizedBox(height: 15),
          _construirItemVersion(
            icono: Icons.calendar_today,
            titulo: 'Última actualización',
            valor: ConstantesApp.fechaActualizacion,
            esModoOscuro: esModoOscuro,
          ),
          const SizedBox(height: 15),
          Divider(
            color: esModoOscuro 
                ? ColoresApp.bordeOscuro 
                : ColoresApp.divisor,
          ),
          const SizedBox(height: 15),
          _construirItemVersion(
            icono: Icons.code,
            titulo: 'Desarrollado con',
            valor: 'Flutter',
            esModoOscuro: esModoOscuro,
          ),
        ],
      ),
    );
  }

  Widget _construirItemVersion({
    required IconData icono,
    required String titulo,
    required String valor,
    required bool esModoOscuro,
  }) {
    return Row(
      children: [
        Icon(
          icono,
          color: esModoOscuro 
              ? ColoresApp.textoBlancoSecundario 
              : ColoresApp.textoSecundario,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            color: esModoOscuro 
                ? ColoresApp.textoBlancoSecundario 
                : ColoresApp.textoSecundario,
          ),
        ),
        const Spacer(),
        Text(
          valor,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: esModoOscuro 
                ? ColoresApp.textoBlanco 
                : ColoresApp.textoPrimario,
          ),
        ),
      ],
    );
  }

  Future<void> _llamarTelefono(BuildContext context) async {
    final Uri telUri = Uri(
      scheme: 'tel',
      path: ConstantesApp.telefonoContacto,
    );

    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        if (context.mounted) {
          _mostrarError(context, 'No se puede abrir el marcador telefónico');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarError(context, 'Error al intentar llamar: $e');
      }
    }
  }

  Future<void> _enviarWhatsApp(BuildContext context) async {
    final String telefono = ConstantesApp.telefonoContacto.replaceAll(RegExp(r'[^\d+]'), '');
    final String mensaje = Uri.encodeComponent('Hola, me comunico desde ${ConstantesApp.nombreApp}');
    final Uri whatsappUri = Uri.parse('https://wa.me/$telefono?text=$mensaje');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          _mostrarError(context, 'No se puede abrir WhatsApp. Asegúrate de tenerlo instalado.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarError(context, 'Error al abrir WhatsApp: $e');
      }
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: ColoresApp.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}