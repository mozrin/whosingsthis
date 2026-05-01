import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

abstract class MusicProviderAdapter {
  Future<Map<String, dynamic>> createPlaylist(String userId, String name);
  Future<bool> addTrack(String playlistId, String trackId);
  Future<Map<String, dynamic>> searchTrack(String query);
}

class SpotifyAdapter implements MusicProviderAdapter {
  final _env = DotEnv(includePlatformEnvironment: true)..load();

  @override
  Future<Map<String, dynamic>> createPlaylist(String userId, String name) async {
    final token = _env['SPOTIFY_ACCESS_TOKEN'] ?? '';
    final url = Uri.parse('https://api.spotify.com/v1/users/$userId/playlists');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'public': false}),
    );

    return jsonDecode(response.body);
  }

  @override
  Future<bool> addTrack(String playlistId, String trackId) async {
    final token = _env['SPOTIFY_ACCESS_TOKEN'] ?? '';
    final url = Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uris': [trackId.startsWith('spotify:track:') ? trackId : 'spotify:track:$trackId']
      }),
    );

    return response.statusCode == 201;
  }

  @override
  Future<Map<String, dynamic>> searchTrack(String query) async {
    final token = _env['SPOTIFY_ACCESS_TOKEN'] ?? '';
    final url = Uri.parse('https://api.spotify.com/v1/search?q=${Uri.encodeComponent(query)}&type=track&limit=1');
    
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    return jsonDecode(response.body);
  }
}
