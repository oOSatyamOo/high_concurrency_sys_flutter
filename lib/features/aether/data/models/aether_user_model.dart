import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/aether_user.dart';

// @AETHER: Model mapping Firebase User to our pure domain AetherUser entity.

class AetherUserModel extends AetherUser {
  const AetherUserModel({
    required super.id,
    super.email,
    super.displayName,
    required super.isAnonymous,
  });

  factory AetherUserModel.fromFirebaseUser(User user) {
    return AetherUserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
    );
  }
}
