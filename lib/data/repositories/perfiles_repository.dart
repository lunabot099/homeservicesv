/// perfiles_repository.dart
/// Repositorio de perfiles de usuario.
/// Abstracción entre ViewModels y PerfilesService.
library;

import '../../app/config/app_config.dart';
import '../models/perfil_model.dart';
import '../services/perfiles_service.dart';

class PerfilesRepository {
  PerfilesService? _service;

  PerfilesRepository({PerfilesService? service}) : _service = service;

  PerfilesService get _activeService {
    if (AppConfig.demoMode) {
      throw StateError('PerfilesService no está disponible en modo demo.');
    }
    return _service ??= PerfilesService();
  }

  /// Obtiene el perfil de un usuario por su ID.
  /// Retorna null si no existe.
  Future<PerfilModel?> getPerfilById(String id) async {
    try {
      return await _activeService.getPerfilById(id);
    } catch (e) {
      throw Exception('No se pudo obtener el perfil: ${e.toString()}');
    }
  }

  /// Crea un nuevo perfil de usuario.
  Future<PerfilModel> createPerfil(PerfilModel perfil) async {
    try {
      if (AppConfig.demoMode) return perfil;
      return await _activeService.createPerfil(perfil);
    } catch (e) {
      throw Exception('No se pudo crear el perfil: ${e.toString()}');
    }
  }

  /// Actualiza campos específicos de un perfil.
  Future<PerfilModel> updatePerfil({
    required String id,
    required Map<String, dynamic> fields,
  }) async {
    try {
      return await _activeService.updatePerfil(id: id, fields: fields);
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil: ${e.toString()}');
    }
  }
}
