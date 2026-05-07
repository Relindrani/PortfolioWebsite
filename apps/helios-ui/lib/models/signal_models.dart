part of helios_ui;

class SignalRecorded {
  SignalRecorded({
    required this.signalId,
    required this.idempotencyKey,
    required this.status,
    required this.wasDuplicate,
    required this.recordedAtUtc,
    required this.event,
  });

  factory SignalRecorded.fromJson(Map<String, dynamic> json) {
    return SignalRecorded(
      signalId: json['signalId'] as String,
      idempotencyKey: json['idempotencyKey'] as String,
      status: json['status'] as String,
      wasDuplicate: json['wasDuplicate'] as bool,
      recordedAtUtc: DateTime.parse(json['recordedAtUtc'] as String),
      event: SignalEvent.fromJson(json['event'] as Map<String, dynamic>),
    );
  }

  final String signalId;
  final String idempotencyKey;
  final String status;
  final bool wasDuplicate;
  final DateTime recordedAtUtc;
  final SignalEvent event;

  String get formattedRecordedAtUtc => _formatUtcDate(recordedAtUtc);
}

class SignalDetail {
  SignalDetail({
    required this.signalId,
    required this.idempotencyKey,
    required this.source,
    required this.type,
    required this.subject,
    required this.payload,
    required this.correlationId,
    required this.recordedAtUtc,
    required this.event,
  });

  factory SignalDetail.fromJson(Map<String, dynamic> json) {
    return SignalDetail(
      signalId: json['signalId'] as String,
      idempotencyKey: json['idempotencyKey'] as String,
      source: json['source'] as String,
      type: json['type'] as String,
      subject: json['subject'] as String,
      payload: json['payload'] as String?,
      correlationId: json['correlationId'] as String,
      recordedAtUtc: DateTime.parse(json['recordedAtUtc'] as String),
      event: SignalEvent.fromJson(json['event'] as Map<String, dynamic>),
    );
  }

  final String signalId;
  final String idempotencyKey;
  final String source;
  final String type;
  final String subject;
  final String? payload;
  final String correlationId;
  final DateTime recordedAtUtc;
  final SignalEvent event;

  String get formattedRecordedAtUtc => _formatUtcDate(recordedAtUtc);
}

class SignalEvent {
  SignalEvent({
    required this.eventId,
    required this.type,
    required this.source,
    required this.subject,
    required this.correlationId,
    required this.occurredAtUtc,
  });

  factory SignalEvent.fromJson(Map<String, dynamic> json) {
    return SignalEvent(
      eventId: json['eventId'] as String,
      type: json['type'] as String,
      source: json['source'] as String,
      subject: json['subject'] as String,
      correlationId: json['correlationId'] as String,
      occurredAtUtc: DateTime.parse(json['occurredAtUtc'] as String),
    );
  }

  final String eventId;
  final String type;
  final String source;
  final String subject;
  final String correlationId;
  final DateTime occurredAtUtc;
}
