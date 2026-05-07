FROM rust:1-alpine AS rules-build
WORKDIR /src/rules-engine/helios_rules

COPY rules-engine/helios_rules/Cargo.toml rules-engine/helios_rules/Cargo.lock ./
COPY rules-engine/helios_rules/src ./src
RUN cargo build --release

FROM golang:1.25-alpine AS build
WORKDIR /src/event-processor

COPY event-processor/go.mod event-processor/go.sum* ./
RUN go mod download

COPY event-processor ./
RUN CGO_ENABLED=0 go build -o /out/helios-event-processor .

FROM alpine:3.22
WORKDIR /app

COPY --from=build /out/helios-event-processor ./helios-event-processor
COPY --from=rules-build /src/rules-engine/helios_rules/target/release/helios_rules ./helios_rules

ENTRYPOINT ["/app/helios-event-processor"]
