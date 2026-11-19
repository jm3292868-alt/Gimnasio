import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class SocioQrScreen extends StatefulWidget {
  final Map<String, dynamic> socio;

  const SocioQrScreen({super.key, required this.socio});

  @override
  State<SocioQrScreen> createState() => _SocioQrScreenState();
}

class _SocioQrScreenState extends State<SocioQrScreen> {
  // Llave para capturar la credencial como imagen
  final GlobalKey _credencialKey = GlobalKey();
  bool _compartiendo = false;

  Map<String, dynamic> get _socio => widget.socio;

  Color _colorEstado(String estado) {
    if (estado == 'Vigente') return Colors.green;
    if (estado == 'Vencido') return Colors.red;
    return Colors.grey;
  }

  // Datos que se guardan dentro del QR (en formato JSON)
  String _datosQr() {
    return jsonEncode({
      'id': _socio['id'],
      'nombre': _socio['nombre'],
      'apellidos': _socio['apellidos'],
      'edad': _socio['edad'],
      'telefono': _socio['telefono'],
      'genero': _socio['genero'],
      'padecimientos': _socio['padecimientos'],
      'plan': _socio['membresia_nombre'],
      'estado': _socio['estado'] ?? 'Sin membresía',
    });
  }

  // Convierte la credencial en imagen PNG y abre el menú de compartir
  Future<void> _compartir() async {
    setState(() => _compartiendo = true);

    try {
      final boundary = _credencialKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final ui.Image imagen = await boundary.toImage(pixelRatio: 3);
      final ByteData? byteData =
          await imagen.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final archivo =
          File('${Directory.systemTemp.path}/socio_${_socio['id']}.png');
      await archivo.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(archivo.path)],
          text: 'Credencial de ${_socio['nombre']} ${_socio['apellidos']}',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo compartir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _compartiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = _socio['estado'] ?? 'Sin membresía';
    final fotoUrl = _socio['foto_url'] as String?;
    final tieneFoto = fotoUrl != null && fotoUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credencial del Socio'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir',
            onPressed: _compartiendo ? null : _compartir,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              // Todo lo que está dentro de RepaintBoundary es lo que se comparte
              RepaintBoundary(
                key: _credencialKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.black),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFD9D9D9),
                          backgroundImage:
                              tieneFoto ? NetworkImage(fotoUrl!) : null,
                          child: !tieneFoto
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.grey)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${_socio['nombre']} ${_socio['apellidos']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('ID ${_socio['id']}',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          estado,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _colorEstado(estado),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Plan: ${_socio['membresia_nombre'] ?? 'Ninguno'}'),
                        
                        const SizedBox(height: 24),
                        QrImageView(
                          data: _datosQr(),
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: _compartiendo ? null : _compartir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  icon: _compartiendo
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.share),
                  label: const Text('Compartir al socio'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
