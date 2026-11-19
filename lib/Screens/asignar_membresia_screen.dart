import 'package:flutter/material.dart';
import './services/asignacion_service.dart';
import '../widgets/estilo_camo.dart';

class AsignarMembresiaScreen extends StatefulWidget {
  final Map<String, dynamic> socio;

  const AsignarMembresiaScreen({super.key, required this.socio});

  @override
  State<AsignarMembresiaScreen> createState() => _AsignarMembresiaScreenState();
}

class _AsignarMembresiaScreenState extends State<AsignarMembresiaScreen> {
  final _service = AsignacionService();

  late final TextEditingController _nombreCtrl;
  final _inicioCtrl = TextEditingController();
  final _vencimientoCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();

  List<Map<String, dynamic>> _membresias = [];
  int? _membresiaId;
  String? _metodoPago;
  DateTime _inicio = DateTime.now();
  DateTime? _vencimiento;
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final s = widget.socio;
    _nombreCtrl = TextEditingController(text: '${s['nombre']} ${s['apellidos']}');
    _inicioCtrl.text = _formatear(_inicio);
    _cargarMembresias();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _inicioCtrl.dispose();
    _vencimientoCtrl.dispose();
    _totalCtrl.dispose();
    super.dispose();
  }

  String _formatear(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  void _mostrarMensaje(String texto, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  Future<void> _cargarMembresias() async {
    try {
      final datos = await _service.obtenerMembresiasActivas();
      if (!mounted) return;
      setState(() => _membresias = datos);
    } catch (e) {
      _mostrarMensaje('Error al cargar membresías: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  // Vencimiento = fecha de inicio + días de duración de la membresía
  void _calcularVencimiento() {
    if (_membresiaId == null) return;

    final membresia = _membresias.firstWhere((m) => m['id'] == _membresiaId);
    final dias = membresia['duracion_dias'] as int;

    _vencimiento = _inicio.add(Duration(days: dias));
    _vencimientoCtrl.text = _formatear(_vencimiento!);
  }

  // Al elegir la membresía se llena el total y el vencimiento solos
  void _elegirMembresia(int? id) {
    setState(() {
      _membresiaId = id;
      final membresia = _membresias.firstWhere((m) => m['id'] == id);
      _totalCtrl.text = membresia['precio'].toString();
      _calcularVencimiento();
    });
  }

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _inicio,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() {
        _inicio = fecha;
        _inicioCtrl.text = _formatear(fecha);
        _calcularVencimiento();
      });
    }
  }

  Future<void> _guardar() async {
    final total = double.tryParse(_totalCtrl.text.trim().replaceAll(',', '.'));

    if (_membresiaId == null) {
      _mostrarMensaje('Selecciona la membresía', Colors.red);
      return;
    }

    if (_metodoPago == null) {
      _mostrarMensaje('Selecciona el método de pago', Colors.red);
      return;
    }

    if (total == null || total < 0) {
      _mostrarMensaje('Escribe un total válido', Colors.red);
      return;
    }

    setState(() => _guardando = true);

    try {
      await _service.asignar(
        socioId: widget.socio['id'] as int,
        membresiaId: _membresiaId!,
        fechaInicio: _inicio,
        fechaVencimiento: _vencimiento!,
        metodoPago: _metodoPago!,
        total: total,
      );

      if (!mounted) return;
      _mostrarMensaje('Membresía asignada', const Color(0xFF3B82F6));
      Navigator.pop(context, true); // true = hubo cambios
    } catch (e) {
      _mostrarMensaje('Error al asignar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Membresía'), centerTitle: true),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _nombreCtrl,
                    readOnly: true,
                    decoration: estiloCampo('Nombre Socio'),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    initialValue: _membresiaId,
                    isExpanded: true,
                    decoration: estiloCampo('Membresía solicitada'),
                    items: _membresias
                        .map((m) => DropdownMenuItem<int>(
                              value: m['id'] as int,
                              child: Text('${m['nombre']} - \$${m['precio']}'),
                            ))
                        .toList(),
                    onChanged: _elegirMembresia,
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _inicioCtrl,
                    readOnly: true,
                    onTap: _elegirFecha,
                    decoration: estiloCampo('Fecha de inicio'),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _vencimientoCtrl,
                    readOnly: true,
                    decoration: estiloCampo('Fecha de vencimiento'),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: _metodoPago,
                    decoration: estiloCampo('Método de pago'),
                    items: ['Efectivo', 'Tarjeta']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (valor) => setState(() => _metodoPago = valor),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _totalCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: estiloCampo('Total a pagar'),
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
                            child: const Text('Confirmar Asignación'),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}