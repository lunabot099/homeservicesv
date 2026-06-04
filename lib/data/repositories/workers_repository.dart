/// workers_repository.dart
/// Repositorio de perfiles de trabajadores.
/// Abstracción entre ViewModels y WorkersService.
library;

import '../models/worker_profile_model.dart';
import '../../app/config/app_config.dart';
import '../services/workers_service.dart';

class WorkersRepository {
  WorkersService? _service;

  WorkersRepository({WorkersService? service}) : _service = service;

  WorkersService get _activeService {
    if (AppConfig.demoMode) {
      throw StateError('WorkersService no está disponible en modo demo.');
    }
    return _service ??= WorkersService();
  }

  /// Obtiene el perfil de trabajador por ID.
  Future<WorkerProfileModel?> getWorkerById(String id) async {
    try {
      if (AppConfig.demoMode) return null;
      return await _activeService.getWorkerById(id);
    } catch (e) {
      throw Exception('No se pudo obtener el perfil del trabajador: ${e.toString()}');
    }
  }

  /// Crea un perfil de trabajador.
  Future<WorkerProfileModel> createWorkerProfile(WorkerProfileModel profile) async {
    try {
      if (AppConfig.demoMode) return profile;
      return await _activeService.createWorkerProfile(profile);
    } catch (e) {
      throw Exception('No se pudo crear el perfil del trabajador: ${e.toString()}');
    }
  }

  /// Obtiene todos los trabajadores verificados y disponibles.
  Future<List<WorkerProfileModel>> getWorkersDisponibles() async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeService.getWorkersDisponibles();
    } catch (e) {
      throw Exception('No se pudieron obtener los trabajadores: ${e.toString()}');
    }
  }

  /// Actualiza el perfil de un trabajador.
  Future<WorkerProfileModel> updateWorkerProfile({
    required String id,
    required Map<String, dynamic> fields,
  }) async {
    try {
      return await _activeService.updateWorkerProfile(id: id, fields: fields);
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil: ${e.toString()}');
    }
  }
}
