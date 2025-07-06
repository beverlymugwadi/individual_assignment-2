// lib/features/notes/domain/usecases/create_note_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';
import 'package:notes_app/features/notes/domain/repositories/note_repository.dart';

class CreateNoteUseCase extends UseCase<void, NoteEntity> {
  final NoteRepository repository;

  CreateNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoteEntity note) async {
    return await repository.createNote(note);
  }
}