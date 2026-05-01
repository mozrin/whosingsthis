import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

import '../services/gemini_service.dart';
import '../services/database_service.dart';

class RecognitionController {
  final _geminiService = GeminiService();
  final _dbService = DatabaseService();
  final _uuid = Uuid();

  Future<Response> handleFingerprint(Request request) async {
    try {
      // In a real app, we'd handle multipart/form-data for audio bytes
      // For this implementation, we'll assume the body is the raw audio bytes or a URL
      final playlistName = request.headers['x-playlist-name'] ?? '';
      
      // Generate a tracking UUID
      final trackUuid = _uuid.v4();

      // Start recognition process (async)
      _performRecognition(trackUuid, request, playlistName);

      return Response.ok(jsonEncode({
        'status': 'processing',
        'uuid': trackUuid,
      }), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<Response> getRecognitionResult(Request request, String uuid) async {
    try {
      final result = await _dbService.getRecognitionResult(uuid);
      if (result == null) {
        return Response.notFound(jsonEncode({'error': 'Result not found or still processing'}));
      }
      return Response.ok(jsonEncode(result), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }

  Future<void> _performRecognition(String uuid, Request request, String playlistName) async {
    try {
      final bytes = await request.read().toList();
      final audioBytes = bytes.expand((x) => x).toList();

      // 1. Send to Gemini Flash for recognition
      final trackInfo = await _geminiService.recognizeAudio(audioBytes);
      
      // Add playlist name to metadata if provided
      if (playlistName.isNotEmpty) {
        trackInfo['suggested_playlist_name'] = playlistName;
      }

      // 2. Store in Database
      await _dbService.saveRecognitionResult(uuid, trackInfo);
      
      print('Recognition complete for $uuid: ${trackInfo['title']} by ${trackInfo['artist']}');
    } catch (e) {
      print('Error during recognition for $uuid: $e');
      await _dbService.saveError(uuid, e.toString());
    }
  }
}
