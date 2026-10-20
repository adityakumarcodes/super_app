import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:milo/services/app_config.dart';

class StorageService {
  Future<Map<String, String>> fetchSignedUrls(List<String> paths) async {
    final result = <String, String>{};
    for (final path in paths) {
      try {
        final response = await FlutterBetterAuth.dioClient
            .get<Map<String, dynamic>>(
              '${AppConfig.storageUrl}url',
              queryParameters: {'path': path},
            )
            .timeout(AppConfig.requestTimeout);
        final data = response.data;
        if (data != null && data['url'] is String) {
          result[path] = data['url'] as String;
        }
      } catch (_) {
        // Skip failed URLs, fallback will handle
      }
    }
    return result;
  }

  Future<String?> fetchSignedUrl(String path) async {
    final urls = await fetchSignedUrls([path]);
    return urls[path];
  }
}
