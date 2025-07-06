import 'package:flutter/material.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';
import 'package:notes_app/features/notes/domain/usecases/create_note_usecase.dart';
import 'package:notes_app/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:notes_app/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:notes_app/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:notes_app/features/notes/presentation/manager/notes_state.dart';
import 'dart:async';

class NotesProvider extends ChangeNotifier {
  final GetNotesUseCase getNotesUseCase;
  final CreateNoteUseCase createNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;

  NotesProvider({
    required this.getNotesUseCase,
    required this.createNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
  });

  NotesState _state = const NotesInitial();
  NotesState get state => _state;

  List<NoteEntity> _notes = [];
  List<NoteEntity> get notes => _notes;

  StreamSubscription? _notesSubscription;

  void listenToNotes(String userId) {
    // Cancel previous subscription if exists
    _notesSubscription?.cancel();
    _notesSubscription = getNotesUseCase(userId).listen(
      (notesList) {
        _notes = notesList;
        _state = NotesLoaded(notesList);
        notifyListeners();
      },
      onError: (error) {
        _state = NotesError(_mapFailureToMessage(error));
        notifyListeners();
      },
      onDone: () {
        // Handle stream completion if necessary
      },
    );
  }

  void clearNotes() {
    _notesSubscription?.cancel(); // Cancel any active note stream subscription
    _notes = []; // Clear the list of notes
    _state = const NotesInitial(); // Reset the state
    notifyListeners(); // Notify listeners that notes have been cleared
  }
  // <-------------------------------------->

  Future<void> createNote(NoteEntity note) async {
    _state = const NotesLoading();
    notifyListeners(); // Notify loading state

    final result = await createNoteUseCase(note);
    result.fold(
      (failure) => _state = NotesError(_mapFailureToMessage(failure)),
      (_) => _state = const NoteOperationSuccess('Note created successfully!'),
    );
    notifyListeners(); // Notify success or error state
  }

  Future<void> updateNote(NoteEntity note) async {
    _state = const NotesLoading();
    notifyListeners();

    final result = await updateNoteUseCase(note);
    result.fold(
      (failure) => _state = NotesError(_mapFailureToMessage(failure)),
      (_) => _state = const NoteOperationSuccess('Note updated successfully!'),
    );
    notifyListeners();
  }

  Future<void> deleteNote(String noteId, String userId) async {
    _state = const NotesLoading();
    notifyListeners();

    final result = await deleteNoteUseCase(DeleteNoteParams(noteId: noteId, userId: userId));
    result.fold(
      (failure) => _state = NotesError(_mapFailureToMessage(failure)),
      (_) => _state = const NoteOperationSuccess('Note deleted successfully!'),
    );
    notifyListeners();
  }

  String _mapFailureToMessage(dynamic error) {
    if (error is Failure) {
      if (error is ServerFailure) {
        return 'Server Error: ${error.message}';
      } else if (error is AuthFailure) {
        return 'Authentication Error: ${error.message}';
      } else {
        return 'An unexpected error occurred: ${error.message}';
      }
    } else {
      return 'An unexpected error occurred.';
    }
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }
}