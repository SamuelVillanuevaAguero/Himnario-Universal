import 'package:flutter/material.dart';
import '/../../../configuracion/temas/colores_app.dart';
import '/../../../datos/modelos/categoria.dart';
import '../pantalla_himnos_categoria.dart';

/// Widget reutilizable para mostrar una tarjeta de categoría
class TarjetaCategoria extends StatelessWidget {
  final Categoria categoria;
  final bool esModoOscuro;

  const TarjetaCategoria({
    Key? key,
    required this.categoria,
    required this.esModoOscuro,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      leading: _construirIcono(),
      title: Text(
        categoria.nombre,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: esModoOscuro 
              ? ColoresApp.textoBlanco 
              : ColoresApp.textoPrimario,
        ),
      ),
      subtitle: Text(
        '${categoria.cantidadHimnos} himnos',
        style: TextStyle(
          fontSize: 14,
          color: esModoOscuro 
              ? ColoresApp.textoBlancoSecundario 
              : ColoresApp.textoSecundario,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: esModoOscuro 
            ? ColoresApp.textoBlancoSecundario 
            : ColoresApp.textoSecundario,
        size: 16,
      ),
      onTap: () => _navegarACategoria(context),
    );
  }

  Widget _construirIcono() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: (esModoOscuro 
                ? ColoresApp.primarioClaro 
                : ColoresApp.primario)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.folder,
        color: esModoOscuro 
            ? ColoresApp.primarioClaro 
            : ColoresApp.primario,
        size: 24,
      ),
    );
  }

  void _navegarACategoria(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PantallaHimnosCategoria(
          categoria: categoria,
        ),
      ),
    );
  }
}
