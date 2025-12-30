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
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? const Color(0xFF2C2C2C)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Icon(
            Icons.search,
            color: esModoOscuro 
                ? ColoresApp.textoBlancoSecundario 
                : ColoresApp.textoSecundario,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controlador,
              onChanged: _alBuscar,
              decoration: InputDecoration(
                hintText: ConstantesApp.hintBusquedaCategorias,
                hintStyle: TextStyle(
                  color: esModoOscuro 
                      ? ColoresApp.textoBlancoSecundario 
                      : ColoresApp.textoSecundario,
                  fontSize: 16,
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              style: TextStyle(
                fontSize: 16,
                color: esModoOscuro 
                    ? ColoresApp.textoBlanco 
                    : ColoresApp.textoPrimario,
              ),
            ),
          ),
          if (_controlador.text.isNotEmpty)
            GestureDetector(
              onTap: _limpiarBusqueda,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.close,
                  color: esModoOscuro 
                      ? ColoresApp.textoBlancoSecundario 
                      : ColoresApp.textoSecundario,
                  size: 20,
                ),
              ),
            ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }
}