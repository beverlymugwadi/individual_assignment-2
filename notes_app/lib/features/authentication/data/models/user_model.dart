// lib/features/authentication/data/models/user_model.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String uid,
    String? email,
  }) : super(uid: uid, email: email);

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
    };
  }

  // Optional: A copyWith method for immutability, if needed
  @override
  UserModel copyWith({
    String? uid,
    String? email,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
    );
  }
}