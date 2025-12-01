/// Case Provider
/// Riverpod providers for case management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/case_service.dart';
import '../../../core/models/case.dart';

final caseServiceProvider = Provider<CaseService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CaseService(apiClient);
});

final casesListProvider = StateNotifierProvider<CasesNotifier, CasesState>((ref) {
  final caseService = ref.watch(caseServiceProvider);
  return CasesNotifier(caseService);
});

class CasesState {
  final List<MedicalCase> cases;
  final bool isLoading;
  final String? error;
  final int total;
  final int page;
  final bool hasMore;

  CasesState({
    this.cases = const [],
    this.isLoading = false,
    this.error,
    this.total = 0,
    this.page = 1,
    this.hasMore = false,
  });

  CasesState copyWith({
    List<MedicalCase>? cases,
    bool? isLoading,
    String? error,
    int? total,
    int? page,
    bool? hasMore,
  }) {
    return CasesState(
      cases: cases ?? this.cases,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CasesNotifier extends StateNotifier<CasesState> {
  final CaseService _caseService;
  String? _statusFilter;

  CasesNotifier(this._caseService) : super(CasesState()) {
    loadCases();
  }

  Future<void> loadCases({bool refresh = false}) async {
    if (refresh) {
      state = CasesState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await _caseService.getCases(
        page: refresh ? 1 : state.page,
        status: _statusFilter,
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
      final result = await _caseService.getCases(
        page: state.page + 1,
        status: _statusFilter,
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

  void setStatusFilter(String? status) {
    _statusFilter = status;
    loadCases(refresh: true);
  }

  Future<void> createCase({
    required String title,
    required String chiefComplaint,
    required String urgency,
    String? description,
    String? patientHistory,
    String? currentMedications,
    String? allergies,
    String? vitalSigns,
  }) async {
    try {
      final newCase = await _caseService.createCase(
        title: title,
        chiefComplaint: chiefComplaint,
        urgency: urgency,
        description: description,
        patientHistory: patientHistory,
        currentMedications: currentMedications,
        allergies: allergies,
        vitalSigns: vitalSigns,
      );

      state = state.copyWith(
        cases: [newCase, ...state.cases],
        total: state.total + 1,
      );
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteCase(String caseId) async {
    try {
      await _caseService.deleteCase(caseId);
      state = state.copyWith(
        cases: state.cases.where((c) => c.id != caseId).toList(),
        total: state.total - 1,
      );
    } catch (e) {
      throw e;
    }
  }
}

