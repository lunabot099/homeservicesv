/// chats_repository.dart
/// Repositorio de chats y mensajes — abstrae ChatsService y MensajesService.
library;

import '../models/chat_model.dart';
import '../models/mensaje_chat_model.dart';
import '../../app/config/app_config.dart';
import '../services/chats_service.dart';
import '../services/mensajes_service.dart';

class ChatsRepository {
  ChatsService? _chatsService;
  MensajesService? _mensajesService;

  ChatsRepository({
    ChatsService? chatsService,
    MensajesService? mensajesService,
  })  : _chatsService = chatsService,
        _mensajesService = mensajesService;

  ChatsService get _activeChatsService {
    if (AppConfig.demoMode) {
      throw StateError('ChatsService no está disponible en modo demo.');
    }
    return _chatsService ??= ChatsService();
  }

  MensajesService get _activeMensajesService {
    if (AppConfig.demoMode) {
      throw StateError('MensajesService no está disponible en modo demo.');
    }
    return _mensajesService ??= MensajesService();
  }

  // ── Chat ─────────────────────────────────────────────────────

  /// Obtiene o crea el chat para una solicitud confirmada.
  Future<ChatModel> getOCrearChat({
    required String solicitudId,
    required String clienteId,
    required String trabajadorId,
  }) async {
    try {
      if (AppConfig.demoMode) {
        return ChatModel(
          id: 'demo-chat-$solicitudId',
          solicitudId: solicitudId,
          clienteId: clienteId,
          trabajadorId: trabajadorId,
          creadoEn: DateTime.now(),
        );
      }
      return await _activeChatsService.getOCrear(
        solicitudId: solicitudId,
        clienteId: clienteId,
        trabajadorId: trabajadorId,
      );
    } catch (e) {
      throw Exception('Error al obtener/crear chat: $e');
    }
  }

  /// Obtiene el chat de una solicitud.
  Future<ChatModel?> getChatDeSolicitud(String solicitudId) async {
    try {
      if (AppConfig.demoMode) return null;
      return await _activeChatsService.getBySolicitud(solicitudId);
    } catch (e) {
      throw Exception('Error al obtener chat: $e');
    }
  }

  /// Obtiene todos los chats del usuario.
  Future<List<ChatModel>> getMisChats(String userId) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeChatsService.getMisChats(userId);
    } catch (e) {
      throw Exception('Error al obtener chats: $e');
    }
  }

  /// Programa la eliminación de mensajes (llamar al completar servicio).
  Future<void> programarLimpieza(String chatId) async {
    try {
      if (AppConfig.demoMode) return;
      await _activeChatsService.programarEliminacion(chatId);
    } catch (e) {
      throw Exception('Error al programar limpieza: $e');
    }
  }

  // ── Mensajes ─────────────────────────────────────────────────

  /// Envía un mensaje de texto.
  Future<MensajeChatModel> enviarTexto({
    required String chatId,
    required String remitenteId,
    required String texto,
  }) async {
    try {
      final mensaje = MensajeChatModel(
        chatId: chatId,
        remitenteId: remitenteId,
        tipo: TipoMensaje.texto,
        contenido: texto,
        creadoEn: DateTime.now(),
      );
      if (AppConfig.demoMode) return mensaje;
      return await _activeMensajesService.enviar(mensaje);
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  /// Envía un mensaje con imagen (la URL ya viene de StorageService).
  Future<MensajeChatModel> enviarImagen({
    required String chatId,
    required String remitenteId,
    required String archivoUrl,
  }) async {
    try {
      final mensaje = MensajeChatModel(
        chatId: chatId,
        remitenteId: remitenteId,
        tipo: TipoMensaje.imagen,
        archivoUrl: archivoUrl,
        creadoEn: DateTime.now(),
      );
      if (AppConfig.demoMode) return mensaje;
      return await _activeMensajesService.enviar(mensaje);
    } catch (e) {
      throw Exception('Error al enviar imagen: $e');
    }
  }

  /// Obtiene los mensajes de un chat.
  Future<List<MensajeChatModel>> getMensajes(String chatId,
      {int limit = 50}) async {
    try {
      if (AppConfig.demoMode) return [];
      return await _activeMensajesService.getMensajes(chatId, limit: limit);
    } catch (e) {
      throw Exception('Error al obtener mensajes: $e');
    }
  }

  /// [Realtime] Stream de mensajes del chat.
  Stream<List<MensajeChatModel>> streamMensajes(String chatId) {
    if (AppConfig.demoMode) return Stream<List<MensajeChatModel>>.value([]);
    return _activeMensajesService.streamMensajes(chatId);
  }

  /// Marca todos los mensajes como leídos para el usuario actual.
  Future<void> marcarLeidos({
    required String chatId,
    required String usuarioId,
  }) async {
    try {
      if (AppConfig.demoMode) return;
      await _activeMensajesService.marcarLeidos(
          chatId: chatId, usuarioId: usuarioId);
    } catch (e) {
      throw Exception('Error al marcar mensajes: $e');
    }
  }

  /// Envía un mensaje de sistema automático.
  Future<void> enviarEventoSistema({
    required String chatId,
    required String contenido,
  }) async {
    try {
      if (AppConfig.demoMode) return;
      await _activeMensajesService.enviarMensajeSistema(
          chatId: chatId, contenido: contenido);
    } catch (e) {
      // Silencioso — los mensajes de sistema no son críticos
    }
  }
}
