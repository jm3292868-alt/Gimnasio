import 'package:flutter/material.dart';

/// Tarjeta de una membresía con acciones: editar y eliminar.
/// Las acciones solo se muestran si [esAdmin] es true.
class MembresiaCard extends StatelessWidget {
  final Map<String, dynamic> membresia;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final bool esAdmin;

  const MembresiaCard({
    super.key,
    required this.membresia,
    required this.onEditar,
    required this.onEliminar,
    this.esAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final m = membresia;
    final activa = m['estado'] == 'Activa';

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('${m['nombre']}'),
            subtitle: Text(
              'Costo: \$${m['precio']}\n'
              'Pago: ${m['frecuencia_pago']}\n'
              'Duración: ${m['duracion_dias']} días',
            ),
            isThreeLine: true,
            trailing: Text(
              '${m['estado']}',
              style: TextStyle(
                color: activa ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (esAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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