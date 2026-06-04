/// supabase_config.dart
/// Inicialización y acceso centralizado al cliente Supabase.
/// Debe llamarse una sola vez en main.dart antes de runApp.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';
import 'env.dart';

class SupabaseConfig {
  SupabaseConfig._(); // No instanciar

  /// Inicializa Supabase solo si hay credenciales reales en `.env`.
  /// Si faltan, activa modo demo/local para que la app siga funcionando.
  static Future<void> initialize() async {
    final url = Env.optionalSupabaseUrl;
    final anonKey = Env.optionalSupabaseAnonKey;

    if (url == null || anonKey == null) {
      AppConfig.enableDemoMode();
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    AppConfig.enableSupabase();
  }

  /// Acceso directo al cliente de Supabase ya inicializado.
  static SupabaseClient get client => Supabase.instance.client;
}
