import 'package:flutter/material.dart';
import '/../../../../../configuracion/temas/colores_app.dart';
import '/../../../../../datos/repositorios/repositorio_notas.dart';

/// Botón + sheet para agregar/editar nota personal en un himno
class BotonNotas extends StatefulWidget {
  final int numeroHimno;
  final bool esModoOscuro;

  const BotonNotas({
    super.key,
    required this.numeroHimno,
    required this.esModoOscuro,
  });

  @override
  State<BotonNotas> createState() => _BotonNotasState();
}

class _BotonNotasState extends State<BotonNotas> {
  final _repo = RepositorioNotas();
  String? _nota;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final n = await _repo.obtenerNota(widget.numeroHimno);
    if (mounted) setState(() { _nota = n; _cargando = false; });
  }

  void _abrirEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditorNota(
        nota: _nota,
        dark: widget.esModoOscuro,
        onGuardar: (texto) async {
          await _repo.guardarNota(widget.numeroHimno, texto);
          if (mounted) setState(() => _nota = texto.trim().isEmpty ? null : texto.trim());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const SizedBox.shrink();
    final tieneNota = _nota != null && _nota!.isNotEmpty;
    return IconButton(
      onPressed: _abrirEditor,
      tooltip: tieneNota ? 'Ver/editar nota' : 'Agregar nota',
      icon: Icon(
        tieneNota ? Icons.sticky_note_2 : Icons.sticky_note_2_outlined,
        color: tieneNota
            ? Colors.amber.shade600
            : (widget.esModoOscuro
                ? ColoresApp.textoBlancoSecundario
                : ColoresApp.textoSecundario),
        size: 24,
      ),
    );
  }
}

// ─── Sheet editor ─────────────────────────────────────────────────────────────

class _EditorNota extends StatefulWidget {
  final String? nota;
  final bool dark;
  final Future<void> Function(String) onGuardar;

  const _EditorNota({required this.nota, required this.dark, required this.onGuardar});

  @override
  State<_EditorNota> createState() => _EditorNotaState();
}

class _EditorNotaState extends State<_EditorNota> {
  late final TextEditingController _ctrl;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.nota ?? '');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    await widget.onGuardar(_ctrl.text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.dark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = widget.dark ? Colors.white : ColoresApp.textoPrimario;
    final hintColor = widget.dark ? ColoresApp.textoBlancoSecundario : ColoresApp.textoSecundario;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: widget.dark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.sticky_note_2_outlined,
                    color: Colors.amber.shade600, size: 20),
                const SizedBox(width: 8),
                Text('Nota personal',
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: textColor,
                    )),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              maxLines: 5,
              minLines: 3,
              autofocus: true,
              style: TextStyle(fontSize: 15, color: textColor),
              decoration: InputDecoration(
                hintText: 'Escribe tu nota aquí…',
                hintStyle: TextStyle(color: hintColor),
                filled: true,
                fillColor: widget.dark
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                // Eliminar nota (si existe)
                if (widget.nota != null && widget.nota!.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      await widget.onGuardar('');
                      if (mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    label: const Text('Borrar', style: TextStyle(color: Colors.red)),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar',
                      style: TextStyle(color: hintColor)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColoresApp.primario,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 11),
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}