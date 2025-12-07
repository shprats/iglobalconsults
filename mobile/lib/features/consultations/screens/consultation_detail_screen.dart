/// Consultation Detail Screen
/// Shows consultation details and allows start/end

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/consultation_provider.dart';
import '../services/consultation_service.dart';
import 'consultation_notes_screen.dart';
import '../../video_call/screens/video_call_screen.dart';
import '../../../core/config/app_config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../video_call/screens/video_call_screen.dart';
import '../../video/screens/video_call_screen.dart';

class ConsultationDetailScreen extends ConsumerStatefulWidget {
  final String consultationId;

  const ConsultationDetailScreen({
    super.key,
    required this.consultationId,
  });

  @override
  ConsumerState<ConsultationDetailScreen> createState() =>
      _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState
    extends ConsumerState<ConsultationDetailScreen> {
  Map<String, dynamic>? _consultation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConsultation();
  }

  Future<void> _loadConsultation() async {
    try {
      final service = ref.read(consultationServiceProvider);
      final consultation = await service.getConsultationById(widget.consultationId);
      setState(() {
        _consultation = consultation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleStart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Consultation'),
        content: const Text('Are you ready to start the video consultation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
      // Start consultation and get Agora token
      final service = ref.read(consultationServiceProvider);
      final startResponse = await service.startConsultation(widget.consultationId);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Get current user for user ID
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Extract Agora details from response
      final agoraAppId = startResponse['agora_app_id'] as String? ?? '';
      final agoraToken = startResponse['agora_token'] as String?;
      final channelName = startResponse['agora_channel_name'] as String?;

      if (agoraToken == null || channelName == null || agoraAppId.isEmpty) {
        throw Exception('Agora credentials not found in response');
      }

      // Generate user ID from user ID string (use hash of UUID)
      // Agora requires numeric UID, so we'll use a hash of the user ID
      final userId = currentUser.id.hashCode.abs() % 2147483647; // Max int32

      // Navigate to video call screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              consultationId: widget.consultationId,
              channelName: channelName,
              agoraToken: agoraToken,
              agoraAppId: agoraAppId,
              userId: userId,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog if still open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting consultation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleEnd() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConsultationNotesScreen(
          consultationId: widget.consultationId,
        ),
      ),
    ).then((_) => _loadConsultation());
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
    if (_isLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _consultation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Consultation Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Consultation not found',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final consultation = _consultation!;
    final status = consultation['status'] as String;
    final scheduledStart =
        DateTime.parse(consultation['scheduled_start'] as String);
    final scheduledEnd = DateTime.parse(consultation['scheduled_end'] as String);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status.toUpperCase().replaceAll('_', ' '),
                style: TextStyle(
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Schedule
            _buildSection(
              'Schedule',
              Icons.calendar_today,
              [
                _buildInfoRow('Date', DateFormat('MMM d, yyyy').format(scheduledStart)),
                _buildInfoRow('Start', DateFormat('h:mm a').format(scheduledStart)),
                _buildInfoRow('End', DateFormat('h:mm a').format(scheduledEnd)),
                if (consultation['duration_minutes'] != null)
                  _buildInfoRow(
                    'Duration',
                    '${consultation['duration_minutes']} minutes',
                  ),
              ],
            ),
            // Diagnosis
            if (consultation['diagnosis'] != null)
              _buildSection(
                'Diagnosis',
                Icons.medical_services,
                [Text(consultation['diagnosis'] as String)],
              ),
            // Treatment Plan
            if (consultation['treatment_plan'] != null)
              _buildSection(
                'Treatment Plan',
                Icons.medication,
                [Text(consultation['treatment_plan'] as String)],
              ),
            // Notes
            if (consultation['volunteer_notes'] != null)
              _buildSection(
                'Notes',
                Icons.note,
                [Text(consultation['volunteer_notes'] as String)],
              ),
            const SizedBox(height: 24),
            // Actions
            if (status == 'scheduled')
              ElevatedButton.icon(
                onPressed: _handleStart,
                          ),
                        ),
                      ).then((_) => _loadConsultation());
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error: ${ref.read(consultationsListProvider).error ?? "Failed to start"}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.video_call),
                label: const Text('Start Consultation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
            if (status == 'in_progress') ...[
              ElevatedButton.icon(
                onPressed: () {
                  // Join ongoing video call
                  if (_consultation != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          consultationId: widget.consultationId,
                          agoraToken: _consultation!['agora_token'] as String?,
                          channelName: _consultation!['agora_channel_name'] as String?,
                          appId: _consultation!['agora_app_id'] as String?,
                        ),
                      ),
                    ).then((_) => _loadConsultation());
                  }
                },
                icon: const Icon(Icons.video_call),
                label: const Text('Join Call'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _handleEnd,
                icon: const Icon(Icons.stop),
                label: const Text('End Consultation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            if (status == 'completed' || status == 'in_progress')
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsultationNotesScreen(
                        consultationId: widget.consultationId,
                      ),
                    ),
                  ).then((_) => _loadConsultation());
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Notes'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

