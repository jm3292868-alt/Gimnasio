
import 'package:flutter/material.dart';
import './services/membresia_service.dart';
import '../widgets/membresia_card.dart';
import 'editar_membresia_screen.dart';
 
class MembresiasScreen extends StatefulWidget {
  const MembresiasScreen({super.key});
 
  @override
  State<MembresiasScreen> createState() => _MembresiasScreenState();
}
 
class _MembresiasScreenState extends State<MembresiasScreen> {
  final _service = MembresiaService();
 
  List<Map<String, dynamic>> _membresias = [];
  String _busqueda = '';
  bool _cargando = true;
 
  @override
  void initState() {
    super.initState();
    _cargarMembresias();
  }
 
  Future<void> _cargarMembresias() async {
    setState(() => _cargando = true);
    try {
      final datos = await _service.obtenerMembresias();
      setState(() => _membresias = datos);
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
 
  Future<void> _nuevaMembresia() async {
    await Navigator.pushNamed(context, '/registro_membresia');
    _cargarMembresias();
  }
 
  Future<void> _editar(Map<String, dynamic> membresia) async {
    final huboCambios = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditarMembresiaScreen(membresia: membresia),
      ),
    );
    if (huboCambios == true) _cargarMembresias();
  }
 
  Future<void> _eliminar(Map<String, dynamic> membresia) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar membresía'),
        content: Text(
          '¿Seguro que quieres eliminar "${membresia['nombre']}"? '
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
      await _service.eliminar(membresia['id'] as int);
      _mostrarMensaje('Membresía eliminada', const Color(0xFF3B82F6));
      _cargarMembresias();
    } catch (e) {
      _mostrarMensaje('Error al eliminar: $e', Colors.red);
    }
  }
 
  // ---------- UI ----------
 
  List<Map<String, dynamic>> get _membresiasFiltradas {
    return _membresias.where((m) {
      return m['nombre']
          .toString()
          .toLowerCase()
          .contains(_busqueda.toLowerCase());
    }).toList();
  }
 
  Widget _lista(List<Map<String, dynamic>> lista) {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (lista.isEmpty) {
      return const Center(child: Text('No hay membresías registradas'));
    }
    return RefreshIndicator(
      onRefresh: _cargarMembresias,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: lista.length,
        itemBuilder: (context, i) {
          final m = lista[i];
          return MembresiaCard(
            membresia: m,
            onEditar: () => _editar(m),
            onEliminar: () => _eliminar(m),
          );
        },
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membresías'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevaMembresia,
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar membresía por nombre...',
                border: OutlineInputBorder(),
              ),
              onChanged: (texto) => setState(() => _busqueda = texto),
            ),
            const SizedBox(height: 10),
            Expanded(child: _lista(_membresiasFiltradas)),
          ],
        ),
      ),
    );
  }
}