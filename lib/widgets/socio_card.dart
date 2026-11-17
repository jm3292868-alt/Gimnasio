import 'package:flutter/material.dart';

/// Tarjeta de un socio con acciones: QR, editar y eliminar.
class SocioCard extends StatelessWidget {
  final Map<String, dynamic> socio;
  final VoidCallback onQr;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const SocioCard({
    super.key,
    required this.socio,
    required this.onQr,
    required this.onEditar,
    required this.onEliminar,
  });

  Color _colorEstado(String estado) {
    if (estado == 'Vigente') return Colors.green;
    if (estado == 'Vencido') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final estado = socio['estado'] ?? 'Sin membresía';

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('${socio['nombre']} ${socio['apellidos']}'),
            subtitle: Text(
              'Plan: ${socio['membresia_nombre'] ?? 'Ninguno'}\n'
              'Tel: ${socio['telefono'] ?? '-'}',
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ID ${socio['id']}'),
                Text(
                  estado,
                  style: TextStyle(
                    color: _colorEstado(estado),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Color(0xFF3B82F6)),
                  tooltip: 'Ver credencial QR',
                  onPressed: onQr,
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Editar',
                  onPressed: onEditar,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Eliminar',
                  onPressed: onEliminar,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
