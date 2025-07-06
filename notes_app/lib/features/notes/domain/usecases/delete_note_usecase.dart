// lib/features/notes/domain/usecases/delete_note_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/notes/domain/repositories/note_repository.dart';

class DeleteNoteUseCase extends UseCase<void, DeleteNoteParams> {
  final NoteRepository repository;

  DeleteNoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) async {
    return await repository.deleteNote(params.noteId, params.userId);
  }
}

class DeleteNoteParams extends Equatable {
  final String noteId;
  final String userId;

  const DeleteNoteParams({required this.noteId, required this.userId});

  @override
  List<Object> get props => [noteId, userId];
}