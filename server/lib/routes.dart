import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import 'controllers/recognition_controller.dart';
import 'controllers/playlist_controller.dart';

class ApiRoutes {
  Router get router {
    final router = Router();
    final recognitionController = RecognitionController();
    final playlistController = PlaylistController();

    // 1. POST /fingerprint -> Upload audio snippet
    router.post('/fingerprint', recognitionController.handleFingerprint);

    // 2. GET /recognize/<uuid> -> Retrieve recognition result
    router.get('/recognize/<uuid>', recognitionController.getRecognitionResult);

    // 3. POST /playlist/<uuid> -> Add recognized track to playlist
    router.post('/playlist/<uuid>', playlistController.addToPlaylist);

    // Health check
    router.get('/health', (Request request) => Response.ok('OK'));

    return router;
  }
}
