// lib/features/notes/data/repositories/note_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:notes_app/core/errors/exceptions.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:notes_app/features/notes/data/models/note_model.dart';
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';
import 'package:notes_app/features/notes/domain/repositories/note_repository.dart';
import 'package:flutter/foundation.dart'; // NEW: Import debugPrint

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel(
        userId: note.userId,
        title: note.title,
        content: note.content,
        timestamp: note.timestamp,
      );
      await remoteDataSource.createNote(noteModel);
      return const Right(null);
    } on NotAuthenticatedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<NoteEntity>> getNotes(String userId) {
    try {
      return remoteDataSource.getNotes(userId);
    } on ServerException catch (e) {
      debugPrint('Error fetching notes stream (initial setup): ${e.message}');
      return Stream.value([]);
    } catch (e) {
      debugPrint('Generic error fetching notes stream (initial setup): $e');
      return Stream.value([]);
    }
  }

  @override
  Future<Either<Failure, void>> updateNote(NoteEntity note) async {
    try {
      final noteModel = NoteModel(
        id: note.id,
        userId: note.userId,
        title: note.title,
        content: note.content,
        timestamp: note.timestamp,
      );
      await remoteDataSource.updateNote(noteModel);
      return const Right(null);
    } on NotAuthenticatedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId, String userId) async {
    try {
      await remoteDataSource.deleteNote(noteId, userId);
      return const Right(null);
    } on NotAuthenticatedException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}