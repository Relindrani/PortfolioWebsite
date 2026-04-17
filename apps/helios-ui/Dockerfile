FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

ARG HELIOS_API_BASE_URL=http://localhost:5091

COPY pubspec.yaml ./
RUN flutter pub get

COPY . ./
RUN flutter build web --release --dart-define=HELIOS_API_BASE_URL=${HELIOS_API_BASE_URL}

FROM nginx:1.27-alpine AS runtime
WORKDIR /usr/share/nginx/html

COPY --from=build /app/build/web ./

EXPOSE 80
