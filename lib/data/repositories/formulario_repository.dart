/// formulario_repository.dart
/// Repositorio del formulario de aplicación de trabajadores.
/// Abstracción entre ViewModels y FormularioService.
library;

import '../models/formulario_trabajador_model.dart';
import '../../app/config/app_config.dart';
import '../services/formulario_service.dart';

class FormularioRepository {
  FormularioService? _service;

  FormularioRepository({FormularioService? service}) : _service = service;

  FormularioService get _activeService {
    if (AppConfig.demoMode) {
      throw StateError('FormularioService no está disponible en modo demo.');
    }
    return _service ??= FormularioService();
  }

  /// Envía el formulario de aplicación de un trabajador.
  Future<FormularioTrabajadorModel> submitFormulario(
    FormularioTrabajadorModel formulario,
  ) async {
    try {
      if (AppConfig.demoMode) return formulario;
      return await _activeService.submitFormulario(formulario);
    } catch (e) {
      throw Exception('No se pudo enviar el formulario: ${e.toString()}');
    }
  }

  /// Consulta el estado de un formulario por correo.
  Future<FormularioTrabajadorModel?> getFormularioByCorreo(String correo) async {
    try {
      if (AppConfig.demoMode) return null;
      return await _activeService.getFormularioByCorreo(correo);
    } catch (e) {
      throw Exception('No se pudo consultar el formulario: ${e.toString()}');
    }
  }

  /// Obtiene un formulario por ID.
  Future<FormularioTrabajadorModel?> getFormularioById(String id) async {
    try {
      if (AppConfig.demoMode) return null;
      return await _activeService.getFormularioById(id);
    } catch (e) {
      throw Exception('No se pudo obtener el formulario: ${e.toString()}');
    }
  }
}
