/// Case Picker Dialog
/// Allows doctors to select a case when booking an appointment

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../cases/providers/case_provider.dart';
import '../../../core/models/case.dart';

class CasePickerDialog extends ConsumerWidget {
  const CasePickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesState = ref.watch(casesListProvider);

    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Select Case',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Cases List
            Expanded(
              child: _buildCasesList(context, ref, casesState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesList(
    BuildContext context,
    WidgetRef ref,
    CasesState state,
  ) {
    if (state.isLoading && state.cases.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.cases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.error}',
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(casesListProvider.notifier).fetchCases(isRefresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter out cases that already have consultations
    // For now, we'll show all cases - the backend will handle validation
    final availableCases = state.cases.where((c) => c.status != 'completed').toList();

    if (availableCases.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_information, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No cases available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Create a case first to book an appointment',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: availableCases.length,
      itemBuilder: (context, index) {
        final medicalCase = availableCases[index];
        return _buildCaseItem(context, medicalCase);
      },
    );
  }

  Widget _buildCaseItem(BuildContext context, MedicalCase medicalCase) {
    Color urgencyColor;
    switch (medicalCase.urgency) {
      case 'emergency':
        urgencyColor = Colors.red;
        break;
      case 'urgent':
        urgencyColor = Colors.orange;
        break;
      case 'routine':
        urgencyColor = Colors.green;
        break;
      default:
        urgencyColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, medicalCase);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      medicalCase.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      medicalCase.urgency.toUpperCase(),
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                medicalCase.chiefComplaint,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(medicalCase.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(medicalCase.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      medicalCase.status.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(medicalCase.status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

