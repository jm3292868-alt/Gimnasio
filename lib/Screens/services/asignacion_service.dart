import 'package:supabase_flutter/supabase_flutter.dart';

class AsignacionService {
  final _supabase = Supabase.instance.client;

  // Solo las membresías activas se pueden asignar
  Future<List<Map<String, dynamic>>> obtenerMembresiasActivas() async {
    final datos = await _supabase
        .from('membresias')
        .select()
        .eq('estado', 'Activa')
        .order('nombre');

    return List<Map<String, dynamic>>.from(datos);
  }

  // Guarda la asignación en la tabla asignaciones
  Future<void> asignar({
    required int socioId,
    required int membresiaId,
    required DateTime fechaInicio,
    required DateTime fechaVencimiento,
    required String metodoPago,
    required double total,
  }) async {
    await _supabase.from('asignaciones').insert({
      'socio_id': socioId,
      'membresia_id': membresiaId,
      'fecha_inicio': fechaInicio.toString().substring(0, 10),
      'fecha_vencimiento': fechaVencimiento.toString().substring(0, 10),
      'metodo_pago': metodoPago,
      'total': total,
    });
  }
}