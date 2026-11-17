import 'package:flutter/material.dart';
import './services/socio_service.dart';
import '../widgets/estilo_camo.dart';

class EditarSocioScreen extends StatefulWidget {
  final Map<String, dynamic> socio;

  const EditarSocioScreen({super.key, required this.socio});

  @override
  State<EditarSocioScreen> createState() => _EditarSocioScreenState();
}

class _EditarSocioScreenState extends State<EditarSocioScreen> {
final _service = SocioService();
  static const _generos = ['Masculino', 'Femenino'];

  late final TextEditingController _nombre;
  late final TextEditingController _apellidos;
  late final TextEditingController _edad;
  late final TextEditingController _padecimientos;
  late final TextEditingController _telefono;

  String? _genero;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final s = widget.socio;
    _nombre = TextEditingController(text: s['nombre']?.toString() ?? '');
    _apellidos = TextEditingController(text: s['apellidos']?.toString() ?? '');
    _edad = TextEditingController(text: s['edad']?.toString() ?? '');
    _padecimientos =
        TextEditingController(text: s['padecimientos']?.toString() ?? '');
    _telefono = TextEditingController(text: s['telefono']?.toString() ?? '');
    final genero = s['genero']?.toString();
    _genero = _generos.contains(genero) ? genero : null;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _edad.dispose();
    _padecimientos.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  Future<void> _guardar() async {
    final edad = int.tryParse(_edad.text.trim());

    if (_nombre.text.trim().isEmpty ||
        _apellidos.text.trim().isEmpty ||
        edad == null) {
      _mostrarMensaje('Llena nombre, apellidos y edad', Colors.red);
      return;
    }
    if (_genero == null) {
      _mostrarMensaje('Selecciona el género', Colors.red);
      return;
    }

    setState(() => _guardando = true);

    try {
      final padecimientos = _padecimientos.text.trim();

      await _service.actualizar(
        id: widget.socio['id'] as int,
        nombre: _nombre.text.trim(),
        apellidos: _apellidos.text.trim(),
        edad: edad,
        padecimientos: padecimientos.isEmpty ? null : padecimientos,
        telefono: _telefono.text.trim(),
        genero: _genero!,
      );

      if (!mounted) return;
      _mostrarMensaje('Socio actualizado', const Color(0xFF3B82F6));
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
      appBar: AppBar(title: const Text('Editar Socio'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nombre, decoration: estiloCampo('Nombre')),
            const SizedBox(height: 15),
            TextField(
                controller: _apellidos, decoration: estiloCampo('Apellidos')),
            const SizedBox(height: 15),
            TextField(
              controller: _edad,
              keyboardType: TextInputType.number,
              decoration: estiloCampo('Edad'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _padecimientos,
              decoration: estiloCampo('Padecimientos (Opcional)'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _telefono,
              keyboardType: TextInputType.phone,
              decoration: estiloCampo('Teléfono'),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _genero,
              decoration: estiloCampo('Género'),
              items: _generos
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (valor) => setState(() => _genero = valor),
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
