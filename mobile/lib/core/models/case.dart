/// Case Model
/// Represents a medical case

class MedicalCase {
  final String id;
  final String requestingDoctorId;
  final String? patientId;
  final String? assignedVolunteerId;
  final String title;
  final String chiefComplaint;
  final String urgency; // 'emergency', 'urgent', 'routine'
  final String status; // 'pending', 'assigned', 'in_progress', 'completed', 'cancelled'
  final String? description;
  final String? patientHistory;
  final String? currentMedications;
  final String? allergies;
  final String? vitalSigns;
  final DateTime createdAt;
  final DateTime updatedAt;

  MedicalCase({
    required this.id,
    required this.requestingDoctorId,
    this.patientId,
    this.assignedVolunteerId,
    required this.title,
    required this.chiefComplaint,
    required this.urgency,
    required this.status,
    this.description,
    this.patientHistory,
    this.currentMedications,
    this.allergies,
    this.vitalSigns,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmergency => urgency == 'emergency';
  bool get isUrgent => urgency == 'urgent';
  bool get isPending => status == 'pending';
  bool get isAssigned => status == 'assigned';
  bool get isCompleted => status == 'completed';

  factory MedicalCase.fromJson(Map<String, dynamic> json) {
    return MedicalCase(
      id: json['id'] as String,
      requestingDoctorId: json['requesting_doctor_id'] as String,
      patientId: json['patient_id'] as String?,
      assignedVolunteerId: json['assigned_volunteer_id'] as String?,
      title: json['title'] as String,
      chiefComplaint: json['chief_complaint'] as String,
      urgency: json['urgency'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      patientHistory: json['patient_history'] as String?,
      currentMedications: json['current_medications'] as String?,
      allergies: json['allergies'] as String?,
      vitalSigns: json['vital_signs'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesting_doctor_id': requestingDoctorId,
      'patient_id': patientId,
      'assigned_volunteer_id': assignedVolunteerId,
      'title': title,
      'chief_complaint': chiefComplaint,
      'urgency': urgency,
      'status': status,
      'description': description,
      'patient_history': patientHistory,
      'current_medications': currentMedications,
      'allergies': allergies,
      'vital_signs': vitalSigns,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

