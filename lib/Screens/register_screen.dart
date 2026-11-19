import 'package:flutter/material.dart';
import '../widgets/password_field.dart';
import './services/recepcionista_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _service = RecepcionistaService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  Future<void> _crearRecepcionista() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _mostrarMensaje('Llena todos los campos', Colors.red);
      return;
    }
    if (password.length < 6) {
      _mostrarMensaje(
          'La contraseña debe tener al menos 6 caracteres', Colors.red);
      return;
    }

    setState(() => _cargando = true);

    try {
      await _service.crear(email: email, password: password);

      if (!mounted) return;
      _mostrarMensaje('Recepcionista creado correctamente',
          const Color(0xFF3B82F6));
      Navigator.pop(context); // el admin sigue con su sesión activa
    } catch (e) {
      if (!mounted) return;
      final mensaje = e.toString().replaceFirst('Exception: ', '');
      _mostrarMensaje(mensaje, Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Recepcionista'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 150),
                const SizedBox(height: 35),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),
                PasswordField(controller: _passwordController),
                const SizedBox(height: 35),
                _cargando
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _crearRecepcionista,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Crear Recepcionista',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}