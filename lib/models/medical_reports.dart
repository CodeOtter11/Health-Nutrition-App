class MedicalReports {
  final String name;
  final String type;
  final DateTime uploadedAt;
  final String? url;

  MedicalReports({
    required this.name,
    required this.type,
    required this.uploadedAt,
    this.url,
  });
}