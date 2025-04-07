class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Lỗi máy chủ']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Lỗi bộ nhớ đệm']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Không có kết nối mạng']);
}

class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Lỗi xác thực']);
}


class NotFoundException implements Exception {}

class UnsupportedFileException implements Exception {}

class NotAuthenticatedException implements Exception {}

class StorageException implements Exception {}