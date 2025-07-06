// lib/features/authentication/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword(String email, String password);
  Future<Either<Failure, void>> signOut();
  UserEntity? getCurrentUser(); // New: Define this in the contract
  Stream<UserEntity?> get authStateChanges; // Changed to a getter
}