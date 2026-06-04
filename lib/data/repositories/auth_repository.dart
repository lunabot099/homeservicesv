/// auth_repository.dart
/// Repositorio de autenticación.
/// Actúa como capa de abstracción entre ViewModels y AuthService.
/// Los ViewModels SOLO interactúan con repositories, nunca con services directamente.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/config/app_config.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthService? _authService;

  AuthRepository({AuthService? authService}) : _authService = authService;

  AuthService get _service {
    if (AppConfig.demoMode) {
      throw StateError('AuthService no está disponible en modo demo.');
    }
    return _authService ??= AuthService();
  }

  /// Intenta iniciar sesión con email y contraseña.
  /// Retorna el [User] en caso de éxito.
  /// Lanza [Exception] con mensaje descriptivo en caso de error.
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _service.signInWithEmail(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo iniciar sesión. Verifica tus credenciales.');
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  /// Registra un nuevo usuario.
  /// Retorna el [User] creado.
  Future<User> signUp({
    required String email,
    required String password,
    String? nombreCompleto,
  }) async {
    try {
      final response = await _service.signUpWithEmail(
        email: email,
        password: password,
        nombreCompleto: nombreCompleto,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo crear la cuenta. Intenta de nuevo.');
      }
      return user;
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    if (AppConfig.demoMode) return;
    await _service.signOut();
  }

  /// Retorna el usuario autenticado actualmente, o null.
  User? get currentUser => AppConfig.demoMode ? null : _service.currentUser;

  /// Stream de cambios de estado de autenticación.
  Stream<AuthState> get authStateChanges => AppConfig.demoMode
      ? Stream<AuthState>.empty()
      : _service.onAuthStateChange;

  /// Envía email para restablecer contraseña.
  Future<void> resetPassword(String email) async {
    try {
      if (AppConfig.demoMode) return;
      await _service.resetPassword(email);
    } on AuthException catch (e) {
      throw Exception(_mapAuthError(e.message));
    }
  }

  /// Traduce mensajes de error de Supabase a mensajes amigables en español.
  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de ingresar.';
    }
    if (message.contains('User already registered')) {
      return 'Ya existe una cuenta con este correo.';
    }
    if (message.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return 'Ocurrió un error. Intenta nuevamente.';
  }
}
