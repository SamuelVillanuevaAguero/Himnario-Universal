import 'package:flutter/material.dart';
import '/../../configuracion/temas/colores_app.dart';
import '../../pantallas/inicio/pantalla_inicio.dart';
import '../../pantallas/favoritos/pantalla_favoritos.dart';
import '../../pantallas/categorias/pantalla_categorias.dart';

/// Pantalla principal con navegación inferior entre secciones
class NavegacionPrincipal extends StatefulWidget {
  const NavegacionPrincipal({Key? key}) : super(key: key);

  @override
  State<NavegacionPrincipal> createState() => _NavegacionPrincipalState();
}

class _NavegacionPrincipalState extends State<NavegacionPrincipal> {
  int _indiceActual = 0;
  late PageController _controladorPagina;

  final List<Widget> _paginas = const [
    PantallaInicio(),
    PantallaFavoritos(),
    PantallaCategorias(),
  ];

  @override
  void initState() {
    super.initState();
    _controladorPagina = PageController();
  }

  @override
  void dispose() {
    _controladorPagina.dispose();
    super.dispose();
  }

  void _alCambiarPagina(int indice) {
    setState(() {
      _indiceActual = indice;
    });
  }

  void _alTocarTab(int indice) {
    _controladorPagina.animateToPage(
      indice,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _controladorPagina,
        onPageChanged: _alCambiarPagina,
        children: _paginas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: _alTocarTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: esModoOscuro 
            ? ColoresApp.fondoOscuro 
            : ColoresApp.fondoPrimario,
        selectedItemColor: esModoOscuro 
            ? ColoresApp.primarioClaro 
            : ColoresApp.primario,
        unselectedItemColor: esModoOscuro 
            ? ColoresApp.textoBlancoSecundario 
            : ColoresApp.textoSecundario,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Himnos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categorías',
          ),
        ],
      ),
    );
  }
}
