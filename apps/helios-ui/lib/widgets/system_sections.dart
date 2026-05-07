part of helios_ui;

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
