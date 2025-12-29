import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../nucleo/constantes/constantes_app.dart';
import '/../../../presentacion/providers/provider_himnos.dart';

/// Widget de barra de búsqueda para filtrar himnos
class BarraBusqueda extends StatefulWidget {
  const BarraBusqueda({Key? key}) : super(key: key);

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _alBuscar(String termino) {
    context.read<ProviderHimnos>().buscar(termino);
  }

  void _limpiarBusqueda() {
    _controlador.clear();
    context.read<ProviderHimnos>().limpiarBusqueda();
  }

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: esModoOscuro 
            ? ColoresApp.fondoTarjeta 
            : ColoresApp.fondoSecundario,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: esModoOscuro 
              ? ColoresApp.bordeOscuro 
              : ColoresApp.divisor,
        ),
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
                hintText: ConstantesApp.hintBusquedaHimnos,
                hintStyle: TextStyle(
                  color: esModoOscuro 
                      ? ColoresApp.textoBlancoSecundario 
                      : ColoresApp.textoSecundario,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
