/// solicitudes_repository.dart
/// Repositorio de solicitudes — extendido en Fase 3 con métodos del trabajador.
library;

import '../models/solicitud_servicio_model.dart';
import '../../app/config/app_config.dart';
import '../services/solicitudes_service.dart';

class SolicitudesRepository {
  SolicitudesService? _service;

  SolicitudesRepository({SolicitudesService? service}) : _service = service;

  SolicitudesService get _activeService {
    if (AppConfig.demoMode) {
      throw StateError('SolicitudesService no está disponible en modo demo.');
    }
    return _service ??= SolicitudesService();
  }

  // ── Cliente ───────────────────────────────────────────────────

  Future<SolicitudServicioModel> createSolicitud(SolicitudServicioModel s) async {
    try {
      if (AppConfig.demoMode) return s;
      return await _activeService.createSolicitud(s);
    } catch (e) {
      throw Exception('No se pudo crear la solicitud: $e');
    }
  }

  Future<List<SolicitudServicioModel>> getSolicitudesByCliente(
      String clienteId) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeService.getSolicitudesByCliente(clienteId);
    } catch (e) {
      throw Exception('No se pudieron obtener las solicitudes: $e');
    }
  }

  Future<SolicitudServicioModel?> getSolicitudById(String id) async {
    try {
      if (AppConfig.demoMode) return null;
      return await _activeService.getSolicitudById(id);
    } catch (e) {
      throw Exception('No se pudo obtener la solicitud: $e');
    }
  }

  Future<void> cancelarSolicitud(String id) async {
    try {
      if (AppConfig.demoMode) return;
      await _activeService.cancelarSolicitud(id);
    } catch (e) {
      throw Exception('No se pudo cancelar la solicitud: $e');
    }
  }

  // ── Trabajador ────────────────────────────────────────────────

  /// Solicitudes disponibles para postularse.
  Future<List<SolicitudServicioModel>> getSolicitudesDisponibles({
    String? departamento,
    String? categoriaId,
  }) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeService.getSolicitudesDisponibles(
          departamento: departamento, categoriaId: categoriaId);
    } catch (e) {
      throw Exception('No se pudieron obtener solicitudes disponibles: $e');
    }
  }

  /// Solicitudes activas donde el trabajador fue seleccionado.
  Future<List<SolicitudServicioModel>> getSolicitudesActivasTrabajador(
      String trabajadorId) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeService.getSolicitudesActivasTrabajador(trabajadorId);
    } catch (e) {
      throw Exception('No se pudieron obtener solicitudes activas: $e');
    }
  }

  /// Historial completo del trabajador.
  Future<List<SolicitudServicioModel>> getHistorialTrabajador(
      String trabajadorId) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeService.getHistorialTrabajador(trabajadorId);
    } catch (e) {
      throw Exception('No se pudo obtener historial: $e');
    }
  }

  // ── Estado del servicio ───────────────────────────────────────

  /// Actualiza el estado del servicio (cliente o trabajador).
  Future<SolicitudServicioModel> updateEstado({
    required String id,
    required EstadoSolicitud estado,
    String? trabajadorId,
  }) async {
    try {
      if (AppConfig.demoMode) {
        final solicitud = await getSolicitudById(id);
        if (solicitud == null) {
          throw Exception('Solicitud demo no encontrada.');
        }
        return solicitud.copyWith(estado: estado, trabajadorId: trabajadorId);
      }
      return await _activeService.updateEstado(
        id: id,
        estado: estado,
        trabajadorId: trabajadorId,
      );
    } catch (e) {
      throw Exception('No se pudo actualizar el estado: $e');
    }
  }

  // ── Realtime ──────────────────────────────────────────────────

  Stream<SolicitudServicioModel?> streamSolicitud(String solicitudId) =>
      AppConfig.demoMode
          ? Stream<SolicitudServicioModel?>.empty()
          : _activeService.streamSolicitud(solicitudId);

  Stream<List<SolicitudServicioModel>> streamSolicitudesDisponibles({
    String? departamento,
  }) =>
      AppConfig.demoMode
          ? Stream<List<SolicitudServicioModel>>.value([])
          : _activeService.streamSolicitudesDisponibles(departamento: departamento);

  // ── Expiración automática ─────────────────────────────────────────────────

  /// Expira solicitudes sin aceptar con más de 1 hora de antigüedad.
  Future<void> expirarSolicitudesAntiguas() async {
    try {
      if (AppConfig.demoMode) return;
      await _activeService.expirarSolicitudesAntiguas();
    } catch (_) {}
  }

  /// Elimina solicitudes expiradas con más de 90 minutos de antigüedad.
  Future<void> limpiarExpiradas() async {
    try {
      if (AppConfig.demoMode) return;
      await _activeService.limpiarExpiradas();
    } catch (_) {}
  }
}
