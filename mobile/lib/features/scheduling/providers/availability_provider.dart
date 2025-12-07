/// Availability Provider
/// Riverpod providers for availability management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/availability_service.dart';

final availabilityServiceProvider = Provider<AvailabilityService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AvailabilityService(apiClient);
});

final availabilityBlocksProvider =
    StateNotifierProvider<AvailabilityNotifier, AvailabilityState>((ref) {
  final availabilityService = ref.watch(availabilityServiceProvider);
  return AvailabilityNotifier(availabilityService);
});

class AvailabilityState {
  final List<Map<String, dynamic>> blocks;
  final bool isLoading;
  final String? error;

  AvailabilityState({
    this.blocks = const [],
    this.isLoading = false,
    this.error,
  });

  AvailabilityState copyWith({
    List<Map<String, dynamic>>? blocks,
    bool? isLoading,
    String? error,
  }) {
    return AvailabilityState(
      blocks: blocks ?? this.blocks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AvailabilityNotifier extends StateNotifier<AvailabilityState> {
  final AvailabilityService _availabilityService;

  AvailabilityNotifier(this._availabilityService) : super(AvailabilityState()) {
    loadAvailabilityBlocks();
  }

  Future<void> loadAvailabilityBlocks() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final blocks = await _availabilityService.getAvailabilityBlocks();
      state = state.copyWith(
        blocks: blocks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createAvailabilityBlock({
    required DateTime startTime,
    required DateTime endTime,
    required String timezone,
    int slotDurationMinutes = 10,
    bool isRecurring = false,
    Map<String, dynamic>? recurrencePattern,
  }) async {
    try {
      await _availabilityService.createAvailabilityBlock(
        startTime: startTime,
        endTime: endTime,
        timezone: timezone,
        slotDurationMinutes: slotDurationMinutes,
        isRecurring: isRecurring,
        recurrencePattern: recurrencePattern,
      );

      // Reload blocks after creating
      await loadAvailabilityBlocks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAvailabilityBlock(String blockId) async {
    try {
      await _availabilityService.deleteAvailabilityBlock(blockId);
      // Reload blocks after deleting
      await loadAvailabilityBlocks();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

