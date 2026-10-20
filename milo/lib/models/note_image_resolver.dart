bool isStoragePath(String? value) {
  if (value == null || value.isEmpty) return false;
  final lower = value.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('data:') ||
      lower.startsWith('blob:') ||
      lower.startsWith('/')) {
    return false;
  }
  return value.contains('/');
}

String? extractStoragePath(Map<String, dynamic>? fileData) {
  if (fileData == null) return null;
  final path = fileData['path']?.toString();
  if (isStoragePath(path)) return path;
  final url = fileData['url']?.toString();
  if (isStoragePath(url)) return url;
  return null;
}
