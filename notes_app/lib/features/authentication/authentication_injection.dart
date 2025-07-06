// lib/features/authentication/authentication_injection.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:notes_app/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:notes_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:notes_app/features/authentication/domain/usecases/get_auth_state_changes_usecase.dart'; // Import
import 'package:notes_app/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:notes_app/features/authentication/domain/usecases/sign_in_usecase.dart'; // Import
import 'package:notes_app/features/authentication/domain/usecases/sign_out_usecase.dart'; // Import
import 'package:notes_app/features/authentication/domain/usecases/sign_up_usecase.dart'; // Import
import 'package:notes_app/features/authentication/presentation/manager/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> authProviders() {
  // Data Sources
  final AuthRemoteDataSource authRemoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth: FirebaseAuth.instance,
  );

  // Repositories
  final AuthRepository authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    firebaseAuth: FirebaseAuth.instance,
  );

  // Use Cases
  final GetAuthStateChangesUseCase getAuthStateChangesUseCase = GetAuthStateChangesUseCase(authRepository);
  final GetCurrentUserUseCase getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final SignInUseCase signInUseCase = SignInUseCase(authRepository);
  final SignUpUseCase signUpUseCase = SignUpUseCase(authRepository);
  final SignOutUseCase signOutUseCase = SignOutUseCase(authRepository);

  return [
    ChangeNotifierProvider(
      create: (_) => AppAuthProvider(
        signInUseCase: signInUseCase,
        signUpUseCase: signUpUseCase,
        signOutUseCase: signOutUseCase,
        getAuthStateChangesUseCase: getAuthStateChangesUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      ),
    ),
  ];
}