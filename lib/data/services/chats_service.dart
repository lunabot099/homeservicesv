/// chats_service.dart
/// Servicio para operaciones sobre la tabla `chats`.
///
/// Regla: Un solo chat por solicitud. Se crea al confirmar el servicio.
/// La base actual usa fecha_creacion/fecha_actualizacion y no tiene columna
/// eliminar_mensajes_en; la limpieza automática se implementará con SQL posterior.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';

class ChatsService {
  final SupabaseClient _client;
  static const _table = 'chats';

  ChatsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Obtiene el chat de una solicitud, o lo crea si no existe.
  Future<ChatModel> getOCrear({
    required String solicitudId,
    required String clienteId,
    required String trabajadorId,
  }) async {
    // Intentar obtener chat existente
    final existing = await _client
        .from(_table)
        .select()
        .eq('solicitud_id', solicitudId)
        .maybeSingle();

    if (existing != null) {
      return ChatModel.fromMap(existing);
    }

    // Crear nuevo chat
    final data = await _client.from(_table).insert({
      'solicitud_id': solicitudId,
      'cliente_id': clienteId,
      'trabajador_id': trabajadorId,
    }).select().single();

    return ChatModel.fromMap(data);
  }

  /// Obtiene el chat asociado a una solicitud.
  Future<ChatModel?> getBySolicitud(String solicitudId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('solicitud_id', solicitudId)
        .maybeSingle();
    return data != null ? ChatModel.fromMap(data) : null;
  }

  /// Obtiene todos los chats de un usuario (cliente o trabajador).
  Future<List<ChatModel>> getMisChats(String userId) async {
    // OR en postGREST: buscar como cliente O como trabajador
    final data = await _client
        .from(_table)
        .select()
        .or('cliente_id.eq.$userId,trabajador_id.eq.$userId')
        .order('fecha_creacion', ascending: false);
    return (data as List)
        .map((e) => ChatModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Placeholder seguro: la base actual no tiene `eliminar_mensajes_en`.
  /// Cuando se defina la base final, se puede agregar esa columna o resolverlo
  /// con una tarea SQL/cron del lado de Supabase.
  Future<void> programarEliminacion(String chatId) async {
    await _client
        .from(_table)
        .update({'fecha_actualizacion': DateTime.now().toIso8601String()})
        .eq('id', chatId);
  }
}
