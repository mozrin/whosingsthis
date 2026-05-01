import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../adapters/spotify_adapter.dart';

class PlaylistController {
  final _spotifyAdapter = SpotifyAdapter();

  Future<Response> addToPlaylist(Request request, String uuid) async {
    try {
      final body = jsonDecode(await request.readAsString());
      final playlistId = body['playlist_id'];
      final trackId = body['track_id']; // This could be the Spotify URI

      final result = await _spotifyAdapter.addTrack(playlistId, trackId);

      return Response.ok(jsonEncode({
        'status': 'success',
        'result': result,
      }), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: jsonEncode({'error': e.toString()}));
    }
  }
}
