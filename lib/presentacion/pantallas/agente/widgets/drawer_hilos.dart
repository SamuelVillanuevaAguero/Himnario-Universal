import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../configuracion/temas/colores_app.dart';
import '../../../../nucleo/utilidades/tiempo_relativo.dart';
import '../../../providers/provider_agente.dart';

/// Drawer lateral con lista de hilos de conversación
class DrawerHilos extends StatelessWidget {
  const DrawerHilos({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      backgroundColor: dark ? const Color(0xFF0F0F0F) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            _EncabezadoDrawer(dark: dark),
            const Divider(height: 1),
            const Expanded(child: _ListaHilos()),
            const Divider(height: 1),
            _BotonNuevoHilo(dark: dark),
          ],
        ),
      ),
    );
  }
}

// ─── Encabezado ───────────────────────────────────────────────────────────────

class _EncabezadoDrawer extends StatelessWidget {
  final bool dark;
  const _EncabezadoDrawer({required this.dark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                    : [const Color(0xFF1976D2), const Color(0xFF64B5F6)],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 17),
          ),
          const SizedBox(width: 10),
          Text(
            'Conversaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : ColoresApp.textoPrimario,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close,
                size: 20,
                color: dark
                    ? ColoresApp.textoBlancoSecundario
                    : ColoresApp.textoSecundario),
          ),
        ],
      ),
    );
  }
}

// ─── Lista de hilos ───────────────────────────────────────────────────────────

class _ListaHilos extends StatelessWidget {
  const _ListaHilos();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ProviderAgente>(
      builder: (context, provider, _) {
        if (provider.hilos.isEmpty) {
          return Center(
            child: Text('Sin conversaciones',
                style: TextStyle(
                    color: dark
                        ? ColoresApp.textoBlancoSecundario
                        : ColoresApp.textoSecundario)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: provider.hilos.length,
          itemBuilder: (context, i) {
            final hilo = provider.hilos[i];
            final activo =
                provider.hiloActivo?.threadId == hilo.threadId;
            return _ItemHilo(
              hilo: hilo,
              activo: activo,
              dark: dark,
            );
          },
        );
      },
    );
  }
}

// ─── Item individual con swipe + long press ───────────────────────────────────

class _ItemHilo extends StatelessWidget {
  final ConversationThread hilo;
  final bool activo;
  final bool dark;

