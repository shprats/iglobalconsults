/// Consultation Notes Screen
/// Add/edit diagnosis, treatment plan, and notes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/consultation_provider.dart';

class ConsultationNotesScreen extends ConsumerStatefulWidget {
  final String consultationId;

  const ConsultationNotesScreen({
    super.key,
    required this.consultationId,
  });

  @override
  ConsumerState<ConsultationNotesScreen> createState() =>
      _ConsultationNotesScreenState();
}

class _ConsultationNotesScreenState
    extends ConsumerState<ConsultationNotesScreen> {
  final _diagnosisController = TextEditingController();
  final _treatmentPlanController = TextEditingController();
  final _notesController = TextEditingController();
  bool _followUpRequired = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _treatmentPlanController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    final success = await ref
        .read(consultationsListProvider.notifier)
        .endConsultation(
          widget.consultationId,
          diagnosis: _diagnosisController.text.trim().isEmpty
              ? null
              : _diagnosisController.text.trim(),
          treatmentPlan: _treatmentPlanController.text.trim().isEmpty
              ? null
              : _treatmentPlanController.text.trim(),
          volunteerNotes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          followUpRequired: _followUpRequired,
        );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation notes saved')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${ref.read(consultationsListProvider).error ?? "Failed to save"}',
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
        title: const Text('Consultation Notes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                hintText: 'Enter diagnosis',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _treatmentPlanController,
              decoration: const InputDecoration(
                labelText: 'Treatment Plan',
                hintText: 'Enter treatment plan',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Any additional notes or observations',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Follow-up Required'),
              value: _followUpRequired,
              onChanged: (value) {
                setState(() => _followUpRequired = value ?? false);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Notes'),
            ),
          ],
        ),
      ),
    );
  }
}

