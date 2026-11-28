import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider monitoring active network connectivity status
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Evaluates if the device is currently offline (no active network connection)
final isOfflineProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(connectivityStreamProvider);
  return asyncValue.maybeWhen(
    data: (results) {
      if (results.isEmpty) return false;
      return results.every((result) => result == ConnectivityResult.none);
    },
    orElse: () => false,
  );
});
