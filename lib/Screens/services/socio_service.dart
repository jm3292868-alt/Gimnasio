import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Toda la comunicación con Supabase relacionada a socios.
class SocioService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _bucketFotos = 'fotos_socios';
  static const String _tablaSocios = 'socios';
  static const String _vistaSocios = 'socios_con_estado';

  /// Lista de socios desde la vista que calcula Vigente/Vencido.
  Future<List<Map<String, dynamic>>> obtenerSocios() async {
    final datos =
        await _client.from(_vistaSocios).select().order('id', ascending: false);
    return List<Map<String, dynamic>>.from(datos);
  }

  /// Busca un socio por id en la vista (con su estado actual).
  /// Regresa null si no existe.
  Future<Map<String, dynamic>?> obtenerSocioPorId(int id) async {
    return await _client
        .from(_vistaSocios)
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  /// Sube la foto al bucket y regresa la URL pública.
  Future<String> subirFoto(File imagen, String nombre) async {
    final nombreArchivo =
        '${DateTime.now().millisecondsSinceEpoch}_${nombre.trim()}.jpg';

    await _client.storage.from(_bucketFotos).upload(nombreArchivo, imagen);

    return _client.storage.from(_bucketFotos).getPublicUrl(nombreArchivo);
  }

  /// Inserta el socio en la tabla 'socios'.
  Future<void> registrar({
    required String nombre,
    required String apellidos,
    required int edad,
    required String? padecimientos,
    required String telefono,
    required String genero,
    required String? fotoUrl,
  }) async {
    await _client.from(_tablaSocios).insert({
      'nombre': nombre,
      'apellidos': apellidos,
      'edad': edad,
      'padecimientos': padecimientos,
      'telefono': telefono,
      'genero': genero,
      'foto_url': fotoUrl,
    });
  }

  /// Actualiza los datos de un socio existente.
  Future<void> actualizar({
    required int id,
    required String nombre,
    required String apellidos,
    required int edad,
    required String? padecimientos,
    required String telefono,
    required String genero,
  }) async {
    await _client.from(_tablaSocios).update({
      'nombre': nombre,
      'apellidos': apellidos,
      'edad': edad,
      'padecimientos': padecimientos,
      'telefono': telefono,
      'genero': genero,
    }).eq('id', id);
  }

  /// Elimina un socio por su id.
  Future<void> eliminar(int id) async {
    await _client.from(_tablaSocios).delete().eq('id', id);
  }
}