/// Consultation Provider
/// Riverpod providers for consultation management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/consultation_service.dart';

final consultationServiceProvider = Provider<ConsultationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ConsultationService(apiClient);
});

final consultationsListProvider =
    StateNotifierProvider<ConsultationsNotifier, ConsultationsState>((ref) {
  final service = ref.watch(consultationServiceProvider);
  return ConsultationsNotifier(service);
});

class ConsultationsState {
  final List<Map<String, dynamic>> consultations;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final bool hasMore;

  ConsultationsState({
    this.consultations = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.hasMore = false,
  });

  ConsultationsState copyWith({
    List<Map<String, dynamic>>? consultations,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    bool? hasMore,
  }) {
    return ConsultationsState(
      consultations: consultations ?? this.consultations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ConsultationsNotifier extends StateNotifier<ConsultationsState> {
  final ConsultationService _service;
  String? _statusFilter;

  ConsultationsNotifier(this._service) : super(ConsultationsState()) {
    loadConsultations();
  }

  Future<void> loadConsultations({bool refresh = false}) async {
    if (refresh) {
      state = ConsultationsState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _service.getConsultations(
        page: refresh ? 1 : state.page,
        status: _statusFilter,
      );

      final consultations = result['consultations'] as List<Map<String, dynamic>>;

      state = state.copyWith(
        consultations: refresh
            ? consultations
            : [...state.consultations, ...consultations],
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
      final result = await _service.getConsultations(
        page: state.page + 1,
        status: _statusFilter,
      );

      final consultations = result['consultations'] as List<Map<String, dynamic>>;

      state = state.copyWith(
        consultations: [...state.consultations, ...consultations],
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

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadConsultations(refresh: true);
  }

  Future<bool> startConsultation(String consultationId) async {
    try {
      await _service.startConsultation(consultationId);
      await loadConsultations(refresh: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> endConsultation(
    String consultationId, {
    String? diagnosis,
    String? treatmentPlan,
    String? volunteerNotes,
    bool? followUpRequired,
  }) async {
    try {
      await _service.endConsultation(
        consultationId,
        diagnosis: diagnosis,
        treatmentPlan: treatmentPlan,
        volunteerNotes: volunteerNotes,
        followUpRequired: followUpRequired,
      );
      await loadConsultations(refresh: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

