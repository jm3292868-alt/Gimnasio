import 'package:flutter/material.dart';

/// Buscador + chips de filtro (Todos / Vigente / Vencido).
class SociosFiltros extends StatelessWidget {
  final String filtroActual;
  final ValueChanged<String> onBusqueda;
  final ValueChanged<String> onFiltro;

  const SociosFiltros({
    super.key,
    required this.filtroActual,
    required this.onBusqueda,
    required this.onFiltro,
  });

  static const _filtros = ['Todos', 'Vigente', 'Vencido'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Buscar socio por nombre o ID...',
            border: OutlineInputBorder(),
          ),
          onChanged: onBusqueda,
        ),
        const SizedBox(height: 10),
        Row(
          children: _filtros.map((f) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: filtroActual == f,
                onSelected: (_) => onFiltro(f),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
