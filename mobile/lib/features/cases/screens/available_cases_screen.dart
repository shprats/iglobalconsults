/// Available Cases Screen
/// Shows cases needing volunteers (for volunteer physicians)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/case.dart';
import '../providers/available_cases_provider.dart';
import 'case_detail_screen.dart';
import 'accept_case_screen.dart';

class AvailableCasesScreen extends ConsumerStatefulWidget {
  const AvailableCasesScreen({super.key});

  @override
  ConsumerState<AvailableCasesScreen> createState() =>
      _AvailableCasesScreenState();
}

class _AvailableCasesScreenState extends ConsumerState<AvailableCasesScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(availableCasesProvider.notifier).loadMore();
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'emergency':
        return Colors.red;
      case 'urgent':
        return Colors.orange;
      case 'routine':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final casesState = ref.watch(availableCasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Cases'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(availableCasesProvider.notifier).loadAvailableCases(
                refresh: true,
              );
        },
        child: _buildBody(casesState),
      ),
    );
  }

  Widget _buildBody(AvailableCasesState state) {
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
                ref.read(availableCasesProvider.notifier).loadAvailableCases(
                      refresh: true,
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.cases.isEmpty) {
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
              'All cases have been assigned',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.cases.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.cases.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final medicalCase = state.cases[index];
        return _buildCaseCard(context, medicalCase);
      },
    );
  }

  Widget _buildCaseCard(BuildContext context, MedicalCase medicalCase) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CaseDetailScreen(caseId: medicalCase.id),
            ),
          );
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
                        fontSize: 18,
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
                      color: _getUrgencyColor(medicalCase.urgency)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      medicalCase.urgency.toUpperCase(),
                      style: TextStyle(
                        color: _getUrgencyColor(medicalCase.urgency),
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
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    _formatDate(medicalCase.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AcceptCaseScreen(
                            caseId: medicalCase.id,
                            caseTitle: medicalCase.title,
                          ),
                        ),
                      ).then((accepted) {
                        if (accepted == true) {
                          // Refresh list
                          ref
                              .read(availableCasesProvider.notifier)
                              .loadAvailableCases(refresh: true);
                        }
                      });
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept Case'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}

