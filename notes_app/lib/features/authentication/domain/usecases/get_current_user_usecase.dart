import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';
import 'package:notes_app/features/authentication/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase extends NoParamsUseCase<UserEntity?> { // Extend a use case for no parameters
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  UserEntity? call(NoParams params) {
    return repository.getCurrentUser();
  }
}

// You might need a base class for use cases that don't return Future<Either<Failure, T>>
// For simplicity, let's create a new type of UseCase in core/usecases/usecase.dart for this.

/*
// In lib/core/usecases/usecase.dart (add this)
abstract class NoParamsUseCase<Type> {
  Type call(NoParams params);
}
*/