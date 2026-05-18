import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../models/aether_user_model.dart';

// @AETHER: Data Source for Auth operations via Firebase Auth.

abstract class AuthRemoteDataSource {
  Stream<AetherUserModel?> watchAuthState();
  Future<AetherUserModel> signInAnonymously();
  Future<AetherUserModel> signInWithGoogle();
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  Stream<AetherUserModel?> watchAuthState() {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return AetherUserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<AetherUserModel> signInAnonymously() async {
    try {
      final UserCredential credential = await _firebaseAuth.signInAnonymously();
      if (credential.user == null) {
        throw const UnexpectedFailure(message: 'Sign in succeeded but user is null.');
      }
      return AetherUserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw UnexpectedFailure(message: e.message ?? 'Auth Error');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Future<AetherUserModel> signInWithGoogle() async {
    // @AETHER: Google Sign-In logic saved for future phase as requested.
    throw UnimplementedError('Google Sign-In is planned for a future phase.');
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
