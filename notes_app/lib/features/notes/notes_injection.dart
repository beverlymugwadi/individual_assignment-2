import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:notes_app/features/notes/data/repositories/note_repository_impl.dart';
import 'package:notes_app/features/notes/domain/repositories/note_repository.dart';
import 'package:notes_app/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:notes_app/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:notes_app/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:notes_app/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:notes_app/features/notes/presentation/manager/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> notesProviders() {
  // Data Source
  final NoteRemoteDataSource noteRemoteDataSource = NoteRemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    firebaseAuth: FirebaseAuth.instance,
  );

  // Repository
  final NoteRepository noteRepository = NoteRepositoryImpl(
    remoteDataSource: noteRemoteDataSource,
  );

  // Use Cases
  final GetNotesUseCase getNotesUseCase = GetNotesUseCase(noteRepository);
  final CreateNoteUseCase createNoteUseCase = CreateNoteUseCase(noteRepository);
  final UpdateNoteUseCase updateNoteUseCase = UpdateNoteUseCase(noteRepository);
  final DeleteNoteUseCase deleteNoteUseCase = DeleteNoteUseCase(noteRepository);

  return [
    ChangeNotifierProvider(
      create: (_) => NotesProvider(
        getNotesUseCase: getNotesUseCase,
        createNoteUseCase: createNoteUseCase,
        updateNoteUseCase: updateNoteUseCase,
        deleteNoteUseCase: deleteNoteUseCase,
      ),
    ),
  ];
}