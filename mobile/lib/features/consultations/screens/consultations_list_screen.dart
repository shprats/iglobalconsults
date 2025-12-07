/// Consultations List Screen
/// Shows consultations for current user

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/consultation_provider.dart';
import 'consultation_detail_screen.dart';

class ConsultationsListScreen extends ConsumerStatefulWidget {
  const ConsultationsListScreen({super.key});

  @override
  ConsumerState<ConsultationsListScreen> createState() =>
      _ConsultationsListScreenState();
}

class _ConsultationsListScreenState
    extends ConsumerState<ConsultationsListScreen> {
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
      ref.read(consultationsListProvider.notifier).loadMore();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'scheduled':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultationsState = ref.watch(consultationsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Consultations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(consultationsListProvider.notifier)
              .loadConsultations(refresh: true);
        },
        child: _buildBody(consultationsState),
      ),
    );
  }

  Widget _buildBody(ConsultationsState state) {
    if (state.isLoading && state.consultations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.consultations.isEmpty) {
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
                ref
                    .read(consultationsListProvider.notifier)
                    .loadConsultations(refresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.consultations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No consultations yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.consultations.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.consultations.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final consultation = state.consultations[index];
        return _buildConsultationCard(context, consultation);
      },
    );
  }

  Widget _buildConsultationCard(
      BuildContext context, Map<String, dynamic> consultation) {
    final scheduledStart =
        DateTime.parse(consultation['scheduled_start'] as String);
    final status = consultation['status'] as String;
    final caseId = consultation['case_id'] as String;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConsultationDetailScreen(
                consultationId: consultation['id'] as String,
              ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Case: ${consultation['case_id']?.toString().substring(0, 8) ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy • h:mm a').format(scheduledStart),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (consultation['diagnosis'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Diagnosis: ${consultation['diagnosis']}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Consultations'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Consultations'),
              onTap: () {
                ref.read(consultationsListProvider.notifier).setStatusFilter(null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Scheduled'),
              onTap: () {
                ref.read(consultationsListProvider.notifier).setStatusFilter('scheduled');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('In Progress'),
              onTap: () {
                ref.read(consultationsListProvider.notifier)
                    .setStatusFilter('in_progress');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Completed'),
              onTap: () {
                ref.read(consultationsListProvider.notifier)
                    .setStatusFilter('completed');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

