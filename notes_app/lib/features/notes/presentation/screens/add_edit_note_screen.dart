// lib/features/notes/presentation/screens/add_edit_note_screen.dart

import 'package:flutter/material.dart';
import 'package:notes_app/features/authentication/presentation/manager/auth_provider.dart' hide AuthProvider;
import 'package:notes_app/features/authentication/presentation/screens/auth_screen.dart'; // For showSnackBar
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';
import 'package:notes_app/features/notes/presentation/manager/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/manager/notes_state.dart';
import 'package:provider/provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteEntity? note; // Null for new note, present for editing existing note

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    final appAuthProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final userId = appAuthProvider.currentUser?.uid;

    if (userId == null) {
      showSnackBar(context, 'User not authenticated. Cannot save note.', isError: true);
      return;
    }

    final newTitle = _titleController.text.trim();
    final newContent = _contentController.text.trim();

    if (widget.note == null) {
      // Create new note
      final newNote = NoteEntity(
        userId: userId,
        title: newTitle,
        content: newContent,
        timestamp: DateTime.now(),
      );
      notesProvider.createNote(newNote).then((_) {
        // After operation, check state for success/error
        if (notesProvider.state is NoteOperationSuccess) {
          Navigator.of(context).pop(); // Go back to home screen on success
        }
      });
    } else {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        title: newTitle,
        content: newContent,
        timestamp: DateTime.now(), // Update timestamp on edit
      );
      notesProvider.updateNote(updatedNote).then((_) {
         // After operation, check state for success/error
        if (notesProvider.state is NoteOperationSuccess) {
          Navigator.of(context).pop(); // Go back to home screen on success
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add New Note' : 'Edit Note'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          // Listen for state changes (loading, error, success)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (notesProvider.state is NotesError) {
              showSnackBar(context, (notesProvider.state as NotesError).message, isError: true);
            }
          });

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter note title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: null, // Allows multiline input
                          expands: true, // Makes the field take available vertical space
                          keyboardType: TextInputType.multiline,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            labelText: 'Content',
                            hintText: 'Write your note here...',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter some content';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: notesProvider.state is NotesLoading ? null : _saveNote,
                          child: notesProvider.state is NotesLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(widget.note == null ? 'Save Note' : 'Update Note'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (notesProvider.state is NotesLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}