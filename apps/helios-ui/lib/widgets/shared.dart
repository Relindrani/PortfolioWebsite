part of helios_ui;

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

    if (normalized == 'online' ||
        normalized == 'ready' ||
        normalized == 'healthy') {
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

class _KeyValueLine extends StatelessWidget {
  const _KeyValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8EA3C0)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFFB6C2D6), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatUtcDate(DateTime timestampUtc) {
  final month = _monthNames[timestampUtc.month - 1];
  final day = timestampUtc.day.toString().padLeft(2, '0');
  final hour = timestampUtc.hour.toString().padLeft(2, '0');
  final minute = timestampUtc.minute.toString().padLeft(2, '0');

  return '$month $day, ${timestampUtc.year} $hour:$minute UTC';
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
