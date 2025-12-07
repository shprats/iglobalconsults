/// Edit Availability Screen
/// Form to edit existing availability blocks

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/availability_provider.dart';

class EditAvailabilityScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> availabilityBlock;

  const EditAvailabilityScreen({
    super.key,
    required this.availabilityBlock,
  });

  @override
  ConsumerState<EditAvailabilityScreen> createState() =>
      _EditAvailabilityScreenState();
}

class _EditAvailabilityScreenState
    extends ConsumerState<EditAvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  late int _slotDurationMinutes;
  late bool _isRecurring;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing values
    final startTime = DateTime.parse(widget.availabilityBlock['start_time'] as String);
    final endTime = DateTime.parse(widget.availabilityBlock['end_time'] as String);
    
    _startDate = startTime;
    _startTime = TimeOfDay.fromDateTime(startTime);
    _endDate = endTime;
    _endTime = TimeOfDay.fromDateTime(endTime);
    _slotDurationMinutes = widget.availabilityBlock['slot_duration_minutes'] as int? ?? 10;
    _isRecurring = widget.availabilityBlock['is_recurring'] as bool? ?? false;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Combine date and time
    final startDateTime = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final blockId = widget.availabilityBlock['id'] as String;
    final success = await ref
        .read(availabilityBlocksProvider.notifier)
        .updateAvailabilityBlock(
          blockId: blockId,
          startTime: startDateTime,
          endTime: endDateTime,
          timezone: 'UTC', // TODO: Get user's timezone
          slotDurationMinutes: _slotDurationMinutes,
          isRecurring: _isRecurring,
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability updated successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${ref.read(availabilityBlocksProvider).error ?? "Failed to update availability"}',
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
        title: const Text('Edit Availability'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Update Availability',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Start Date
              const Text(
                'Start Date *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectStartDate,
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
                        DateFormat('MMM d, yyyy').format(_startDate),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Start Time
              const Text(
                'Start Time *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectStartTime,
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
                      Text(_startTime.format(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // End Date
              const Text(
                'End Date *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectEndDate,
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
                        DateFormat('MMM d, yyyy').format(_endDate),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // End Time
              const Text(
                'End Time *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectEndTime,
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
                      Text(_endTime.format(context)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Slot Duration
              const Text(
                'Slot Duration (minutes)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _slotDurationMinutes,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [10, 15, 30, 60]
                    .map((duration) => DropdownMenuItem(
                          value: duration,
                          child: Text('$duration minutes'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _slotDurationMinutes = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              // Recurring
              CheckboxListTile(
                title: const Text('Recurring availability'),
                subtitle: const Text('Repeat this schedule'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() => _isRecurring = value ?? false);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Availability'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

