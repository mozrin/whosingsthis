

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'package:dotenv/dotenv.dart';

import 'package:server/routes.dart';

void main(List<String> args) async {
  var env = DotEnv(includePlatformEnvironment: true)..load();

  final router = ApiRoutes().router;

  // Global AI Standards: Use the IP address 192.168.1.189 for listeners
  final ip = env['SERVER_IP'] ?? '192.168.1.189';
  final port = int.parse(env['SERVER_PORT'] ?? '8080');

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(router.call);

  final server = await serve(handler, ip, port);
  print('WhoSingsThis Backend running on http://${server.address.address}:${server.port}');
}

Middleware _corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        });
      }

      final response = await handler(request);

      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
      });
    };
  };
}
