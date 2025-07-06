import 'package:dartz/dartz.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';
import 'package:notes_app/features/notes/domain/repositories/note_repository.dart';

class UpdateNoteUseCase extends UseCase<void, NoteEntity> {
  final NoteRepository repository;

  UpdateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoteEntity note) async {
    return await repository.updateNote(note);
  }
}