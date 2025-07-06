import 'package:flutter/material.dart';
import 'package:notes_app/core/errors/failures.dart';
import 'package:notes_app/core/usecases/usecase.dart';
import 'package:notes_app/features/authentication/domain/entities/user_entity.dart';
import 'package:notes_app/features/authentication/domain/usecases/get_auth_state_changes_usecase.dart';
import 'package:notes_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:notes_app/features/authentication/domain/usecases/sign_in_usecase.dart';
import 'package:notes_app/features/authentication/domain/usecases/sign_out_usecase.dart';
import 'package:notes_app/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:notes_app/features/authentication/presentation/manager/auth_state.dart';
import 'dart:async';

class AppAuthProvider extends ChangeNotifier {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;
  final GetAuthStateChangesUseCase getAuthStateChangesUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AppAuthProvider({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getAuthStateChangesUseCase,
    required this.getCurrentUserUseCase,
  });

  AuthState _state = const AuthInitial();
  AuthState get state => _state;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  StreamSubscription? _authStateSubscription;

  void initialize() {
    _authStateSubscription?.cancel();
    _authStateSubscription = getAuthStateChangesUseCase(const NoParams()).listen(
      (user) {
        _currentUser = user;
        if (user != null) {
          _state = AuthAuthenticated(user);
        } else {
          _state = const AuthUnauthenticated();
        }
        notifyListeners();
      },
      onError: (error) {
        // Handle errors coming from the auth state stream itself
        if (error is Failure) {
          _state = AuthError(error.message);
        } else {
          _state = AuthError('An unexpected stream error occurred: ${error.toString()}');
        }
        notifyListeners();
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    _state = const AuthLoading();
    notifyListeners();
    // Assuming SignInUseCase and SignUpUseCase params are defined correctly
    final result = await signInUseCase(SignInParams(email: email, password: password));
    result.fold(
      (failure) => _state = AuthError(_mapFailureToMessage(failure)),
      (user) {
        _currentUser = user;
        _state = AuthAuthenticated(user);
      },
    );
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _state = const AuthLoading();
    notifyListeners();
    final result = await signUpUseCase(SignUpParams(email: email, password: password));
    result.fold(
      (failure) => _state = AuthError(_mapFailureToMessage(failure)),
      (user) {
        _currentUser = user;
        _state = AuthAuthenticated(user);
      },
    );
    notifyListeners();
  }

  Future<void> signOut() async {
    _state = const AuthLoading();
    notifyListeners();
    final result = await signOutUseCase(const NoParams());
    result.fold(
      (failure) => _state = AuthError(_mapFailureToMessage(failure)),
      (_) {
        _currentUser = null;
        _state = const AuthUnauthenticated();
      },
    );
    notifyListeners();
  }
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server Error: ${failure.message}';
    } else if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is GenericFailure) {
      return failure.message;
    }
    // Fallback for any unhandled Failure type
    return 'An unknown error occurred: ${failure.message}';
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}