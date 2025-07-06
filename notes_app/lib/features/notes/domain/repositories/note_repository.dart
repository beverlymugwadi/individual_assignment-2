import 'package:dartz/dartz.dart'; 
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';

abstract class NoteRepository {
  Future<Either<Failure, void>> createNote(NoteEntity note);
  Stream<List<NoteEntity>> getNotes(String userId); // Stream for real-time updates
  Future<Either<Failure, void>> updateNote(NoteEntity note);
  Future<Either<Failure, void>> deleteNote(String noteId, String userId);
}