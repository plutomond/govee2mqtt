####################################################################################################
## Builder: baut die govee-Binary aus dem Source im Repo
####################################################################################################
FROM --platform=$BUILDPLATFORM rust:1.81-bullseye AS builder
ARG TARGETPLATFORM

# Benutzer anlegen (UID 1000 wie vorher)
RUN useradd -u 1000 -m govee

WORKDIR /app

# Build-Abhängigkeiten (für TLS/HTTPS usw.)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      pkg-config \
      libssl-dev \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Source-Code ins Build-Image kopieren
COPY Cargo.toml Cargo.lock ./
COPY build.rs ./
COPY src ./src
COPY assets ./assets
COPY AmazonRootCA1.pem ./

# Release-Build der govee-Binary
RUN cargo build --release -p govee

# /data-Verzeichnis vorbereiten (wie vorher)
RUN mkdir -p /data && chown govee:govee /data

####################################################################################################
## Final image: schlankes Laufzeit-Image
####################################################################################################
FROM gcr.io/distroless/cc-debian12

# Benutzer/Gruppe aus Builder übernehmen
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /app

# frisch gebaute Binary verwenden
COPY --from=builder /app/target/release/govee /app/govee
COPY --from=builder /app/AmazonRootCA1.pem /app/
COPY --from=builder /app/assets /app/assets
COPY --from=builder --chown=govee:govee /data /data

USER govee:govee

LABEL org.opencontainers.image.source="https://github.com/plutomond/govee2mqtt"

ENV \
  RUST_BACKTRACE=full \
  PATH=/app:$PATH \
  XDG_CACHE_HOME=/data

VOLUME /data

CMD ["/app/govee", \
  "serve", \
  "--govee-iot-key=/data/iot.key", \
  "--govee-iot-cert=/data/iot.cert", \
  "--amazon-root-ca=/app/AmazonRootCA1.pem"]
