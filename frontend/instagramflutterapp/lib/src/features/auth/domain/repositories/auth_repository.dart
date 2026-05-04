import 'package:instagramflutterapp/src/utils/utils.dart';
import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'dart:io';

abstract class AuthRepository {
  /// Stream of auth state changes. Emits AppUser when authenticated, null when not.
  Stream<AppUser?> get onAuthStateChanged;

  /// Sign in with email and password
  FutureEither<AppUser> login({
    required String email,
    required String password,
  });

  /// Sign up with email, password, and optional name
  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Send a password reset email
  FutureEither<void> forgotPassword({
    required String email,
  });

  /// Sign out the current user
  FutureEither<void> logout();

  /// Check if the user is currently authenticated natively
  FutureEither<AppUser?> checkAuthState();

  /// Update the current user's profile details.
  FutureEither<AppUser> updateProfile({
    required String name,
    File? photo,
  });
}
