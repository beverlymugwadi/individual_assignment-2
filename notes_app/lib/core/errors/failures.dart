// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({this.message = 'An unexpected error occurred.'});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server failure.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache failure.'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failure.'});
}

// NEW: Specific Authentication Failures
class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({super.message = 'The password provided is too weak.'});
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure({super.message = 'The account already exists for that email.'});
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({super.message = 'No user found for that email.'});
}

class WrongPasswordFailure extends AuthFailure {
  const WrongPasswordFailure({super.message = 'Wrong password provided for that user.'});
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure({super.message = 'The email address is not valid.'});
}

class OperationNotAllowedFailure extends AuthFailure {
  const OperationNotAllowedFailure({super.message = 'Operation not allowed. Enable email/password sign-in in Firebase console.'});
}

class GenericFailure extends Failure {
  const GenericFailure({super.message = 'An unexpected error occurred.'});
}