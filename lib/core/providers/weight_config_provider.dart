import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipesantren/core/models/weight_config_model.dart';
import 'package:sipesantren/core/repositories/weight_config_repository.dart';

/// Provides a stream of the WeightConfigModel.
///
/// This provider listens to changes in the `grading_weights` document
/// in Firestore and automatically rebuilds its dependents with the latest
/// WeightConfigModel.
final weightConfigProvider = StreamProvider<WeightConfigModel>((ref) {
  final repository = ref.watch(weightConfigRepositoryProvider);
  return repository.getWeightConfig();
});

/// A provider that exposes a Future to initialize default weights if they don't exist.
/// This can be called once at app startup.
final initializeWeightConfigProvider = FutureProvider<void>((ref) async {
  final repository = ref.read(weightConfigRepositoryProvider);
  await repository.initializeWeightConfig();
});