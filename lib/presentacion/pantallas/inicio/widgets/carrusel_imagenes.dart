import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../nucleo/constantes/constantes_app.dart';

/// Widget de carrusel de imágenes con versículo bíblico
class CarruselImagenes extends StatefulWidget {
  const CarruselImagenes({Key? key}) : super(key: key);

  @override
  State<CarruselImagenes> createState() => _CarruselImagenesState();
}

class _CarruselImagenesState extends State<CarruselImagenes> {
  final PageController _controladorPagina = PageController();
  int _indiceImagenActual = 0;
  Timer? _temporizadorCarrusel;
  List<String> _imagenes = [];
  bool _estaAutoScrolling = false;

  @override
  void initState() {
    super.initState();
    _cargarImagenes();
  }

  @override
  void dispose() {
    _temporizadorCarrusel?.cancel();
    _controladorPagina.dispose();
    super.dispose();
  }

  Future<void> _cargarImagenes() async {
    try {
      final contenidoManifest = await rootBundle.loadString(
        ConstantesApp.manifestAssets,
      );
      final Map<String, dynamic> mapaManifest = json.decode(contenidoManifest);

      final archivosImagen = mapaManifest.keys
          .where((String ruta) =>
              ruta.startsWith(ConstantesApp.rutaImagenes) &&
              ConstantesApp.extensionesImagen.any((ext) => ruta.endsWith(ext)))
          .toList();

      if (mounted) {
        setState(() {
          _imagenes = archivosImagen;
        });

        if (_imagenes.length > 1) {
          _iniciarCarrusel();
        }
      }
    } catch (e) {
      print('Error cargando imágenes del carrusel: $e');
    }
  }

  void _iniciarCarrusel() {
    _temporizadorCarrusel = Timer.periodic(
      const Duration(seconds: ConstantesApp.duracionCarruselSegundos),
      (timer) {
        if (!mounted || !_controladorPagina.hasClients) return;

        final siguienteIndice = (_indiceImagenActual + 1) % _imagenes.length;
        _estaAutoScrolling = true;

        _controladorPagina.animateToPage(
          siguienteIndice,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ).then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _estaAutoScrolling = false;
          });
        });
      },
    );
  }

  void _detenerCarrusel() {
    _temporizadorCarrusel?.cancel();
  }

  void _reiniciarCarrusel() {
    _detenerCarrusel();
    if (mounted && _imagenes.length > 1) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _iniciarCarrusel();
        }
      });
    }
  }

  void _alCambiarPagina(int indice) {
    if (!mounted) return;

    setState(() {
      _indiceImagenActual = indice;
    });

    // Si no es auto-scroll, el usuario deslizó manualmente
    if (!_estaAutoScrolling) {
      _reiniciarCarrusel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ConstantesApp.alturaCarrusel,
      child: Stack(
        children: [
          // Imágenes del carrusel
          _imagenes.isNotEmpty
              ? PageView.builder(
                  controller: _controladorPagina,
                  onPageChanged: _alCambiarPagina,
                  itemCount: _imagenes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(_imagenes[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: ColoresCarrusel.placeholder,
                  child: const Icon(
                    Icons.image,
                    size: 64,
                    color: ColoresCarrusel.iconoPlaceholder,
                  ),
                ),

          // Overlay con gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ColoresCarrusel.overlaySuperior,
                  ColoresCarrusel.overlayInferior,
                ],
              ),
            ),
          ),

          // Texto overlay (versículo)
          Positioned(
            left: 20,
            right: 20,
            bottom: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ConstantesApp.versiculoTexto,
                  style: const TextStyle(
                    color: ColoresCarrusel.textoOverlay,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ConstantesApp.versiculoReferencia,
                  style: const TextStyle(
                    color: ColoresCarrusel.textoOverlay,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Indicadores del carrusel
          if (_imagenes.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _imagenes.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _indiceImagenActual == entry.key
                          ? ColoresCarrusel.indicadorActivo
                          : ColoresCarrusel.indicadorInactivo,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
