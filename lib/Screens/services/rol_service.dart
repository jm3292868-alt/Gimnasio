import 'package:supabase_flutter/supabase_flutter.dart';

class RolService {
  static String? get rol =>
      Supabase.instance.client.auth.currentUser?.appMetadata['rol'] as String?;

  /// Solo el administrador puede editar, borrar y crear recepcionistas.
  static bool get esAdmin => rol == 'admin';
}