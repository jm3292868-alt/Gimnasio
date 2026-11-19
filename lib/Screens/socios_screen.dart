
import 'package:flutter/material.dart';
import './services/socio_service.dart';
import '../widgets/socio_card.dart';
import '../widgets/socios_filtros.dart';
import '../widgets/user_menu.dart';
import 'editar_socio_screen.dart';
import 'socio_qr_screen.dart';
import 'asignar_membresia_screen.dart';
import 'escanear_qr_screen.dart';
 
class SociosScreen extends StatefulWidget {
  const SociosScreen({super.key});
 
  @override
  State<SociosScreen> createState() => _SociosScreenState();
}
 
class _SociosScreenState extends State<SociosScreen> {
  final _service = SocioService();
 
  List<Map<String, dynamic>> _socios = [];
  String _filtro = 'Todos';
  String _busqueda = '';
  bool _cargando = true;
 
  @override
  void initState() {
    super.initState();
    _cargarSocios();
  }
 
  Future<void> _cargarSocios() async {
    setState(() => _cargando = true);
    try {
      final datos = await _service.obtenerSocios();
      setState(() => _socios = datos);
    } catch (e) {
      _mostrarMensaje('Error al cargar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
 
  void _mostrarMensaje(String texto, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }
 
  // ---------- Acciones ----------
 
  Future<void> _nuevoSocio() async {
    await Navigator.pushNamed(context, '/registro_socio');
    _cargarSocios();
  }
 
  void _nuevoRecepcionista() {
    Navigator.pushNamed(context, '/register_screen');
  }
 
  void _abrirQr(Map<String, dynamic> socio) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SocioQrScreen(socio: socio)),
    );
  }
 
  Future<void> _editar(Map<String, dynamic> socio) async {
    final huboCambios = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditarSocioScreen(socio: socio)),
    );
    if (huboCambios == true) _cargarSocios();
  }
 
  Future<void> _eliminar(Map<String, dynamic> socio) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar socio'),
        content: Text(
          '¿Seguro que quieres eliminar a '
          '${socio['nombre']} ${socio['apellidos']}? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
 
    if (confirmado != true) return;
 
    try {
      await _service.eliminar(socio['id'] as int);
      _mostrarMensaje('Socio eliminado', const Color(0xFF3B82F6));
      _cargarSocios();
    } catch (e) {
      _mostrarMensaje('Error al eliminar: $e', Colors.red);
    }
  }
  Future<void> _asignar(Map<String, dynamic> socio) async {
    final huboCambios = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AsignarMembresiaScreen(socio: socio)),
    );
    if (huboCambios == true) _cargarSocios();
 
}
 
  // ---------- UI ----------
 
  List<Map<String, dynamic>> get _sociosFiltrados {
    return _socios.where((s) {
      final nombreCompleto = '${s['nombre']} ${s['apellidos']}'.toLowerCase();
      final coincideBusqueda =
          nombreCompleto.contains(_busqueda.toLowerCase()) ||
              s['id'].toString().contains(_busqueda);
      final coincideFiltro = _filtro == 'Todos' || s['estado'] == _filtro;
      return coincideBusqueda && coincideFiltro;
    }).toList();
  }
 
  Widget _botonesFlotantes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'nuevo_recepcionista',
          onPressed: _nuevoRecepcionista,
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: const Text('Nuevo Recepcionista'),
        ),
        const SizedBox(height: 12),
        FloatingActionButton.extended(
          heroTag: 'nuevo_socio',
          onPressed: _nuevoSocio,
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Socio'),
        ),
      ],
    );
  }
 
  Widget _lista(List<Map<String, dynamic>> lista) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (lista.isEmpty) {
      return const Center(child: Text('No hay socios registrados'));
    }
    return RefreshIndicator(
      onRefresh: _cargarSocios,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 140),
        itemCount: lista.length,
        itemBuilder: (context, i) {
          final s = lista[i];
          return SocioCard(
            socio: s,
            onQr: () => _abrirQr(s),
            onEditar: () => _editar(s),
            onEliminar: () => _eliminar(s),
            onAsignarMembresia: () => _asignar(s),
          );
        },
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Socios'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_membership),
            onPressed: () => Navigator.pushNamed(context, '/membresias'),
          ),
          IconButton(
  icon: const Icon(Icons.qr_code_scanner),
  tooltip: 'Escanear credencial',
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EscanearQrScreen()),
  ),
),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => UserMenu.show(context),
          ),
        ],
      ),
      floatingActionButton: _botonesFlotantes(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SociosFiltros(
              filtroActual: _filtro,
              onBusqueda: (t) => setState(() => _busqueda = t),
              onFiltro: (f) => setState(() => _filtro = f),
            ),
            const SizedBox(height: 10),
            Expanded(child: _lista(_sociosFiltrados)),
          ],
        ),
      ),
    );
  }
}