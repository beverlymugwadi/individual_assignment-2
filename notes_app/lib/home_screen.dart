// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:notes_app/features/authentication/presentation/manager/auth_provider.dart' hide AuthProvider;
import 'package:notes_app/features/authentication/presentation/screens/auth_screen.dart'; // For showSnackBar
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';
import 'package:notes_app/features/notes/presentation/manager/notes_provider.dart';
import 'package:notes_app/features/notes/presentation/manager/notes_state.dart';
import 'package:notes_app/features/notes/presentation/screens/add_edit_note_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appAuthProvider = Provider.of<AppAuthProvider>(context);
    // notesProvider is accessed via Consumer below, so no need for direct Provider.of here if not used outside Consumer.
    final userEmail = appAuthProvider.currentUser?.email ?? 'Guest';
    final currentUserId = appAuthProvider.currentUser?.uid; // Get userId directly from AuthProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              appAuthProvider.signOut();
            },
          ),
        ],
      ),
      body: currentUserId == null
          ? const Center(child: Text('Please log in to view your notes.'))
          : Consumer<NotesProvider>( // Consumer to react to NotesProvider changes
              builder: (context, notesProvider, child) {
                // Listen for operation success/error from NotesProvider
                // This will execute after the frame is built, preventing setState during build errors.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (notesProvider.state is NoteOperationSuccess) {
                    // Assuming showSnackBar is a utility function in auth_screen.dart or common_widgets
                    showSnackBar(
                        context, (notesProvider.state as NoteOperationSuccess).message);
                  } else if (notesProvider.state is NotesError) {
                    showSnackBar(
                        context, (notesProvider.state as NotesError).message,
                        isError: true);
                  }
                });

                if (notesProvider.state is NotesLoading && notesProvider.notes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (notesProvider.notes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome, $userEmail!',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'You don\'t have any notes yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap the "+" button to create your first note!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: notesProvider.notes.length,
                    itemBuilder: (context, index) {
                      final note = notesProvider.notes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            note.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                note.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                // Format timestamp for display
                                'Last updated: ${DateFormat('MMM d, yyyy h:mm a').format(note.timestamp)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to AddEditNoteScreen for editing existing note
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => AddEditNoteScreen(note: note),
                              ),
                            );
                          },
                          // --- MODIFIED TRAILING WIDGET TO INCLUDE EDIT AND DELETE ICONS ---
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, // Important for Row inside ListTile trailing
                            children: [
                              // Edit Icon Button
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      // Pass the existing note to the AddEditNoteScreen for editing
                                      builder: (ctx) => AddEditNoteScreen(note: note),
                                    ),
                                  );
                                },
                              ),
                              // Delete Icon Button
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _confirmDelete(context, notesProvider, note, currentUserId);
                                },
                              ),
                            ],
                          ),
                          // ---------------------------------------------------------------
                        ),
                      );
                    },
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddEditNoteScreen to add a new note
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => const AddEditNoteScreen(), // No note passed for new creation
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, NotesProvider notesProvider, NoteEntity note, String? currentUserId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (note.id != null && currentUserId != null) {
                notesProvider.deleteNote(note.id!, currentUserId);
                Navigator.of(ctx).pop(); // Close dialog
              } else {
                // Ensure showSnackBar exists, typically a global helper or in auth_screen.dart as you imported
                showSnackBar(context, 'Error: Note ID or user ID missing for delete.', isError: true);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}