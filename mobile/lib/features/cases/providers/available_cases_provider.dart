/// Available Cases Provider
/// For volunteers to view and accept cases

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/available_cases_service.dart';
import '../../../core/models/case.dart';

final availableCasesServiceProvider = Provider<AvailableCasesService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AvailableCasesService(apiClient);
});

final availableCasesProvider =
    StateNotifierProvider<AvailableCasesNotifier, AvailableCasesState>((ref) {
  final service = ref.watch(availableCasesServiceProvider);
  return AvailableCasesNotifier(service);
});

class AvailableCasesState {
  final List<MedicalCase> cases;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final bool hasMore;

  AvailableCasesState({
    this.cases = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.hasMore = false,
  });

  AvailableCasesState copyWith({
    List<MedicalCase>? cases,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    bool? hasMore,
  }) {
    return AvailableCasesState(
      cases: cases ?? this.cases,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class AvailableCasesNotifier extends StateNotifier<AvailableCasesState> {
  final AvailableCasesService _service;

  AvailableCasesNotifier(this._service) : super(AvailableCasesState()) {
    loadAvailableCases();
  }

  Future<void> loadAvailableCases({bool refresh = false}) async {
    if (refresh) {
      state = AvailableCasesState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _service.getAvailableCases(
        page: refresh ? 1 : state.page,
      );

      state = state.copyWith(
        cases: refresh
            ? result['cases'] as List<MedicalCase>
            : [...state.cases, ...(result['cases'] as List<MedicalCase>)],
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
      final result = await _service.getAvailableCases(
        page: state.page + 1,
      );

      state = state.copyWith(
        cases: [...state.cases, ...(result['cases'] as List<MedicalCase>)],
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

  Future<bool> acceptCase({
    required String caseId,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
  }) async {
    try {
      await _service.acceptCase(
        caseId: caseId,
        scheduledStart: scheduledStart,
        scheduledEnd: scheduledEnd,
      );

      // Remove accepted case from list
      state = state.copyWith(
        cases: state.cases.where((c) => c.id != caseId).toList(),
        total: state.total - 1,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

