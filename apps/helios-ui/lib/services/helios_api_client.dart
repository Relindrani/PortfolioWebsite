part of helios_ui;

class HeliosApiClient {
  const HeliosApiClient({required this.baseUrl});

  final String baseUrl;

  Future<SystemSummary> fetchSummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/system/summary'),
    );

    if (response.statusCode != 200) {
      throw Exception('API returned ${response.statusCode}');
    }

    return SystemSummary.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<SignalDetail>> fetchSignals({int take = 8}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/signals?take=$take'),
    );

    if (response.statusCode != 200) {
      throw Exception('API returned ${response.statusCode}');
    }

    return (jsonDecode(response.body) as List<dynamic>)
        .map((item) => SignalDetail.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SignalRecorded> recordSignal({
    required String idempotencyKey,
    required String source,
    required String type,
    required String subject,
    required String payload,
    required String correlationId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/signals'),
      headers: {
        'Content-Type': 'application/json',
        'Idempotency-Key': idempotencyKey.trim(),
      },
      body: jsonEncode({
        'source': source.trim(),
        'type': type.trim(),
        'subject': subject.trim(),
        'payload': payload.trim(),
        'correlationId': correlationId.trim(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('API returned ${response.statusCode}: ${response.body}');
    }

    return SignalRecorded.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
