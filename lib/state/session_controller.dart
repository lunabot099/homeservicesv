/// session_controller.dart
/// Controlador global de sesión de usuario.
/// Es un ChangeNotifier que escucha cambios de autenticación en Supabase
/// y expone el estado de sesión a toda la app mediante Provider.
library;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app/config/app_config.dart';
import '../data/models/perfil_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/perfiles_repository.dart';

class SessionController extends ChangeNotifier {
  final AuthRepository _authRepository;
  final PerfilesRepository _perfilesRepository;

  User? _currentUser;
  PerfilModel? _currentPerfil;
  bool _isDemoAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  SessionController({
    AuthRepository? authRepository,
    PerfilesRepository? perfilesRepository,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _perfilesRepository = perfilesRepository ?? PerfilesRepository() {
    if (!AppConfig.demoMode) {
      // Escuchar cambios de autenticación automáticamente solo con Supabase activo.
      _authRepository.authStateChanges.listen(_onAuthStateChanged);
      _initSession();
    }
  }

  // ── Getters ─────────────────────────────────────────────────
  User? get currentUser => _currentUser;
  PerfilModel? get currentPerfil => _currentPerfil;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null || _isDemoAuthenticated;
  UserRole? get currentRole => _currentPerfil?.rol;

  // ── Inicialización ───────────────────────────────────────────
  Future<void> _initSession() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      _currentUser = user;
      await _loadPerfil(user.id);
    }
  }

  // ── Listener de auth ─────────────────────────────────────────
  Future<void> _onAuthStateChanged(AuthState state) async {
    final event = state.event;
    final user = state.session?.user;

    if (event == AuthChangeEvent.signedIn && user != null) {
      _currentUser = user;
      await _loadPerfil(user.id);
    } else if (event == AuthChangeEvent.signedOut) {
      _currentUser = null;
      _currentPerfil = null;
    }
    notifyListeners();
  }

  // ── Carga de perfil ──────────────────────────────────────────
  Future<void> _loadPerfil(String userId) async {
    try {
      _currentPerfil = await _perfilesRepository.getPerfilById(userId);
    } catch (_) {
      // El perfil puede no existir todavía (usuario recién registrado)
      _currentPerfil = null;
    }
    notifyListeners();
  }

  // ── Acciones públicas ────────────────────────────────────────

  /// Fuerza la recarga del perfil del usuario actual.
  Future<void> refreshPerfil() async {
    if (AppConfig.demoMode) return;
    if (_currentUser == null) return;
    await _loadPerfil(_currentUser!.id);
  }

  /// Inicia una sesión local/demo sin tocar Supabase.
  Future<void> startDemoSession({
    required UserRole role,
    required String nombreCompleto,
    required String correo,
    String? telefono,
  }) async {
    _isDemoAuthenticated = true;
    _currentPerfil = PerfilModel(
      id: 'demo-${role.name}',
      nombreCompleto: nombreCompleto,
      correo: correo,
      telefono: telefono,
      rol: role,
    );
    _error = null;
    notifyListeners();
  }

  /// Cierra la sesión del usuario.
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!AppConfig.demoMode) {
        await _authRepository.signOut();
      }
      _currentUser = null;
      _currentPerfil = null;
      _isDemoAuthenticated = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpia el error actual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
