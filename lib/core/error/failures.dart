import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class AppException extends Equatable {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ErrorMapper {
  static AppException mapDioException(DioException e) {
    // Handle timeout errors
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
      return const AppException('Network timeout');
    }
    
    // Handle response errors
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      
      switch (statusCode) {
        case 400:
          // Try to extract specific field validation errors if present
          {
            final extracted = _extractValidationMessage(data);
            if (extracted != null && extracted.isNotEmpty) {
              return AppException(extracted, code: 'bad_request');
            }
            if (data is Map<String, dynamic>) {
              if (data['message'] is String) {
                return AppException(data['message'] as String, code: 'bad_request');
              }
              if (data['error'] is String) {
                return AppException(data['error'] as String, code: 'bad_request');
              }
            }
            return const AppException('Bad request - please check your input', code: 'bad_request');
          }
        case 401:
          return const AppException('Session expired, please sign in again');
        case 403:
          return const AppException('You don\'t have permission to do this');
        case 404:
          return const AppException('Not found');
        case 422:
          {
            final extracted = _extractValidationMessage(data);
            if (extracted != null && extracted.isNotEmpty) {
              return AppException(extracted, code: 'validation_error');
            }
            if (data is Map<String, dynamic>) {
              if (data['message'] is String) {
                return AppException(data['message'] as String, code: 'validation_error');
              } else if (data['error'] is String) {
                return AppException(data['error'] as String, code: 'validation_error');
              }
            }
            return const AppException('Validation error', code: 'validation_error');
          }
        case 500:
          return const AppException('Server is temporarily unavailable');
        case 502:
          return const AppException('Bad gateway - server is down');
        case 503:
          return const AppException('Service is under maintenance');
        case 504:
          return const AppException('Gateway timeout - please try again');
        default:
          if (data is Map<String, dynamic> && data['message'] is String) {
            return AppException(data['message'] as String);
          }
          return const AppException('Unexpected error occurred');
      }
    }
    
    // Handle non-response errors
    return const AppException('Unexpected error occurred');
  }

  /// Attempts to extract a human-readable validation message from common API shapes.
  /// Supported formats:
  /// - { "errors": { "email": ["Invalid email"], "password": ["Too short"] } }
  /// - { "errors": { "email": "Invalid email" } }
  /// - { "error": { "details": { "field": ["msg"] } } }
  /// - [ { "field": "email", "message": "Invalid email" }, ... ]
  static String? _extractValidationMessage(dynamic data) {
    try {
      // errors map: field -> List/String
      if (data is Map<String, dynamic>) {
        // Direct "errors" key
        final errors = data['errors'];
        if (errors is Map<String, dynamic>) {
          final parts = <String>[];
          errors.forEach((field, value) {
            if (value is List) {
              final msg = value.join(', ');
              parts.add('${_humanizeField(field)}: $msg');
            } else if (value is String) {
              parts.add('${_humanizeField(field)}: $value');
            }
          });
          if (parts.isNotEmpty) return parts.join('\n');
        }

        // Nested error.details
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          final details = error['details'];
          if (details is Map<String, dynamic>) {
            final parts = <String>[];
            details.forEach((field, value) {
              if (value is List) {
                final msg = value.join(', ');
                parts.add('${_humanizeField(field)}: $msg');
              } else if (value is String) {
                parts.add('${_humanizeField(field)}: $value');
              }
            });
            if (parts.isNotEmpty) return parts.join('\n');
          }
        }
      }

      // List of error objects
      if (data is List) {
        final parts = <String>[];
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final field = item['field']?.toString();
            final message = item['message']?.toString() ?? item['msg']?.toString();
            if (message != null) {
              if (field != null && field.isNotEmpty) {
                parts.add('${_humanizeField(field)}: $message');
              } else {
                parts.add(message);
              }
            }
          }
        }
        if (parts.isNotEmpty) return parts.join('\n');
      }
    } catch (_) {
      // Fall through to null
    }
    return null;
  }

  static String _humanizeField(String field) {
    if (field.isEmpty) return field;
    final withSpaces = field.replaceAll('_', ' ');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }
}
