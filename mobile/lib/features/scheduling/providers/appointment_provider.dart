/// Appointment Provider
/// Riverpod providers for appointment booking

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/appointment_service.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppointmentService(apiClient);
});

final availableSlotsProvider =
    StateNotifierProvider<AvailableSlotsNotifier, AvailableSlotsState>((ref) {
  final service = ref.watch(appointmentServiceProvider);
  return AvailableSlotsNotifier(service);
});

class AvailableSlotsState {
  final List<Map<String, dynamic>> slots;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final bool hasMore;

  AvailableSlotsState({
    this.slots = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.hasMore = false,
  });

  AvailableSlotsState copyWith({
    List<Map<String, dynamic>>? slots,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    bool? hasMore,
  }) {
    return AvailableSlotsState(
      slots: slots ?? this.slots,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class AvailableSlotsNotifier extends StateNotifier<AvailableSlotsState> {
  final AppointmentService _service;

  AvailableSlotsNotifier(this._service) : super(AvailableSlotsState()) {
    loadSlots();
  }

  Future<void> loadSlots({bool refresh = false}) async {
    if (refresh) {
      state = AvailableSlotsState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _service.getAvailableSlots(
        page: refresh ? 1 : state.page,
      );

      final slots = result['slots'] as List<Map<String, dynamic>>;

      state = state.copyWith(
        slots: refresh ? slots : [...state.slots, ...slots],
        isLoading: false,
        total: result['total'] as int,
        page: result['page'] as int,
        hasMore: (result['page'] as int) * (result['page_size'] as int) <
            (result['total'] as int),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await _service.getAvailableSlots(
        page: state.page + 1,
      );

      final slots = result['slots'] as List<Map<String, dynamic>>;

      state = state.copyWith(
        slots: [...state.slots, ...slots],
        isLoading: false,
        page: result['page'] as int,
        hasMore: (result['page'] as int) * (result['page_size'] as int) <
            (result['total'] as int),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> bookAppointment({
    required String slotId,
    required String caseId,
  }) async {
    try {
      await _service.bookAppointment(
        slotId: slotId,
        caseId: caseId,
      );
      await loadSlots(refresh: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

