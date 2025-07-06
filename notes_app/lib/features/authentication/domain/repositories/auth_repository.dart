import 'package:dartz/dartz.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(String email, String password);
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword(String email, String password);
  Future<Either<Failure, void>> signOut();
  UserEntity? getCurrentUser(); 
  Stream<UserEntity?> get authStateChanges; 
}