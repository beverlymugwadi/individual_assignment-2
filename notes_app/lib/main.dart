import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Corrected import
import 'package:notes_app/features/authentication/authentication_injection.dart';
import 'package:notes_app/features/authentication/presentation/manager/auth_provider.dart';
import 'package:notes_app/features/authentication/presentation/manager/auth_state.dart';
import 'package:notes_app/features/authentication/presentation/screens/auth_screen.dart';
import 'package:notes_app/features/notes/notes_injection.dart';
import 'package:notes_app/features/notes/presentation/manager/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:notes_app/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // added your Firebase options here
  );
  runApp(
    // MultiProvider is now at the top level, wrapping MyApp
    MultiProvider(
      providers: [
        ...authProviders(),
        ...notesProviders(),
      ],
      child: const MyApp(), // MyApp is now a child of MultiProvider
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Define auth and notes providers 
  late AppAuthProvider _appAuthProvider;
  late NotesProvider _notesProvider;

  // This flag helps ensure the listener is only added once
  bool _listenerAdded = false;

  @override
  void initState() {
    super.initState();
    _appAuthProvider = context.read<AppAuthProvider>();
    _notesProvider = context.read<NotesProvider>();

    if (!_listenerAdded) {
      _appAuthProvider.addListener(_onAuthChange);
      _listenerAdded = true;

      // Initialize authProvider.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _appAuthProvider.initialize();
      });
    }
  }

  void _onAuthChange() {
    if (_appAuthProvider.state is AuthAuthenticated) {
      final userId = (_appAuthProvider.state as AuthAuthenticated).user.uid;
      _notesProvider.listenToNotes(userId); // Trigger notes loading
    } else if (_appAuthProvider.state is AuthUnauthenticated) {
      _notesProvider.clearNotes(); // Clear notes on logout
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed to prevent memory leaks
    _appAuthProvider.removeListener(_onAuthChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AppAuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.state is AuthInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (authProvider.state is AuthAuthenticated) {
            return const HomeScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}