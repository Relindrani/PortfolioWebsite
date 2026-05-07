part of helios_ui;

class _SignalConsole extends StatelessWidget {
  const _SignalConsole({
    required this.idempotencyKeyController,
    required this.sourceController,
    required this.typeController,
    required this.subjectController,
    required this.payloadController,
    required this.correlationIdController,
    required this.lastSignal,
    required this.signalError,
    required this.signalsFuture,
    required this.isSubmitting,
    required this.onSubmitNew,
    required this.onReplay,
    required this.onRefresh,
  });

  final TextEditingController idempotencyKeyController;
  final TextEditingController sourceController;
  final TextEditingController typeController;
  final TextEditingController subjectController;
  final TextEditingController payloadController;
  final TextEditingController correlationIdController;
  final SignalRecorded? lastSignal;
  final String? signalError;
  final Future<List<SignalDetail>> signalsFuture;
  final bool isSubmitting;
  final Future<void> Function() onSubmitNew;
  final Future<void> Function() onReplay;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        final formPanel = _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Eyebrow('Signal Intake'),
              const SizedBox(height: 8),
              const Text(
                'Record a Signal',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              _SignalTextField(
                controller: idempotencyKeyController,
                label: 'Idempotency key',
              ),
              const SizedBox(height: 12),
              _SignalTextField(controller: sourceController, label: 'Source'),
              const SizedBox(height: 12),
              _SignalTextField(controller: typeController, label: 'Type'),
              const SizedBox(height: 12),
              _SignalTextField(controller: subjectController, label: 'Subject'),
              const SizedBox(height: 12),
              _SignalTextField(
                controller: correlationIdController,
                label: 'Correlation ID',
              ),
              const SizedBox(height: 12),
              _SignalTextField(
                controller: payloadController,
                label: 'Payload',
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              if (signalError != null) ...[
                Text(
                  signalError!,
                  style: const TextStyle(color: Color(0xFFE9969F), height: 1.5),
                ),
                const SizedBox(height: 14),
              ],
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            onSubmitNew();
                          },
                    child: Text(isSubmitting ? 'Recording...' : 'Record new signal'),
                  ),
                  OutlinedButton(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            onReplay();
                          },
                    child: const Text('Replay same key'),
                  ),
                  TextButton(
                    onPressed: onRefresh,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ],
          ),
        );
        final activityPanel = Column(
          children: [
            _Panel(
              child: _LastSignalPanel(signal: lastSignal),
            ),
            const SizedBox(height: 24),
            _Panel(
              child: _RecentSignalsList(signalsFuture: signalsFuture),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            children: [
              formPanel,
              const SizedBox(height: 24),
              activityPanel,
            ],
          );
        }

        return Flex(
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: formPanel),
            const SizedBox(width: 24),
            Expanded(child: activityPanel),
          ],
        );
      },
    );
  }
}

class _SignalTextField extends StatelessWidget {
  const _SignalTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFF08101C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _LastSignalPanel extends StatelessWidget {
  const _LastSignalPanel({required this.signal});

  final SignalRecorded? signal;

  @override
  Widget build(BuildContext context) {
    if (signal == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow('Last Response'),
          SizedBox(height: 8),
          Text(
            'No signal recorded yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Eyebrow('Last Response'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SelectableText(
                signal!.signalId,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _StatusChip(signal!.wasDuplicate ? 'Duplicate' : signal!.status),
          ],
        ),
        const SizedBox(height: 14),
        _KeyValueLine(label: 'Event', value: signal!.event.type),
        _KeyValueLine(label: 'Key', value: signal!.idempotencyKey),
        _KeyValueLine(label: 'Recorded', value: signal!.formattedRecordedAtUtc),
      ],
    );
  }
}

class _RecentSignalsList extends StatelessWidget {
  const _RecentSignalsList({required this.signalsFuture});

  final Future<List<SignalDetail>> signalsFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SignalDetail>>(
      future: signalsFuture,
      builder: (context, snapshot) {
        final signals = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Eyebrow('Recent Signals'),
            const SizedBox(height: 8),
            if (snapshot.hasError)
              Text(
                '${snapshot.error}',
                style: const TextStyle(color: Color(0xFFE9969F), height: 1.5),
              )
            else if (!snapshot.hasData)
              const LinearProgressIndicator()
            else if (signals.isEmpty)
              const Text(
                'No recorded signals yet.',
                style: TextStyle(color: Color(0xFFB6C2D6), height: 1.6),
              )
            else
              ...signals.map(
                (signal) => Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: _ItemCard(
                    title: signal.type,
                    subtitle: signal.source,
                    description:
                        '${signal.subject} | ${signal.formattedRecordedAtUtc}',
                    status: signal.event.type,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
