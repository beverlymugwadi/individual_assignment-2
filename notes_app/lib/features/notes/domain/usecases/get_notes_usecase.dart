import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';
import 'package:notes_app/features/notes/domain/repositories/note_repository.dart';

class GetNotesUseCase extends StreamUseCase<List<NoteEntity>, String> {
  final NoteRepository repository;

  GetNotesUseCase(this.repository);

  @override
  Stream<List<NoteEntity>> call(String userId) {
    return repository.getNotes(userId);
  }
}