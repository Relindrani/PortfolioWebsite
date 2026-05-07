library helios_ui;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

part 'models/signal_models.dart';
part 'models/system_models.dart';
part 'screens/dashboard_screen.dart';
part 'services/helios_api_client.dart';
part 'widgets/shared.dart';
part 'widgets/signal_console.dart';
part 'widgets/system_sections.dart';

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
