import 'package:flutter/material.dart';

/// Tarjeta de un socio con acciones: asignar membresía, QR, editar y eliminar.
/// Editar y eliminar solo se muestran si [esAdmin] es true.
class SocioCard extends StatelessWidget {
  final Map<String, dynamic> socio;
  final VoidCallback onQr;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onAsignarMembresia;
  final bool esAdmin;

  const SocioCard({
    super.key,
    required this.socio,
    required this.onQr,
    required this.onEditar,
    required this.onEliminar,
    required this.onAsignarMembresia,
    this.esAdmin = false,
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
                  icon: const Icon(Icons.add_card, color: Colors.green),
                  tooltip: 'Asignar membresía',
                  onPressed: onAsignarMembresia,
                ),
                IconButton(
                  icon: const Icon(Icons.qr_code, color: Color(0xFF3B82F6)),
                  tooltip: 'Ver credencial QR',
                  onPressed: onQr,
                ),
                if (esAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    tooltip: 'Editar',
                    onPressed: onEditar,
                  ),
                if (esAdmin)
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