import 'package:supabase_flutter/supabase_flutter.dart';

/// Crea recepcionistas mediante la Edge Function 'crear-recepcionista'.
class RecepcionistaService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Lanza una [Exception] con un mensaje legible si algo falla.
  Future<void> crear({
    required String email,
    required String password,
  }) async {
    try {
      await _client.functions.invoke(
  'dynamic-endpoint',
  body: {'email': email, 'password': password},
);
    } on FunctionException catch (e) {
      // La función responde {"error": "mensaje"} cuando algo sale mal
      final detalle = e.details;
      if (detalle is Map && detalle['error'] != null) {
        throw Exception(detalle['error']);
      }
      throw Exception('No se pudo crear el recepcionista (código ${e.status})');
    }
  }
}
