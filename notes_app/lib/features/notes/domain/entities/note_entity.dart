import 'package:equatable/equatable.dart';

class NoteEntity extends Equatable {
  final String? id; // Nullable for new notes
  final String userId; // To associate note with a user
  final String title;
  final String content;
  final DateTime timestamp;

  const NoteEntity({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, title, content, timestamp];

  // a copyWith method for immutability
  NoteEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? timestamp,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}