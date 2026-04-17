import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String configuredApiBaseUrl = String.fromEnvironment(
  'HELIOS_API_BASE_URL',
  defaultValue: 'http://localhost:5091',
);

void main() {
  runApp(const HeliosApp());
}

class HeliosApp extends StatelessWidget {
  const HeliosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helios UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF39C38A),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF09111F),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<SystemSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = fetchSummary();
  }

  Future<SystemSummary> fetchSummary() async {
    final response = await http.get(
      Uri.parse('$configuredApiBaseUrl/api/system/summary'),
    );

    if (response.statusCode != 200) {
      throw Exception('API returned ${response.statusCode}');
    }

    return SystemSummary.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<SystemSummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Hero(apiBaseUrl: configuredApiBaseUrl),
                  const SizedBox(height: 24),
                  if (snapshot.hasData) ...[
                    _Overview(summary: snapshot.data!),
                    const SizedBox(height: 24),
                    _ContentGrid(summary: snapshot.data!),
                  ] else if (snapshot.hasError) ...[
                    _ErrorPanel(message: '${snapshot.error}'),
                  ] else ...[
                    const _LoadingState(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.apiBaseUrl});

  final String apiBaseUrl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        return Flex(
          direction: isNarrow ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isNarrow ? 0 : 2,
              child: _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _Eyebrow('Helios Control Plane'),
                    SizedBox(height: 12),
                    Text(
                      'Bootstrap Dashboard',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'A first Flutter-based operational UI shell for Helios. It reads from the ASP.NET Core API and gives us a clean place to grow timelines, workflow state, and decision explanations.',
                      style: TextStyle(
                        color: Color(0xFFB6C2D6),
                        height: 1.6,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: isNarrow ? 0 : 24, height: isNarrow ? 24 : 0),
            Expanded(
              child: _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Eyebrow('API Base URL'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF08101C),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x2E94A3B8)),
                      ),
                      child: SelectableText(
                        apiBaseUrl,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Change the build-time API base URL with --dart-define=HELIOS_API_BASE_URL=...',
                      style: TextStyle(color: Color(0xFFB6C2D6), height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({required this.summary});

  final SystemSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        return Flex(
          direction: isNarrow ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              child: _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Eyebrow('System'),
                    Text(
                      summary.systemName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatusChip(summary.status),
                    const SizedBox(height: 16),
                    Text(
                      summary.primaryObjective,
                      style: const TextStyle(
                        color: Color(0xFFB6C2D6),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: isNarrow ? 0 : 24, height: isNarrow ? 24 : 0),
            Expanded(
              child: _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Eyebrow('Environment'),
                    Text(
                      summary.environment,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Last refreshed ${summary.formattedTimestampUtc}',
                      style: const TextStyle(
                        color: Color(0xFFB6C2D6),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ContentGrid extends StatelessWidget {
  const _ContentGrid({required this.summary});

  final SystemSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        return Flex(
          direction: isNarrow ? Axis.vertical : Axis.horizontal,
          children: [
            Expanded(
              child: _Panel(
                child: _SectionList<ServiceStatus>(
                  title: 'Services',
                  subtitle: 'Current system slices we can reason about and extend.',
                  items: summary.services,
                  titleBuilder: (service) => service.name,
                  subtitleBuilder: (service) => '${service.plane} Plane',
                  descriptionBuilder: (service) => service.responsibility,
                  statusBuilder: (service) => service.status,
                ),
              ),
            ),
            SizedBox(width: isNarrow ? 0 : 24, height: isNarrow ? 24 : 0),
            Expanded(
              child: _Panel(
                child: _SectionList<Capability>(
                  title: 'Capabilities',
                  subtitle: 'What this first Helios slice supports today and what comes next.',
                  items: summary.capabilities,
                  titleBuilder: (capability) => capability.name,
                  subtitleBuilder: (_) => null,
                  descriptionBuilder: (capability) => capability.description,
                  statusBuilder: (capability) => capability.status,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionList<T> extends StatelessWidget {
  const _SectionList({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.titleBuilder,
    required this.subtitleBuilder,
    required this.descriptionBuilder,
    required this.statusBuilder,
  });

  final String title;
  final String subtitle;
  final List<T> items;
  final String Function(T item) titleBuilder;
  final String? Function(T item) subtitleBuilder;
  final String Function(T item) descriptionBuilder;
  final String Function(T item) statusBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFFB6C2D6), height: 1.6),
        ),
        const SizedBox(height: 20),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ItemCard(
              title: titleBuilder(item),
              subtitle: subtitleBuilder(item),
              description: descriptionBuilder(item),
              status: statusBuilder(item),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.status,
  });

  final String title;
  final String? subtitle;
  final String description;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101B2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x2E94A3B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Color(0xFF8EA3C0),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Color(0xFFB6C2D6), height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loading Helios summary',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12),
          Text(
            'The Flutter dashboard is waiting for the API response.',
            style: TextStyle(color: Color(0xFFB6C2D6), height: 1.6),
          ),
          SizedBox(height: 24),
          LinearProgressIndicator(),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'API not reachable yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            'The Flutter UI scaffold is in place, but the API could not be reached from the browser.',
            style: TextStyle(color: Color(0xFFB6C2D6), height: 1.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Error: $message',
            style: const TextStyle(color: Color(0xFFE9969F), height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xF2111B2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x2E94A3B8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59020617),
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF72E2AE),
        letterSpacing: 1.4,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    Color foreground = const Color(0xFFF0B35D);
    Color background = const Color(0x24F0B35D);
    Color border = const Color(0x47F0B35D);

    if (normalized == 'online' || normalized == 'ready' || normalized == 'healthy') {
      foreground = const Color(0xFF72E2AE);
      background = const Color(0x2472E2AE);
      border = const Color(0x4772E2AE);
    } else if (normalized == 'offline') {
      foreground = const Color(0xFFEF6B73);
      background = const Color(0x24EF6B73);
      border = const Color(0x47EF6B73);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          fontSize: 12,
        ),
      ),
    );
  }
}

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

  String get formattedTimestampUtc {
    final month = _monthNames[timestampUtc.month - 1];
    final day = timestampUtc.day.toString().padLeft(2, '0');
    final hour = timestampUtc.hour.toString().padLeft(2, '0');
    final minute = timestampUtc.minute.toString().padLeft(2, '0');

    return '$month $day, ${timestampUtc.year} $hour:$minute UTC';
  }
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

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
