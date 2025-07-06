import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:notes_app/core/errors/exceptions.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:notes_app/features/authentication/data/models/user_model.dart'; 
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';
import 'package:notes_app/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth; // to get current user directly

  AuthRepositoryImpl({required this.remoteDataSource, required this.firebaseAuth}); // Update constructor

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(email, password);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(_mapFirebaseCodeToFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailAndPassword(email, password);
      return Right(userModel);
    } on AuthException catch (e) {
      return Left(_mapFirebaseCodeToFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges { // a getter, matching AuthRepository
    return remoteDataSource.authStateChanges;
  }

  @override
  UserEntity? getCurrentUser() { // Implementation for getCurrentUser
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  Failure _mapFirebaseCodeToFailure(String code) {
    switch (code) {
      case 'weak-password':
        return const WeakPasswordFailure();
      case 'email-already-in-use':
        return const EmailAlreadyInUseFailure();
      case 'user-not-found':
        return const UserNotFoundFailure();
      case 'wrong-password':
        return const WrongPasswordFailure();
      case 'invalid-email':
        return const InvalidEmailFailure();
      case 'operation-not-allowed':
        return const OperationNotAllowedFailure();
      default:
        return AuthFailure(message: code);
    }
  }
}