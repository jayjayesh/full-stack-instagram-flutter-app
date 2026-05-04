import 'package:instagramflutterapp/src/imports/core_imports.dart';
import 'package:instagramflutterapp/src/imports/packages_imports.dart';
import 'dart:io';

import 'package:instagramflutterapp/src/features/auth/domain/entities/user.dart';
import 'package:instagramflutterapp/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:instagramflutterapp/src/features/auth/data/repositories/auth_repository_impl.dart';

// Provides the single instance of AuthRepositoryImpl
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(
    repository: ref.read(authRepositoryProvider),
  );
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _repository;

  AuthController({
    required AuthRepository repository,
  })  : _repository = repository,
        super(false); // loading state is false

  FutureEither<AppUser> login({
    required String email,
    required String password,
  }) async {
    state = true;

    final result = await _repository.login(email: email, password: password);

    state = false;
    return result;
  }

  FutureEither<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    state = true;

    final result =
        await _repository.signUp(name: name, email: email, password: password);

    state = false;
    return result;
  }

  FutureEither<void> forgotPassword({required String email}) async {
    state = true;

    final result = await _repository.forgotPassword(email: email);

    state = false;
    return result;
  }

  FutureEither<AppUser> updateProfile({
    required String name,
    File? photo,
  }) async {
    state = true;

    final result = await _repository.updateProfile(name: name, photo: photo);

    state = false;
    return result;
  }
}
