import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../models/world_boss_model.dart';

// @AETHER: Data Source for World Boss event metadata.
// Called once on initialization. Does NOT stream — timer is computed locally.

/// {@template pulse_data_source}
/// Remote data source for World Boss pulse.
/// {@endtemplate}
abstract class PulseDataSource {
  /// Fetches the currently active World Boss event.
  Future<WorldBossModel?> getActiveWorldBoss();
}

/// Implementation of [PulseDataSource] using Firestore.
class PulseDataSourceImpl implements PulseDataSource {
  const PulseDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<WorldBossModel?> getActiveWorldBoss() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection(AetherConstants.worldBossCollection)
          .doc(AetherConstants.activeWorldBossDocument)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return WorldBossModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreFailure(
          message: e.message ?? 'Failed to fetch World Boss');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
