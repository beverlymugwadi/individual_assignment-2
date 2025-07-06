import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/features/notes/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  const NoteModel({
    String? id,
    required String userId,
    required String title,
    required String content,
    required DateTime timestamp,
  }) : super(
          id: id,
          userId: userId,
          title: title,
          content: content,
          timestamp: timestamp,
        );

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  // Factory constructor to create a NoteModel from a Firestore DocumentSnapshot
  factory NoteModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return NoteModel(
      id: snap.id, // Firestore document ID is the note ID
      userId: data['userId'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Override copyWith for NoteModel to return NoteModel
  @override
  NoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? timestamp,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}