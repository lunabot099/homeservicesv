/// storage_service.dart
/// Servicio de subida y eliminación de archivos en Supabase Storage.
/// Todos los nombres de bucket se leen desde Env (que carga .env en runtime).
/// NO hardcodear nombres de bucket aquí — siempre usar Env.bucket*.
///
/// Métodos *Binary trabajan con Uint8List y son compatibles con Flutter Web.
library;

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/config/env.dart';

class StorageService {
  final SupabaseClient _client;

  StorageService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ── Chat ──────────────────────────────────────────────────────

  /// Sube una imagen enviada en el chat usando bytes.
  /// Compatible con Flutter Web, móvil y escritorio.
  Future<String> uploadChatImageBytes({
    required String chatId,
    required String userId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return uploadBinaryData(
      bucket: Env.bucketChatImagenes,
      path: '$chatId/${userId}_$ts.jpg',
      bytes: bytes,
      contentType: contentType,
    );
  }

  // ── Eliminación ───────────────────────────────────────────────

  /// Elimina un archivo de un bucket específico.
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }

  // ── Métodos Binary (Uint8List) — compatibles con Flutter Web ──
  // Usa uploadBinary de Supabase Storage en lugar de upload(File).

  /// Sube bytes a un bucket. Funciona en web, móvil y escritorio.
  Future<String> uploadBinaryData({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
    bool upsert = true,
  }) async {
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: upsert,
          ),
        );
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  /// Sube foto de perfil usando bytes.
  /// Bucket: perfil-fotos | Path: {userId}/perfil.jpg
  Future<String> uploadFotoPerfilBytes({
    required String userId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    return uploadBinaryData(
      bucket: Env.bucketPerfilFotos,
      path: '$userId/perfil.jpg',
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Sube foto del DUI usando bytes.
  /// Bucket: dui-documentos | Path: {userId}/dui.jpg
  Future<String> uploadFotoDuiBytes({
    required String userId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    return uploadBinaryData(
      bucket: Env.bucketDuiDocumentos,
      path: '$userId/dui.jpg',
      bytes: bytes,
      contentType: contentType,
    );
  }

  /// Sube documento de antecedentes penales usando bytes.
  /// Bucket: antecedentes-documentos | Path: {userId}/antecedentes.{ext}
  Future<String> uploadAntecedentesBytes({
    required String userId,
    required Uint8List bytes,
    String contentType = 'application/pdf',
  }) async {
    final ext = contentType == 'application/pdf' ? 'pdf' : 'jpg';
    return uploadBinaryData(
      bucket: Env.bucketAntecedentesDocumentos,
      path: '$userId/antecedentes.$ext',
      bytes: bytes,
      contentType: contentType,
    );
  }
}
