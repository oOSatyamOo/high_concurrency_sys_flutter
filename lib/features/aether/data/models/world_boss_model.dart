import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/world_boss.dart';

// @AETHER: Data transfer object for WorldBoss.
// Parses Firestore Timestamps into Dart DateTimes for the domain entity.

/// {@template world_boss_model}
/// Data model for [WorldBoss] handling Firestore serialization.
/// {@endtemplate}
class WorldBossModel extends WorldBoss {
  const WorldBossModel({
    required super.id,
    required super.name,
    required super.endTime,
    required super.totalDuration,
  });

  /// Creates a model from a Firestore document snapshot.
  factory WorldBossModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data()!;
    
    // Parse the total duration from seconds (stored in DB) to Duration.
    final int durationSeconds = (data['total_duration_seconds'] as num).toInt();

    return WorldBossModel(
      id: snapshot.id,
      name: data['name'] as String,
      endTime: (data['end_time'] as Timestamp).toDate(),
      totalDuration: Duration(seconds: durationSeconds),
    );
  }
}