  const _ItemHilo(
      {required this.hilo, required this.activo, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(hilo.threadId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmarEliminar(context),
      onDismissed: (_) {
        context.read<ProviderAgente>().eliminarHilo(hilo.threadId);
        Navigator.pop(context);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline,
            color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onLongPress: () => _mostrarMenuLongPress(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: activo
                ? (dark
                    ? ColoresApp.primario.withOpacity(0.18)
                    : ColoresApp.primario.withOpacity(0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: _icono(),
            title: Row(
              children: [
                if (hilo.isPinned) ...[
                  Icon(Icons.push_pin,
                      size: 12,
                      color: dark
                          ? ColoresApp.primarioClaro
                          : ColoresApp.primario),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    hilo.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          activo ? FontWeight.w600 : FontWeight.w400,
                      color: activo
                          ? (dark
                              ? ColoresApp.primarioClaro
                              : ColoresApp.primario)
                          : (dark ? Colors.white : ColoresApp.textoPrimario),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hilo.lastMessagePreview,
                  style: TextStyle(
                    fontSize: 12,
                    color: dark
                        ? ColoresApp.textoBlancoTerciario
                        : ColoresApp.textoTerciario,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  TiempoRelativo.formatear(hilo.lastMessageAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: dark
                        ? ColoresApp.textoBlancoTerciario.withOpacity(0.7)
                        : ColoresApp.textoTerciario.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            trailing: _indicadorEstado(),
            onTap: () {
              context.read<ProviderAgente>().abrirHilo(hilo.threadId);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _icono() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: activo
            ? (dark
                ? ColoresApp.primario.withOpacity(0.35)
                : ColoresApp.primario.withOpacity(0.12))
            : (dark
                ? const Color(0xFF222222)
                : const Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.chat_bubble_outline_rounded,
        size: 16,
        color: activo
            ? (dark ? ColoresApp.primarioClaro : ColoresApp.primario)
            : (dark
                ? ColoresApp.textoBlancoSecundario
                : ColoresApp.textoSecundario),
      ),
    );
  }

  Widget? _indicadorEstado() {
    switch (hilo.status) {
      case ThreadStatus.streaming:
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ThreadStatus.error:
        return const Icon(Icons.error_outline,
            color: Colors.red, size: 16);
      default:
        return null;
    }
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor:
                dark ? const Color(0xFF1E1E1E) : Colors.white,
            title: Text('¿Eliminar conversación?',
                style: TextStyle(
                    fontSize: 15,
                    color:
                        dark ? Colors.white : ColoresApp.textoPrimario)),
            content: Text('Se eliminará "${hilo.title}" y todos sus mensajes.',
                style: TextStyle(
                    color: dark
                        ? ColoresApp.textoBlancoSecundario
                        : ColoresApp.textoSecundario,
                    fontSize: 13)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _mostrarMenuLongPress(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: dark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _MenuAccionesHilo(
        hilo: hilo,
        dark: dark,
        parentContext: context,
      ),
    );
  }
}

// ─── Bottom sheet de acciones ─────────────────────────────────────────────────

class _MenuAccionesHilo extends StatelessWidget {
  final ConversationThread hilo;
  final bool dark;
  final BuildContext parentContext;

  const _MenuAccionesHilo(
      {required this.hilo,
      required this.dark,
      required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AccionMenu(
        icono: Icons.edit_outlined,
        etiqueta: 'Renombrar',
        onTap: () {
          Navigator.pop(context);
          _mostrarRenombrar(parentContext);
        },
      ),
      _AccionMenu(
        icono: hilo.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        etiqueta: hilo.isPinned ? 'Quitar pin' : 'Fijar',
        onTap: () {
          parentContext.read<ProviderAgente>().togglePin(hilo.threadId);
          Navigator.pop(context);
        },
      ),
      _AccionMenu(
        icono: Icons.share_outlined,
        etiqueta: 'Exportar conversación',
        onTap: () async {
          Navigator.pop(context);
          final texto = await parentContext
              .read<ProviderAgente>()
              .exportarHilo(hilo.threadId);
          await Share.share(texto, subject: hilo.title);
        },
      ),
      _AccionMenu(
        icono: Icons.delete_outline,
        etiqueta: 'Eliminar',
        color: Colors.red,
        onTap: () {
          Navigator.pop(context); // bottom sheet
          _confirmarEliminar(parentContext);
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.white24
                  : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              hilo.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dark ? Colors.white : ColoresApp.textoPrimario,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => ListTile(
                leading: Icon(item.icono,
                    color: item.color ??
                        (dark ? Colors.white70 : ColoresApp.textoSecundario),
                    size: 20),
                title: Text(
                  item.etiqueta,
                  style: TextStyle(
                    color: item.color ??
                        (dark ? Colors.white : ColoresApp.textoPrimario),
                    fontSize: 14,
                  ),
                ),
                onTap: item.onTap,
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _mostrarRenombrar(BuildContext context) {
    final ctrl = TextEditingController(text: hilo.title);
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('Renombrar',
            style: TextStyle(
                fontSize: 15,
                color: dark ? Colors.white : ColoresApp.textoPrimario)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(
              color: dark ? Colors.white : ColoresApp.textoPrimario),
          decoration: InputDecoration(
            hintText: 'Nuevo nombre',
            hintStyle: TextStyle(
                color: dark
                    ? ColoresApp.textoBlancoSecundario
                    : ColoresApp.textoSecundario),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final nombre = ctrl.text.trim();
              if (nombre.isNotEmpty) {
                context
                    .read<ProviderAgente>()
                    .renombrarHilo(hilo.threadId, nombre);
              }
              Navigator.pop(context);
            },
            child: Text('Guardar',
                style: TextStyle(
                    color: dark
                        ? ColoresApp.primarioClaro
                        : ColoresApp.primario,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: dark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text('¿Eliminar conversación?',
            style: TextStyle(
                fontSize: 15,
                color: dark ? Colors.white : ColoresApp.textoPrimario)),
        content: Text(
            'Se eliminará "${hilo.title}" y todos sus mensajes.',
            style: TextStyle(
                color: dark
                    ? ColoresApp.textoBlancoSecundario
                    : ColoresApp.textoSecundario,
                fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              context.read<ProviderAgente>().eliminarHilo(hilo.threadId);
              Navigator.pop(context); // diálogo
              Navigator.pop(context); // drawer
            },
            child: const Text('Eliminar',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _AccionMenu {
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;
  final Color? color;
  const _AccionMenu(
      {required this.icono,
      required this.etiqueta,
      required this.onTap,
      this.color});
}

// ─── Botón nueva conversación ─────────────────────────────────────────────────

class _BotonNuevoHilo extends StatelessWidget {
  final bool dark;
  const _BotonNuevoHilo({required this.dark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await context.read<ProviderAgente>().crearHilo();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Nueva conversación',
              style: TextStyle(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                dark ? ColoresApp.primarioClaro : ColoresApp.primario,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}