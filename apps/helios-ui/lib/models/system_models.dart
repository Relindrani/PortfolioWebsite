part of helios_ui;

class SystemSummary {
  SystemSummary({
    required this.systemName,
    required this.environment,
    required this.status,
    required this.primaryObjective,
    required this.services,
    required this.capabilities,
    required this.timestampUtc,
  });

  factory SystemSummary.fromJson(Map<String, dynamic> json) {
    return SystemSummary(
      systemName: json['systemName'] as String,
      environment: json['environment'] as String,
      status: json['status'] as String,
      primaryObjective: json['primaryObjective'] as String,
      services: (json['services'] as List<dynamic>)
          .map((item) => ServiceStatus.fromJson(item as Map<String, dynamic>))
          .toList(),
      capabilities: (json['capabilities'] as List<dynamic>)
          .map((item) => Capability.fromJson(item as Map<String, dynamic>))
          .toList(),
      timestampUtc: DateTime.parse(json['timestampUtc'] as String),
    );
  }

  final String systemName;
  final String environment;
  final String status;
  final String primaryObjective;
  final List<ServiceStatus> services;
  final List<Capability> capabilities;
  final DateTime timestampUtc;

  String get formattedTimestampUtc => _formatUtcDate(timestampUtc);
}

class ServiceStatus {
  ServiceStatus({
    required this.name,
    required this.responsibility,
    required this.status,
    required this.plane,
  });

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      name: json['name'] as String,
      responsibility: json['responsibility'] as String,
      status: json['status'] as String,
      plane: json['plane'] as String,
    );
  }

  final String name;
  final String responsibility;
  final String status;
  final String plane;
}

class Capability {
  Capability({
    required this.name,
    required this.description,
    required this.status,
  });

  factory Capability.fromJson(Map<String, dynamic> json) {
    return Capability(
      name: json['name'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
    );
  }

  final String name;
  final String description;
  final String status;
}
