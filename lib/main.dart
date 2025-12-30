import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Configuración
import 'configuracion/temas/tema_app.dart';

// Repositorios
import 'datos/repositorios/repositorio_himnos.dart';
import 'datos/repositorios/repositorio_favoritos.dart';
import 'datos/repositorios/repositorio_categorias.dart';
import 'datos/repositorios/repositorio_audios.dart';

// Servicios
import 'datos/servicios/servicio_terminos_condiciones.dart';

// Providers
import 'presentacion/providers/provider_himnos.dart';
import 'presentacion/providers/provider_reproductor_audio.dart';
import 'presentacion/providers/provider_categorias.dart';

// Pantallas
import 'presentacion/pantallas/navegacion/navegacion_principal.dart';
import 'presentacion/pantallas/terminos_condiciones/pantalla_terminos_condiciones.dart';

// Colores
import 'configuracion/temas/colores_app.dart';

void main() {
  runApp(const AplicacionHimnario());
}

/// Aplicación principal del Himnario Universal
class AplicacionHimnario extends StatelessWidget {
  const AplicacionHimnario({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _crearProviders(),
      child: MaterialApp(
        title: 'Himnario Universal',
        debugShowCheckedModeBanner: false,
        
        // Temas
        theme: TemaApp.temaClaro,
        darkTheme: TemaApp.temaOscuro,
        themeMode: ThemeMode.system,
        
        // Pantalla inicial con verificación de términos
        home: const PantallaInicial(),
      ),
    );
  }

  /// Crea y configura todos los providers de la aplicación
  List<SingleChildWidget> _crearProviders() {
    // Crear instancias de repositorios
    final repositorioAudios = RepositorioAudios();
    final repositorioFavoritos = RepositorioFavoritos();
    final repositorioHimnos = RepositorioHimnos(
      repositorioAudios: repositorioAudios,
    );
    final repositorioCategorias = RepositorioCategorias();

    return [
      // Repositorios (para acceso directo si es necesario)
      Provider<RepositorioHimnos>.value(value: repositorioHimnos),
      Provider<RepositorioFavoritos>.value(value: repositorioFavoritos),
      Provider<RepositorioCategorias>.value(value: repositorioCategorias),
      Provider<RepositorioAudios>.value(value: repositorioAudios),
      
      // Providers con ChangeNotifier
      ChangeNotifierProvider(
        create: (_) => ProviderHimnos(
          repositorioHimnos: repositorioHimnos,
          repositorioFavoritos: repositorioFavoritos,
        ),
      ),
      
      ChangeNotifierProvider(
        create: (_) => ProviderReproductorAudio(),
      ),
      
      ChangeNotifierProvider(
        create: (_) => ProviderCategorias(
          repositorioCategorias: repositorioCategorias,
          repositorioHimnos: repositorioHimnos,
        ),
      ),
    ];
  }
}

/// Pantalla inicial que verifica si se han aceptado los términos
class PantallaInicial extends StatefulWidget {
  const PantallaInicial({Key? key}) : super(key: key);

  @override
  State<PantallaInicial> createState() => _PantallaInicialState();
}

class _PantallaInicialState extends State<PantallaInicial> {
  final ServicioTerminosCondiciones _servicioTerminos = ServicioTerminosCondiciones();
  bool _estaCargando = true;
  bool _terminosAceptados = false;

  @override
  void initState() {
    super.initState();
    _verificarTerminos();
  }

  Future<void> _verificarTerminos() async {
    try {
      final aceptados = await _servicioTerminos.haAceptadoTerminos();
      if (mounted) {
        setState(() {
          _terminosAceptados = aceptados;
          _estaCargando = false;
        });
      }
    } catch (e) {
      print('Error verificando términos: $e');
      if (mounted) {
        setState(() {
          _terminosAceptados = false;
          _estaCargando = false;
        });
      }
    }
  }

  Future<void> _aceptarTerminos() async {
    try {
      await _servicioTerminos.guardarAceptacionTerminos();
      if (mounted) {
        setState(() {
          _terminosAceptados = true;
        });
      }
    } catch (e) {
      print('Error guardando aceptación de términos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar la aceptación: $e'),
            backgroundColor: ColoresApp.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_estaCargando) {
      // Pantalla de carga
      final esModoOscuro = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: esModoOscuro ? ColoresApp.fondoOscuro : ColoresApp.fondoPrimario,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: esModoOscuro ? ColoresApp.primarioClaro : ColoresApp.primario,
              ),
              const SizedBox(height: 24),
              Text(
                'Himnario Universal',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: esModoOscuro ? ColoresApp.textoBlanco : ColoresApp.textoPrimario,
                ),
              ),
              const SizedBox(height: 40),
              CircularProgressIndicator(
                color: esModoOscuro ? ColoresApp.primarioClaro : ColoresApp.primario,
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar términos o navegación principal
    if (!_terminosAceptados) {
      return PantallaTerminosCondiciones(
        alAceptar: _aceptarTerminos,
      );
    }

    return const NavegacionPrincipal();
  }
}