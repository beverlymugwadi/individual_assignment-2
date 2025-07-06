// lib/features/authentication/domain/usecases/sign_up_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';
import 'package:notes_app/features/authentication/domain/repositories/auth_repository.dart';

class SignUpUseCase extends UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(params.email, params.password);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;

  const SignUpParams({required this.email, required void password}) : password = password as String;

  @override
  List<Object?> get props => [email, password];
}