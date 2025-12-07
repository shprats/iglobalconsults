/// Book Appointment Screen
/// Allows doctors to book appointments with volunteers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/appointment_service.dart';
import '../providers/appointment_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
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
      ref.read(availableSlotsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotsState = ref.watch(availableSlotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
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

    if (state.slots.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No available slots',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Volunteers need to add their availability first',
              style: TextStyle(color: Colors.grey),
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
              onPressed: () {
                _showBookDialog(context, slot);
              },
              child: const Text('Book This Slot'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookDialog(BuildContext context, Map<String, dynamic> slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Appointment'),
        content: const Text('Select a case to book this appointment for:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Show case selection dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Case selection coming soon'),
                ),
              );
            },
            child: const Text('Select Case'),
          ),
        ],
      ),
    );
  }
}

