// lib/features/authentication/domain/usecases/get_auth_state_changes_usecase.dart

import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';
import 'package:notes_app/features/authentication/domain/repositories/auth_repository.dart';

class GetAuthStateChangesUseCase extends StreamUseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetAuthStateChangesUseCase(this.repository);

  @override
  Stream<UserEntity?> call(NoParams params) {
    return repository.authStateChanges;
  }
}