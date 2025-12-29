import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../configuracion/temas/colores_app.dart';
import '/../../../nucleo/constantes/constantes_app.dart';
import '/../../../presentacion/providers/provider_categorias.dart';

/// Widget de barra de búsqueda para filtrar categorías
class BarraBusquedaCategorias extends StatefulWidget {
  const BarraBusquedaCategorias({Key? key}) : super(key: key);

  @override
  State<BarraBusquedaCategorias> createState() =>
      _BarraBusquedaCategoriasState();
}

class _BarraBusquedaCategoriasState extends State<BarraBusquedaCategorias> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alBuscar(String termino) {
    context.read<ProviderCategorias>().buscar(termino);
  }

  void _limpiarBusqueda() {
    _controlador.clear();
    context.read<ProviderCategorias>().limpiarBusqueda();
  }

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? ColoresApp.fondoOscuro.withOpacity(0.8) 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esModoOscuro 
              ? ColoresApp.bordeOscuro 
              : ColoresApp.divisor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: esModoOscuro 
                ? ColoresApp.textoBlancoSecundario 
                : ColoresApp.textoSecundario,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controlador,
              onChanged: _alBuscar,
              style: TextStyle(
                fontSize: 16,
                color: esModoOscuro 
                    ? ColoresApp.textoBlanco 
                    : ColoresApp.textoPrimario,
              ),
              decoration: InputDecoration(
                hintText: ConstantesApp.hintBusquedaCategorias,
                hintStyle: TextStyle(
                  color: esModoOscuro 
                      ? ColoresApp.textoBlancoSecundario 
                      : ColoresApp.textoSecundario,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_controlador.text.isNotEmpty)
            IconButton(
              onPressed: _limpiarBusqueda,
              icon: Icon(
                Icons.clear,
                color: esModoOscuro 
                    ? ColoresApp.textoBlancoSecundario 
                    : ColoresApp.textoSecundario,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
