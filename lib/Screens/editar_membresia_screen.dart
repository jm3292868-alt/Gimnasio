import 'package:flutter/material.dart';
import './services/membresia_service.dart';

class EditarMembresiaScreen extends StatefulWidget {
  final Map<String, dynamic> membresia;

  const EditarMembresiaScreen({super.key, required this.membresia});

  @override
  State<EditarMembresiaScreen> createState() => _EditarMembresiaScreenState();
}

class _EditarMembresiaScreenState extends State<EditarMembresiaScreen> {
  final _service = MembresiaService();

  static const _frecuencias = ['Semanal', 'Quincenal', 'Mensual', 'Anual', 'Único'];
  static const _estados = ['Activa', 'Inactiva'];

  late final TextEditingController _nombre;
  late final TextEditingController _precio;
  late final TextEditingController _duracion;

  String? _frecuencia;
  String _estado = 'Activa';
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final m = widget.membresia;
    _nombre = TextEditingController(text: m['nombre']?.toString() ?? '');
    _precio = TextEditingController(text: m['precio']?.toString() ?? '');
    _duracion = TextEditingController(text: m['duracion_dias']?.toString() ?? '');

    final frecuencia = m['frecuencia_pago']?.toString();
    _frecuencia = _frecuencias.contains(frecuencia) ? frecuencia : null;

    final estado = m['estado']?.toString();
    _estado = _estados.contains(estado) ? estado! : 'Activa';
  }

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _duracion.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  InputDecoration _estilo(String label, {String? sufijo}) {
    return InputDecoration(
      labelText: label,
      suffixText: sufijo,
      filled: true,
      fillColor: const Color(0xFFD9D9D9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _guardar() async {
    final precio = double.tryParse(_precio.text.trim().replaceAll(',', '.'));
    final duracion = int.tryParse(_duracion.text.trim());

    if (_nombre.text.trim().isEmpty) {
      _mostrarMensaje('Escribe el nombre de la membresía', Colors.red);
      return;
    }
    if (precio == null || precio < 0) {
      _mostrarMensaje('Escribe un precio válido', Colors.red);
      return;
    }
    if (_frecuencia == null) {
      _mostrarMensaje('Selecciona la frecuencia de pagos', Colors.red);
      return;
    }
    if (duracion == null || duracion <= 0) {
      _mostrarMensaje('Escribe la duración en días', Colors.red);
      return;
    }

    setState(() => _guardando = true);

    try {
      await _service.actualizar(
        id: widget.membresia['id'] as int,
        nombre: _nombre.text.trim(),
        precio: precio,
        frecuenciaPago: _frecuencia!,
        estado: _estado,
        duracionDias: duracion,
      );

      if (!mounted) return;
      _mostrarMensaje('Membresía actualizada', const Color(0xFF3B82F6));
      Navigator.pop(context, true); // true = hubo cambios
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al actualizar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Membresía'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nombre,
              decoration: _estilo('Nombre de la membresía'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _precio,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: _estilo('Precio', sufijo: 'MXN'),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _frecuencia,
              decoration: _estilo('Frecuencia de pagos'),
              items: _frecuencias
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (valor) => setState(() => _frecuencia = valor),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: _estilo('Estado'),
              items: _estados
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (valor) => setState(() => _estado = valor!),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _duracion,
              keyboardType: TextInputType.number,
              decoration: _estilo('Duración', sufijo: 'días'),
            ),
            const SizedBox(height: 30),
            _guardando
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Guardar Cambios'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
