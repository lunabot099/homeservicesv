/// main.dart
/// Punto de entrada de HomeServiceSV.
/// Inicializa: flutter bindings, variables de entorno y Supabase.
/// Luego delega todo a App() — sin lógica de negocio aquí.
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'app/config/supabase_config.dart';

Future<void> main() async {
  // Garantiza que los bindings de Flutter estén listos antes de
  // llamar a código nativo (Supabase, plugins, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Carga variables de entorno si existe `.env`.
  // Si no existe, la app entra en modo demo/local y sigue funcionando.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Modo demo: sin credenciales locales de Supabase.
  }

  // Inicializa Supabase solo cuando hay credenciales reales.
  await SupabaseConfig.initialize();

  // Arranca la app — toda la lógica vive en App()
  runApp(const App());
}
