import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:milo/services/app_config.dart';

class StorageService {
  Future<Map<String, String>> fetchSignedUrls(List<String> paths) async {
    final entries = await Future.wait(
      paths.map((path) async => MapEntry(path, await fetchSignedUrl(path))),
    );
    return {
      for (final entry in entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }

  Future<String?> fetchSignedUrl(String path) async {
    try {
      final response = await FlutterBetterAuth.dioClient
          .get<Map<String, dynamic>>(
            '${AppConfig.storageUrl}url',
            queryParameters: {'path': path},
          )
          .timeout(AppConfig.requestTimeout);
      final url = response.data?['url'];
      return url is String ? url : null;
    } catch (_) {
      // Callers fall back to a placeholder when a URL cannot be resolved.
      return null;
    }
  }
}
