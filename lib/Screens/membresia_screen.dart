import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembresiasScreen extends StatefulWidget {
  const MembresiasScreen({super.key});

  @override
  State<MembresiasScreen> createState() => _MembresiasScreenState();
}

class _MembresiasScreenState extends State<MembresiasScreen> {
  List<Map<String, dynamic>> _membresias = [];
  String _busqueda = '';
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMembresias();
  }

  // Trae las membresías de Supabase
  Future<void> _cargarMembresias() async {
    setState(() => _cargando = true);

    try {
      final datos = await Supabase.instance.client
          .from('membresias')
          .select()
          .order('id', ascending: false);

      setState(() => _membresias = List<Map<String, dynamic>>.from(datos));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Abre el formulario y al regresar recarga la lista
  Future<void> _nuevaMembresia() async {
    await Navigator.pushNamed(context, '/registro_membresia');
    _cargarMembresias();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _membresias.where((m) {
      return m['nombre'].toString().toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresías'),
        centerTitle: true,
      ),
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
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : lista.isEmpty
                      ? const Center(child: Text('No hay membresías registradas'))
                      : RefreshIndicator(
                          onRefresh: _cargarMembresias,
                          child: ListView.builder(
                            itemCount: lista.length,
                            itemBuilder: (context, i) {
                              final m = lista[i];
                              final activa = m['estado'] == 'Activa';
                              return Card(
                                child: ListTile(
                                  title: Text(m['nombre']),
                                  subtitle: Text(
                                    'Costo: \$${m['precio']}\n'
                                    'Pago: ${m['frecuencia_pago']}\n'
                                    'Duración: ${m['duracion_dias']} días',
                                  ),
                                  isThreeLine: true,
                                  trailing: Text(
                                    m['estado'],
                                    style: TextStyle(
                                      color: activa ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}