/// booking_confirmation_viewmodel.dart
library;

import 'package:flutter/foundation.dart';
import '../../../data/models/postulacion_solicitud_model.dart';
import '../../../data/models/solicitud_servicio_model.dart';
import '../../../data/repositories/solicitudes_repository.dart';

class BookingConfirmationViewModel extends ChangeNotifier {
  final SolicitudesRepository _solicitudesRepository;

  SolicitudServicioModel? _solicitud;
  WorkerCatalogItemModel? _trabajador;
  bool _isLoading = false;
  String? _error;

  BookingConfirmationViewModel({
    SolicitudesRepository? solicitudesRepository,
  }) : _solicitudesRepository =
            solicitudesRepository ?? SolicitudesRepository();

  SolicitudServicioModel? get solicitud => _solicitud;
  WorkerCatalogItemModel? get trabajador => _trabajador;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void load({
    required SolicitudServicioModel solicitud,
    required WorkerCatalogItemModel trabajador,
  }) {
    _solicitud = solicitud;
    _trabajador = trabajador;
    notifyListeners();
  }

  /// Confirma al trabajador seleccionado en Supabase.
  Future<bool> confirmar() async {
    final solicitud = _solicitud;
    final trabajador = _trabajador;

    if (solicitud?.id == null || trabajador == null) {
      _error = 'No hay datos suficientes para confirmar el servicio.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _solicitudesRepository.updateEstado(
        id: solicitud!.id!,
        estado: EstadoSolicitud.confirmada,
        trabajadorId: trabajador.trabajadorId,
      );
      _solicitud = updated;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
