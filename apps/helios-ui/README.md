# Helios UI

This app is the Flutter-based operator dashboard for Helios.

Current goals:

- establish the long-term UI stack as Flutter
- provide a simple dashboard that reads from the Helios API
- keep the web build easy to serve through Docker

## Local development

If Flutter is installed locally:

```bash
flutter pub get
flutter run -d chrome --dart-define=HELIOS_API_BASE_URL=http://localhost:5091
```

## Docker

The top-level `docker-compose.yml` builds the Flutter web app and serves it on
`http://localhost:4321`.
