import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

class DatabaseService {
  late final Connection? _connection;
  final _env = DotEnv(includePlatformEnvironment: true)..load();
  
  // In-memory fallback for development without a live DB
  final Map<String, Map<String, dynamic>> _cache = {};

  DatabaseService() {
    _init();
  }

  Future<void> _init() async {
    try {
      final host = _env['DB_HOST'] ?? 'localhost';
      final port = int.parse(_env['DB_PORT'] ?? '5432');
      final database = _env['DB_NAME'] ?? 'whosingsthis';
      final username = _env['DB_USER'] ?? 'postgres';
      final password = _env['DB_PASSWORD'] ?? 'postgres';

      _connection = await Connection.open(
        Endpoint(
          host: host,
          port: port,
          database: database,
          username: username,
          password: password,
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
    } catch (e) {
      print('Database connection failed: $e. Using in-memory fallback.');
      _connection = null;
    }
  }

  Future<void> saveRecognitionResult(String uuid, Map<String, dynamic> trackInfo) async {
    if (_connection != null) {
      try {
        await _connection.execute(
          'INSERT INTO tracks (title, artist, album, provider_id) VALUES (@title, @artist, @album, @pid) RETURNING track_id',
          parameters: {
            'title': trackInfo['title'],
            'artist': trackInfo['artist'],
            'album': trackInfo['album'],
            'pid': trackInfo['track_id'],
          },
        );
        // Additional logic to link fingerprint...
      } catch (e) {
        print('DB save error: $e');
      }
    }
    
    _cache[uuid] = trackInfo;
  }

  Future<Map<String, dynamic>?> getRecognitionResult(String uuid) async {
    return _cache[uuid];
  }

  Future<void> saveError(String uuid, String error) async {
    _cache[uuid] = {'status': 'error', 'message': error};
  }
}
