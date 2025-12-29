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

// Providers
import 'presentacion/providers/provider_himnos.dart';
import 'presentacion/providers/provider_reproductor_audio.dart';
import 'presentacion/providers/provider_categorias.dart';

// Pantallas
import 'presentacion/pantallas/navegacion/navegacion_principal.dart';

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
        
        // Pantalla inicial
        home: const NavegacionPrincipal(),
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