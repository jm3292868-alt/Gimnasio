import 'package:supabase_flutter/supabase_flutter.dart';

/// Toda la comunicación con Supabase relacionada a membresías.
class MembresiaService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _tabla = 'membresias';

  /// Lista de membresías, la más reciente primero.
  Future<List<Map<String, dynamic>>> obtenerMembresias() async {
    final datos = await _client.from(_tabla).select().order('id', ascending: false);
    return List<Map<String, dynamic>>.from(datos);
  }

  /// Actualiza una membresía existente.
  Future<void> actualizar({
    required int id,
    required String nombre,
    required double precio,
    required String frecuenciaPago,
    required String estado,
    required int duracionDias,
  }) async {
    await _client.from(_tabla).update({
      'nombre': nombre,
      'precio': precio,
      'frecuencia_pago': frecuenciaPago,
      'estado': estado,
      'duracion_dias': duracionDias,
    }).eq('id', id);
  }

  /// Elimina una membresía por su id.
  Future<void> eliminar(int id) async {
    await _client.from(_tabla).delete().eq('id', id);
  }
}
