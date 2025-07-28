import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_colors.dart'; // Importar los colores centralizados

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double height;

  const ImageCarousel({
    Key? key,
    required this.images,
    this.height = 280,
  }) : super(key: key);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  Timer? _carouselTimer;
  bool _carouselStarted = false;
  bool _isAutoScrolling = false; // Para distinguir scroll automático vs manual

  _ImageCarouselState() {
    print('Constructor de _ImageCarouselState ejecutado'); // Debug constructor
  }

  @override
  void initState() {
    super.initState();
    print('ImageCarousel initState ejecutado'); // Debug básico
    print('Número de imágenes recibidas: ${widget.images.length}'); // Debug básico
    print('Imágenes: ${widget.images}'); // Debug básico
    
    // Esperar un frame antes de iniciar el carrusel para asegurar que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('PostFrameCallback ejecutado'); // Debug básico
      _startCarousel();
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startCarousel() {
    print('_startCarousel llamado'); // Debug
    print('mounted: $mounted'); // Debug
    print('widget.images.length: ${widget.images.length}'); // Debug
    
    if (widget.images.length > 1 && mounted) {
      print('Creando Timer.periodic'); // Debug
      _carouselTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        print('Timer tick automático'); // Debug
        
        if (mounted && _pageController.hasClients) {
          int nextIndex = (_currentImageIndex + 1) % widget.images.length;
          print('Auto-scroll a imagen: $nextIndex'); // Debug
          
          _isAutoScrolling = true; // Marcar como scroll automático
          _pageController.animateToPage(
            nextIndex,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          ).then((_) {
            // Después de completar la animación, resetear la bandera
            Future.delayed(Duration(milliseconds: 100), () {
              _isAutoScrolling = false;
            });
          });
        }
      });
      print('Timer creado correctamente'); // Debug
    }
  }

  void _stopCarousel() {
    print('Deteniendo carrusel'); // Debug
    _carouselTimer?.cancel();
  }

  void _restartCarousel() {
    print('Reiniciando carrusel por deslizamiento manual...'); // Debug
    _stopCarousel();
    if (mounted) {
      // Dar tiempo para que termine cualquier animación pendiente
      Future.delayed(Duration(milliseconds: 600), () {
        if (mounted) {
          print('Carrusel reiniciado después de deslizamiento manual'); // Debug
          _startCarousel();
        }
      });
    }
  }

  void _onPageChanged(int index) {
    print('Página cambiada a: $index, isAutoScrolling: $_isAutoScrolling'); // Debug
    
    if (mounted) {
      setState(() {
        _currentImageIndex = index;
      });
      
      // Si no es scroll automático, significa que el usuario deslizó manualmente
      if (!_isAutoScrolling) {
        print('Scroll manual detectado - reiniciando timer'); // Debug
        _restartCarousel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('ImageCarousel build ejecutado con ${widget.images.length} imágenes'); // Debug básico
    
    // Iniciar carrusel aquí si no se ha iniciado
    if (!_carouselStarted && widget.images.length > 1) {
      print('Iniciando carrusel desde build'); // Debug
      _carouselStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('PostFrameCallback desde build ejecutado'); // Debug
        _startCarousel();
      });
    }
    
    return Container(
      height: widget.height,
      child: Stack(
        children: [
          widget.images.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(widget.images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Carousel.placeholder, // Cambio: usar color centralizado
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: Carousel.placeholderIcon, // Cambio: usar color centralizado
                  ),
                ),
          
          // Overlay con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Carousel.overlayTop, // Cambio: usar color centralizado
                  Carousel.overlayBottom, // Cambio: usar color centralizado
                ],
              ),
            ),
          ),
          
          // Texto overlay
          Positioned(
            left: 20,
            right: 20,
            bottom: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Así que, ofrezcamos siempre a Dios, por medio de él, sacrificio de alabanza, es decir, fruto de labios que confiesan su nombre',
                  style: TextStyle(
                    color: Carousel.textOverlay, // Cambio: usar color centralizado
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hebreos 13:15',
                  style: TextStyle(
                    color: Carousel.textOverlay, // Cambio: usar color centralizado
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          
          // Indicadores del carrusel
          if (widget.images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Carousel.indicatorActive // Cambio: usar color centralizado
                          : Carousel.indicatorInactive, // Cambio: usar color centralizado
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