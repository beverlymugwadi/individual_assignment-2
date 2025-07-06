// lib/core/errors/exceptions.dart

class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error occurred.'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error occurred.'});
}

class NotAuthenticatedException implements Exception {
  final String message;
  const NotAuthenticatedException({this.message = 'User is not authenticated.'});
}

// NEW: Authentication-specific exception
class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Authentication error occurred.'});
}