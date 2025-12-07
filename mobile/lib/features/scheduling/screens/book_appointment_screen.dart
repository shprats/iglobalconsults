/// Book Appointment Screen
/// Allows doctors to book appointments with volunteers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import '../providers/appointment_provider.dart';
import '../widgets/case_picker_dialog.dart';
import '../../cases/providers/case_provider.dart';
import '../../../core/models/case.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  final _scrollController = ScrollController();
  MedicalCase? _selectedCase;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load cases when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Cases will be loaded when dialog opens
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(availableSlotsProvider.notifier).loadMore();
    }
  }

  Future<void> _selectCase() async {
    final selectedCase = await showDialog<MedicalCase>(
      context: context,
      builder: (context) => const CasePickerDialog(),
    );

    if (selectedCase != null) {
      setState(() {
        _selectedCase = selectedCase;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotsState = ref.watch(availableSlotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        actions: [
          if (_selectedCase != null)
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: null,
              tooltip: 'Case selected',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(availableSlotsProvider.notifier).loadSlots(refresh: true);
        },
        child: _buildBody(slotsState),
      ),
    );
  }

  Widget _buildBody(AvailableSlotsState state) {
    if (state.isLoading && state.slots.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.slots.isEmpty) {
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
                ref.read(availableSlotsProvider.notifier).loadSlots(refresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show case selection prompt if no case selected
    if (_selectedCase == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_information, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Select a Case First',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a case to book an appointment for',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectCase,
              icon: const Icon(Icons.medical_information),
              label: const Text('Select Case'),
            ),
          ],
        ),
      );
    }

    if (state.slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No available slots',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Volunteers need to add their availability first',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _selectCase,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Change Case'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.slots.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.slots.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final slot = state.slots[index];
        return _buildSlotCard(context, slot);
      },
    );
  }

  Widget _buildSlotCard(BuildContext context, Map<String, dynamic> slot) {
    final startTime = DateTime.parse(slot['start_time'] as String);
    final endTime = DateTime.parse(slot['end_time'] as String);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected case info
            if (_selectedCase != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_information, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedCase!.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: _selectCase,
                      child: const Text('Change', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              DateFormat('MMM d, yyyy').format(startTime),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('h:mm a').format(startTime)} - ${DateFormat('h:mm a').format(endTime)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _selectedCase == null
                  ? _selectCase
                  : () {
                      _showBookDialog(context, slot);
                    },
              child: Text(_selectedCase == null
                  ? 'Select Case to Book'
                  : 'Book This Slot'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBookDialog(
      BuildContext context, Map<String, dynamic> slot) async {
    if (_selectedCase == null) {
      await _selectCase();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Book appointment for:'),
            const SizedBox(height: 8),
            Text(
              _selectedCase!.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Slot:'),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM d, yyyy • h:mm a').format(DateTime.parse(slot['start_time'] as String))}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _bookAppointment(slot);
    }
  }

  Future<void> _bookAppointment(Map<String, dynamic> slot) async {
    if (_selectedCase == null) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success = await ref.read(availableSlotsProvider.notifier).bookAppointment(
            slotId: slot['id'] as String,
            caseId: _selectedCase!.id,
          );

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to previous screen
      } else {
        final error = ref.read(availableSlotsProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error ?? "Failed to book appointment"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

