import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:notes_app/core/errors/failures.dart';

// Abstract class for synchronous or Future-based use cases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Abstract class for Stream-based use cases
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call(Params params);
}

//Abstract class for use cases that take no parameters and return a direct type 
abstract class NoParamsUseCase<Type> {
  Type call(NoParams params);
}


class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}