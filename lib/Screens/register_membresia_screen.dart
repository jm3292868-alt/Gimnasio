import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistroMembresiaScreen extends StatefulWidget {
  const RegistroMembresiaScreen({super.key});

  @override
  State<RegistroMembresiaScreen> createState() =>
      _RegistroMembresiaScreenState();
}

class _RegistroMembresiaScreenState extends State<RegistroMembresiaScreen> {
  final _nombre = TextEditingController();
  final _precio = TextEditingController();
  final _duracion = TextEditingController();

  String? _frecuencia;
  String _estado = 'Activa';
  bool _cargando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _precio.dispose();
    _duracion.dispose();
    super.dispose();
  }

  // Guarda la membresía en Supabase
  Future<void> _guardarMembresia() async {
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

    setState(() => _cargando = true);

    try {
      await Supabase.instance.client.from('membresias').insert({
        'nombre': _nombre.text.trim(),
        'precio': precio,
        'frecuencia_pago': _frecuencia,
        'estado': _estado,
        'duracion_dias': duracion,
      });

      if (!mounted) return;
      _mostrarMensaje('Membresía guardada', const Color(0xFF3B82F6));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al guardar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  // Estilo de los campos (gris como en el Figma)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Membresía'),
        centerTitle: true,
      ),
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
              items: ['Semanal', 'Quincenal', 'Mensual', 'Anual', 'Único']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (valor) => setState(() => _frecuencia = valor),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: _estilo('Estado'),
              items: ['Activa', 'Inactiva']
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
            _cargando
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _guardarMembresia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Guardar Membresía'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}