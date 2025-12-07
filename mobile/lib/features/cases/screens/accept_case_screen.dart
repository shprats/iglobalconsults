/// Accept Case Screen
/// Allows volunteers to accept a case and schedule consultation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/available_cases_provider.dart';

class AcceptCaseScreen extends ConsumerStatefulWidget {
  final String caseId;
  final String caseTitle;

  const AcceptCaseScreen({
    super.key,
    required this.caseId,
    required this.caseTitle,
  });

  @override
  ConsumerState<AcceptCaseScreen> createState() => _AcceptCaseScreenState();
}

class _AcceptCaseScreenState extends ConsumerState<AcceptCaseScreen> {
  DateTime? _consultationDate;
  TimeOfDay? _startTime;
  int _durationMinutes = 30;
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _consultationDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _handleAccept() async {
    if (_consultationDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _consultationDate!.year,
      _consultationDate!.month,
      _consultationDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final endDateTime = startDateTime.add(Duration(minutes: _durationMinutes));

    setState(() => _isLoading = true);

    final success = await ref.read(availableCasesProvider.notifier).acceptCase(
          caseId: widget.caseId,
          scheduledStart: startDateTime,
          scheduledEnd: endDateTime,
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Case accepted successfully')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${ref.read(availableCasesProvider).error ?? "Failed to accept case"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept Case'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.caseTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Schedule Consultation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Date
            const Text('Consultation Date *'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      _consultationDate == null
                          ? 'Select date'
                          : DateFormat('MMM d, yyyy').format(_consultationDate!),
                      style: TextStyle(
                        color: _consultationDate == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Time
            const Text('Start Time *'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Text(
                      _startTime == null
                          ? 'Select time'
                          : _startTime!.format(context),
                      style: TextStyle(
                        color: _startTime == null ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Duration
            const Text('Duration'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _durationMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: [15, 30, 45, 60]
                  .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text('$duration minutes'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _durationMinutes = value);
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleAccept,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Accept Case'),
            ),
          ],
        ),
      ),
    );
  }
}

