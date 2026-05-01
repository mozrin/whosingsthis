import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class RecognitionProvider with ChangeNotifier {
  AudioRecorder? _recorder;
  bool _isRecording = false;
  String? _lastResultUuid;
  Map<String, dynamic>? _result;
  String _status = 'idle'; // idle, recording, processing, success, error
  String _playlistName = '';

  AudioRecorder get _audioRecorder {
    _recorder ??= AudioRecorder();
    return _recorder!;
  }

  bool get isRecording => _isRecording;
  String get status => _status;
  Map<String, dynamic>? get result => _result;
  String get playlistName => _playlistName;

  set playlistName(String value) {
    _playlistName = value;
    notifyListeners();
  }

  // Global AI Standards: Use the IP address 192.168.1.189
  // AcoustID API Key (User should replace this)
  final String _acoustidApiKey = '8W9pbdS2'; 
  final String _acoustidUrl = 'https://api.acoustid.org/v2/lookup';
  final String _baseUrl = 'http://192.168.1.189:8080';

  Future<void> startListening() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        _isRecording = true;
        _status = 'recording';
        _result = null;
        notifyListeners();

        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/snippet.m4a';

        const config = RecordConfig();
        await _audioRecorder.start(config, path: path);

        // Record for 5 seconds then stop automatically
        Future.delayed(const Duration(seconds: 5), () async {
          if (_isRecording) {
            await stopListening();
          }
        });
      }
    } catch (e) {
      _status = 'error';
      _result = {'error_detail': 'Missing system dependencies (PulseAudio/parecord)'};
      _isRecording = false;
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    final path = await _audioRecorder.stop();
    _isRecording = false;
    _status = 'processing';
    notifyListeners();

    if (path != null) {
      await _performAcoustidRecognition(path);
    }
  }

  Future<void> _performAcoustidRecognition(String audioPath) async {
    try {
      // Step 03: Generate Audio Fingerprint
      final fingerprintData = await _generateFingerprint(audioPath);
      if (fingerprintData == null) {
        _status = 'error';
        notifyListeners();
        return;
      }

      // Step 04: Query Public Database (AcoustID)
      final response = await http.post(
        Uri.parse(_acoustidUrl),
        body: {
          'format': 'json',
          'client': _acoustidApiKey,
          'duration': fingerprintData['duration'].toString(),
          'fingerprint': fingerprintData['fingerprint'],
          'meta': 'recordings artists releasegroups',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final bestMatch = data['results'][0]['recordings'][0];
          _result = {
            'title': bestMatch['title'],
            'artist': bestMatch['artists'][0]['name'],
          };
          _status = 'success';
        } else {
          _status = 'error'; // Song not found
        }
      } else {
        _status = 'error'; // API error
      }
    } catch (e) {
      _status = 'error';
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> _generateFingerprint(String path) async {
    // This requires 'fpcalc' to be installed on the system
    try {
      final result = await Process.run('fpcalc', ['-json', path]);
      if (result.exitCode == 0) {
        return jsonDecode(result.stdout);
      }
      return null;
    } catch (e) {
      // Fallback/Simulated fingerprint for testing if fpcalc is missing
      if (kDebugMode) {
        return {
          'duration': 5,
          'fingerprint': 'AQAAAA...',
        };
      }
      return null;
    }
  }

  Future<void> addToPlaylist(String playlistId) async {
    if (_result == null || _result!['track_id'] == null) return;

    try {
      await http.post(
        Uri.parse('$_baseUrl/playlist/$_lastResultUuid'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'playlist_id': playlistId,
          'track_id': _result!['track_id'],
        }),
      );
    } catch (e) {
      // Log error
    }
  }

  @override
  void dispose() {
    _recorder?.dispose();
    super.dispose();
  }
}
