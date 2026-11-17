
import 'dart:io';
import 'package:flutter/material.dart';
 
import './services/socio_service.dart';
import '../widgets/foto_perfil_selector.dart';
import '../widgets/estilo_camo.dart';
 
class RegistroSocioScreen extends StatefulWidget {
  const RegistroSocioScreen({super.key});
 
  @override
  State<RegistroSocioScreen> createState() => _RegistroSocioScreenState();
}
 
class _RegistroSocioScreenState extends State<RegistroSocioScreen> {
  final _socioService = SocioService();
 
  final _nombre = TextEditingController();
  final _apellidos = TextEditingController();
  final _edad = TextEditingController();
  final _padecimientos = TextEditingController();
  final _telefono = TextEditingController();
 
  String? _genero;
  bool _cargando = false;
  File? _imagenSeleccionada;
 
  @override
  void dispose() {
    _nombre.dispose();
    _apellidos.dispose();
    _edad.dispose();
    _padecimientos.dispose();
    _telefono.dispose();
    super.dispose();
  }
 
  Future<void> _registrarSocio() async {
    final edad = int.tryParse(_edad.text.trim());
 
    if (_nombre.text.isEmpty || _apellidos.text.isEmpty || edad == null) {
      _mostrarMensaje('Llena nombre, apellidos y edad', Colors.red);
      return;
    }
 
    if (_genero == null) {
      _mostrarMensaje('Selecciona el género', Colors.red);
      return;
    }
 
    setState(() => _cargando = true);
 
    try {
      String? urlFoto;
      if (_imagenSeleccionada != null) {
        urlFoto = await _socioService.subirFoto(
          _imagenSeleccionada!,
          _nombre.text,
        );
      }
 
      final padecimientosTexto = _padecimientos.text.trim();
 
      await _socioService.registrar(
        nombre: _nombre.text.trim(),
        apellidos: _apellidos.text.trim(),
        edad: edad,
        padecimientos: padecimientosTexto.isEmpty ? null : padecimientosTexto,
        telefono: _telefono.text.trim(),
        genero: _genero!,
        fotoUrl: urlFoto,
      );
 
      if (!mounted) return;
      _mostrarMensaje('Socio registrado con éxito', const Color(0xFF3B82F6));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al registrar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
 
  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Socios'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FotoPerfilSelector(
              imagen: _imagenSeleccionada,
              onImagenSeleccionada: (file) =>
                  setState(() => _imagenSeleccionada = file),
            ),
            const SizedBox(height: 25),
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
              items: ['Masculino', 'Femenino']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (valor) => setState(() => _genero = valor),
            ),
            const SizedBox(height: 30),
            _cargando
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _registrarSocio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Registrar Socio'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
 