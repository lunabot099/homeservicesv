/// postulaciones_repository.dart
/// Repositorio de postulaciones — abstrae PostulacionesService.
library;

import '../models/postulacion_solicitud_model.dart';
import '../../app/config/app_config.dart';
import '../services/postulaciones_service.dart';

class PostulacionesRepository {
  PostulacionesService? _service;

  PostulacionesRepository({PostulacionesService? service}) : _service = service;

  PostulacionesService get _activeService {
    if (AppConfig.demoMode) {
      throw StateError('PostulacionesService no está disponible en modo demo.');
    }
    return _service ??= PostulacionesService();
  }

  /// Postula a un trabajador a una solicitud.
  Future<PostulacionSolicitudModel> postularse(
      PostulacionSolicitudModel p) async {
    try {
      if (AppConfig.demoMode) return p;
      final yaExiste = await _activeService.yaPostulado(
          solicitudId: p.solicitudId, trabajadorId: p.trabajadorId);
      if (yaExiste) {
        throw Exception('Ya te has postulado a esta solicitud.');
      }
      return await _activeService.create(p);
    } catch (e) {
      throw Exception('Error al postularse: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  /// Obtiene las postulaciones de una solicitud.
  Future<List<PostulacionSolicitudModel>> getPostulacionesDeSolicitud(
      String solicitudId) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeService.getBySolicitud(solicitudId);
    } catch (e) {
      throw Exception('Error al obtener postulaciones: $e');
    }
  }

  /// Obtiene las postulaciones activas del trabajador.
  Future<List<PostulacionSolicitudModel>> getMisPostulaciones(
      String trabajadorId) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeService.getByTrabajador(trabajadorId);
    } catch (e) {
      throw Exception('Error al obtener mis postulaciones: $e');
    }
  }

  /// Selecciona una postulación (acepta al trabajador).
  Future<void> seleccionarTrabajador(String postulacionId) async {
    try {
      if (AppConfig.demoMode) return;
      await _activeService.updateEstado(postulacionId, EstadoPostulacion.aceptada);
    } catch (e) {
      throw Exception('Error al seleccionar trabajador: $e');
    }
  }

  /// Rechaza/cancela una postulación.
  Future<void> rechazarPostulacion(String postulacionId) async {
    try {
      if (AppConfig.demoMode) return;
      await _activeService.updateEstado(postulacionId, EstadoPostulacion.rechazada);
    } catch (e) {
      throw Exception('Error al rechazar postulación: $e');
    }
  }

  /// [Realtime] Stream de postulaciones de una solicitud (para el cliente).
  Stream<List<PostulacionSolicitudModel>> streamPostulaciones(
      String solicitudId) {
    if (AppConfig.demoMode) return Stream<List<PostulacionSolicitudModel>>.value([]);
    return _activeService.streamBySolicitud(solicitudId);
  }

  /// [Realtime] Stream de mis postulaciones (para el trabajador).
  Stream<List<PostulacionSolicitudModel>> streamMisPostulaciones(
      String trabajadorId) {
    if (AppConfig.demoMode) return Stream<List<PostulacionSolicitudModel>>.value([]);
    return _activeService.streamByTrabajador(trabajadorId);
  }

  /// Acepta la postulación indicada y rechaza las demás de la misma solicitud.
  /// Llamar desde el cliente al seleccionar a un trabajador.
  Future<void> aceptarTrabajadorYRechazarOtros({
    required String postulacionId,
    required String solicitudId,
  }) async {
    try {
      // 1. Marcar la elegida como aceptada
      if (AppConfig.demoMode) return;
      await _activeService.updateEstado(postulacionId, EstadoPostulacion.aceptada);
      // 2. Rechazar todas las demás pendientes de esa solicitud
      await _activeService.rechazarOtrasPostulaciones(
        solicitudId: solicitudId,
        postulacionAceptadaId: postulacionId,
      );
    } catch (e) {
      throw Exception('Error al aceptar trabajador: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}
