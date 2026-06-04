/// app_config.dart
/// Estado global de configuración runtime.
/// Permite que la app funcione en modo demo/local sin Supabase.
library;

class AppConfig {
  AppConfig._();

  static bool _supabaseEnabled = false;

  /// true cuando Supabase fue inicializado correctamente.
  static bool get supabaseEnabled => _supabaseEnabled;

  /// true cuando la app debe usar datos locales/demo.
  static bool get demoMode => !_supabaseEnabled;

  static void enableSupabase() {
    _supabaseEnabled = true;
  }

  static void enableDemoMode() {
    _supabaseEnabled = false;
  }
}
