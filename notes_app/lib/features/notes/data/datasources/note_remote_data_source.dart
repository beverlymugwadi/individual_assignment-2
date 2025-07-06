// lib/features/notes/data/datasources/note_remote_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/core/errors/exceptions.dart'; // Import the new exception
import 'package:notes_app/features/notes/data/models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<void> createNote(NoteModel note);
  Stream<List<NoteModel>> getNotes(String userId);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String noteId, String userId);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  NoteRemoteDataSourceImpl({required this.firestore, required this.firebaseAuth});

  // Helper to get current user ID or throw exception
  String get currentUserId {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw const NotAuthenticatedException(); // Now it's a defined class!
    }
    return user.uid;
  }

  @override
  Future<void> createNote(NoteModel note) async {
    try {
      final userId = currentUserId;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .add(note.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firebase error creating note');
    } on NotAuthenticatedException { // Catch the custom exception
      rethrow; // Re-throw to be caught by the repository
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<List<NoteModel>> getNotes(String userId) {
    try {
      // Listen to notes for the specific user, ordered by timestamp
      return firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .orderBy('timestamp', descending: true) // Order by latest first
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => NoteModel.fromSnapshot(doc))
            .toList();
      });
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firebase error getting notes');
    } catch (e) {
      // Errors in streams are typically handled by the stream's onError callback.
      // This catch block would primarily handle synchronous errors during stream setup.
      // For persistent stream errors, the StreamBuilder or .listen.onError handles it.
      // We can throw ServerException or simply let the stream's error channel handle it.
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    try {
      if (note.id == null) {
        throw const ServerException(message: 'Note ID cannot be null for update.');
      }
      final userId = currentUserId;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(note.id)
          .update(note.toJson());
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firebase error updating note');
    } on NotAuthenticatedException { // Catch the custom exception
      rethrow; // Re-throw to be caught by the repository
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteNote(String noteId, String userId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('notes')
          .doc(noteId)
          .delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Firebase error deleting note');
    } on NotAuthenticatedException { // Catch the custom exception
      rethrow; // Re-throw to be caught by the repository
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}