import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dotenv/dotenv.dart';

class GeminiService {
  late final GenerativeModel _model;
  final _env = DotEnv(includePlatformEnvironment: true)..load();

  GeminiService() {
    final apiKey = _env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }

  Future<Map<String, dynamic>> recognizeAudio(List<int> audioBytes) async {
    try {
      if (_env['GEMINI_API_KEY'] == null) {
        // Mock response if no API key is provided
        return {
          'title': 'Mock Track',
          'artist': 'Mock Artist',
          'album': 'Mock Album',
          'confidence': 0.95,
          'track_id': 'mock-id-123',
        };
      }

      final prompt = 'Identify this song from the audio snippet. Return a JSON object with title, artist, album, and release_year.';
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('audio/mpeg', Uint8List.fromList(audioBytes)),
        ])
      ];

      final response = await _model.generateContent(content);
      final text = response.text ?? '{}';
      
      // Clean up markdown code blocks if present
      final jsonString = text.replaceAll('```json', '').replaceAll('```', '').trim();
      return jsonDecode(jsonString);
    } catch (e) {
      print('Gemini recognition error: $e');
      rethrow;
    }
  }
}
