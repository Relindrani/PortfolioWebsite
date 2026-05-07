part of helios_ui;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HeliosApiClient _apiClient = const HeliosApiClient(
    baseUrl: configuredApiBaseUrl,
  );

  late Future<SystemSummary> _summaryFuture;
  late Future<List<SignalDetail>> _signalsFuture;
  late final TextEditingController _idempotencyKeyController;
  late final TextEditingController _sourceController;
  late final TextEditingController _typeController;
  late final TextEditingController _subjectController;
  late final TextEditingController _payloadController;
  late final TextEditingController _correlationIdController;
  SignalRecorded? _lastSignal;
  String? _signalError;
  bool _isSubmittingSignal = false;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _apiClient.fetchSummary();
    _signalsFuture = _apiClient.fetchSignals();
    _idempotencyKeyController = TextEditingController(
      text: _newIdempotencyKey(),
    );
    _sourceController = TextEditingController(text: 'operator-dashboard');
    _typeController = TextEditingController(text: 'PortfolioViewed');
    _subjectController = TextEditingController(text: 'helios-control-plane');
    _payloadController = TextEditingController(text: '{"page":"helios"}');
    _correlationIdController = TextEditingController(text: 'portfolio-demo');
  }

  @override
  void dispose() {
    _idempotencyKeyController.dispose();
    _sourceController.dispose();
    _typeController.dispose();
    _subjectController.dispose();
    _payloadController.dispose();
    _correlationIdController.dispose();
    super.dispose();
  }

  Future<void> submitSignal({required bool reuseIdempotencyKey}) async {
    if (!reuseIdempotencyKey) {
      _idempotencyKeyController.text = _newIdempotencyKey();
    }

    setState(() {
      _isSubmittingSignal = true;
      _signalError = null;
    });

    try {
      final recordedSignal = await _apiClient.recordSignal(
        idempotencyKey: _idempotencyKeyController.text,
        source: _sourceController.text,
        type: _typeController.text,
        subject: _subjectController.text,
        payload: _payloadController.text,
        correlationId: _correlationIdController.text,
      );

      setState(() {
        _lastSignal = recordedSignal;
        _signalsFuture = _apiClient.fetchSignals();
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _signalError = '$error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingSignal = false;
        });
      }
    }
  }

  void refreshSignals() {
    setState(() {
      _signalsFuture = _apiClient.fetchSignals();
    });
  }

  String _newIdempotencyKey() {
    return 'ui-signal-${DateTime.now().microsecondsSinceEpoch}';
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
                    const SizedBox(height: 24),
                    _SignalConsole(
                      idempotencyKeyController: _idempotencyKeyController,
                      sourceController: _sourceController,
                      typeController: _typeController,
                      subjectController: _subjectController,
                      payloadController: _payloadController,
                      correlationIdController: _correlationIdController,
                      lastSignal: _lastSignal,
                      signalError: _signalError,
                      signalsFuture: _signalsFuture,
                      isSubmitting: _isSubmittingSignal,
                      onSubmitNew: () => submitSignal(
                        reuseIdempotencyKey: false,
                      ),
                      onReplay: () => submitSignal(reuseIdempotencyKey: true),
                      onRefresh: refreshSignals,
                    ),
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
