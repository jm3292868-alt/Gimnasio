import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import './services/socio_service.dart';

/// Escanea el QR de la credencial de un socio y muestra su estado actual.
class EscanearQrScreen extends StatefulWidget {
  const EscanearQrScreen({super.key});

  @override
  State<EscanearQrScreen> createState() => _EscanearQrScreenState();
}

class _EscanearQrScreenState extends State<EscanearQrScreen> {
  final _service = SocioService();
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  // Evita procesar varios QR al mismo tiempo
  bool _procesando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mostrarMensaje(String texto, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  Future<void> _alDetectar(BarcodeCapture captura) async {
    if (_procesando) return;

    final texto = captura.barcodes.isEmpty ? null : captura.barcodes.first.rawValue;
    if (texto == null) return;

    _procesando = true;

    try {
      // El QR guarda un JSON; solo necesitamos el id
      final datos = jsonDecode(texto);
      final id = datos is Map ? int.tryParse('${datos['id']}') : null;

      if (id == null) {
        _mostrarMensaje('QR no válido', Colors.red);
        return;
      }

      // Se consulta la base de datos para tener el estado ACTUAL
      // (el estado guardado dentro del QR pudo haber cambiado)
      final socio = await _service.obtenerSocioPorId(id);

      if (socio == null) {
        _mostrarMensaje('Socio no encontrado', Colors.red);
        return;
      }

      if (!mounted) return;
      await _mostrarResultado(socio);
    } catch (_) {
      _mostrarMensaje('No se pudo leer el QR', Colors.red);
    } finally {
      _procesando = false;
    }
  }

  Future<void> _mostrarResultado(Map<String, dynamic> socio) {
    final estado = (socio['estado'] ?? 'Sin membresía').toString();
    final vigente = estado == 'Vigente';
    final color = vigente
        ? Colors.green
        : (estado == 'Vencido' ? Colors.red : Colors.grey);

    final fotoUrl = socio['foto_url'] as String?;
    final tieneFoto = fotoUrl != null && fotoUrl.isNotEmpty;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFFD9D9D9),
                backgroundImage: tieneFoto ? NetworkImage(fotoUrl) : null,
                child: !tieneFoto
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                '${socio['nombre']} ${socio['apellidos']}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text('ID ${socio['id']}'),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      vigente ? Icons.check_circle : Icons.cancel,
                      color: color,
                      size: 40,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      estado,
                      style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Plan: ${socio['membresia_nombre'] ?? 'Ninguno'}'),
              Text('Tel: ${socio['telefono'] ?? '-'}'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Escanear otro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Credencial'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Linterna',
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Cambiar cámara',
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _alDetectar),
          // Marco guía en el centro
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Apunta la cámara al QR de la credencial',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 6, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
