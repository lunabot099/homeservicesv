/// chat_model.dart
/// Modelo de la tabla `chats`.
/// Cada chat está ligado a una solicitud de servicio específica.
///
/// Regla de negocio:
/// - Solo existe UN chat por solicitud
/// - Se crea cuando el trabajador es seleccionado y el servicio se confirma
/// - Los mensajes se eliminan automáticamente 7 días después de finalizado el trabajo
library;

class ChatModel {
  final String? id;
  final String solicitudId;
  final String clienteId;
  final String trabajadorId;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  // ── Campos de presentación (NO columnas de BD) ────────────────────────────
  /// Texto del último mensaje — se puebla desde un JOIN/RPC, no desde la tabla `chats`.
  final String? ultimoMensaje;
  /// Cantidad de mensajes no leídos — campo calculado, no almacenado.
  final int? mensajesNoLeidos;

  const ChatModel({
    this.id,
    required this.solicitudId,
    required this.clienteId,
    required this.trabajadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    // Presentación
    this.ultimoMensaje,
    this.mensajesNoLeidos,
  });

  /// Alias de compatibilidad para vistas que aún usan `creadoEn`.
  DateTime? get creadoEn => fechaCreacion;

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String?,
      solicitudId: map['solicitud_id'] as String,
      clienteId: map['cliente_id'] as String,
      trabajadorId: map['trabajador_id'] as String,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.tryParse(map['fecha_creacion'] as String)
          : null,
      fechaActualizacion: map['fecha_actualizacion'] != null
          ? DateTime.tryParse(map['fecha_actualizacion'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'solicitud_id': solicitudId,
        'cliente_id': clienteId,
        'trabajador_id': trabajadorId,
        // fecha_creacion y fecha_actualizacion las maneja Supabase.
        // ultimoMensaje y mensajesNoLeidos son de presentación — no se persisten
      };

  @override
  String toString() =>
      'ChatModel(id: $id, solicitudId: $solicitudId)';
}
